import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/venue_model.dart';

/// Tipo de badge de estado operativo de un establecimiento
enum VenueBadgeType {
  open,
  openingToday,
  closedToday,
  permanentlyClosed;

  Color get color {
    switch (this) {
      case VenueBadgeType.open:
        return AppColors.neonGreen;
      case VenueBadgeType.openingToday:
        return AppColors.neonAmber;
      case VenueBadgeType.closedToday:
        return AppColors.neonRedAlert.withOpacity(0.85);
      case VenueBadgeType.permanentlyClosed:
        return Colors.white54;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case VenueBadgeType.open:
        return AppColors.neonGreen.withOpacity(0.18);
      case VenueBadgeType.openingToday:
        return AppColors.neonAmber.withOpacity(0.18);
      case VenueBadgeType.closedToday:
        return AppColors.neonRedAlert.withOpacity(0.14);
      case VenueBadgeType.permanentlyClosed:
        return Colors.white10;
    }
  }

  Color get borderColor {
    switch (this) {
      case VenueBadgeType.open:
        return AppColors.neonGreen.withOpacity(0.6);
      case VenueBadgeType.openingToday:
        return AppColors.neonAmber.withOpacity(0.6);
      case VenueBadgeType.closedToday:
        return AppColors.neonRedAlert.withOpacity(0.35);
      case VenueBadgeType.permanentlyClosed:
        return Colors.white24;
    }
  }

  IconData get icon {
    switch (this) {
      case VenueBadgeType.open:
        return Icons.circle;
      case VenueBadgeType.openingToday:
        return Icons.access_time_filled_rounded;
      case VenueBadgeType.closedToday:
        return Icons.nightlight_round;
      case VenueBadgeType.permanentlyClosed:
        return Icons.power_off_rounded;
    }
  }
}

/// Resultado de la evaluación inteligente de horario y estatus de apertura
class VenueScheduleStatus {
  final bool isOpenNow;
  final VenueBadgeType badgeType;
  final String badgeLabel; // 'Abierto', 'Abre Hoy', 'Cerrado', 'In Memoriam'
  final String detailedStatus; // 'Abierto ahora (Cierra 4:00 AM)', 'Abre hoy a las 8:00 PM', 'Cerrado hoy · Abre Jueves 19:00'
  final String? eventNote;

  const VenueScheduleStatus({
    required this.isOpenNow,
    required this.badgeType,
    required this.badgeLabel,
    required this.detailedStatus,
    this.eventNote,
  });
}

/// Evaluador en tiempo real para determinar el estado de apertura de los establecimientos.
/// Garantiza cero incongruencias: si el local tiene un evento programado para hoy, NUNCA
/// mostrará "Cerrado hoy", sino "Abre hoy a las [hora]" o "Abierto ahora".
class VenueScheduleEvaluator {
  static const List<String> _dayNames = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  /// Evalúa el estatus operativo del local en base al horario real y eventos de HOY
  static VenueScheduleStatus evaluate(VenueModel venue, {DateTime? referenceTime}) {
    final now = referenceTime ?? DateTime.now();

    // 1. Caso In Memoriam / Cerrado permanente
    if (venue.isPermanentlyClosed) {
      return VenueScheduleStatus(
        isOpenNow: false,
        badgeType: VenueBadgeType.permanentlyClosed,
        badgeLabel: 'In Memoriam',
        detailedStatus: venue.closedJokeNote ?? 'Cerrado permanentemente',
      );
    }

    // 2. Comprobar si existe un evento programado para HOY
    VenueEvent? todayEvent;
    for (final ev in venue.upcomingEvents) {
      if (ev.isToday) {
        todayEvent = ev;
        break;
      }
    }

    final scheduleRule = _getRuleForVenue(venue.id);
    final weekday = now.weekday; // 1 = Lunes, 7 = Domingo

    // Obtener las horas de apertura y cierre para hoy (o del evento)
    final isOperatingToday = scheduleRule.operatingDays.contains(weekday) || todayEvent != null;

    // Regla de Oro (Base Google Maps): Un evento nocturno (ej. set de DJ a las 9 PM o 10 PM)
    // NUNCA debe retrasar la hora de apertura base del establecimiento (ej. si abre a las 7:00 PM o 1:00 PM).
    // Solo permitimos que el evento modifique la hora de apertura si el evento inicia ANTES
    // del horario regular (ej. tardeada, sunset party o apertura especial anticipada).
    int openHour = scheduleRule.openHour;
    int openMinute = scheduleRule.openMinute;
    final closeHour = scheduleRule.closeHour;

    if (todayEvent?.eventDate != null) {
      final evH = todayEvent!.eventDate!.hour;
      final evM = todayEvent!.eventDate!.minute;
      if (evH < openHour || (evH == openHour && evM < openMinute)) {
        openHour = evH;
        openMinute = evM;
      }
    }

    if (isOperatingToday) {
      final currentTotalMinutes = now.hour * 60 + now.minute;
      final openTotalMinutes = openHour * 60 + openMinute;

      // La mayoría de los bares cierran en la madrugada del día siguiente (ej. 3:00 AM o 5:00 AM)
      bool isOpenNow = false;

      if (closeHour < openHour) {
        // Cierre después de medianoche (ej. abre 20:00 y cierra 04:00)
        final closeTotalMinutes = closeHour * 60;
        if (currentTotalMinutes >= openTotalMinutes || currentTotalMinutes < closeTotalMinutes) {
          isOpenNow = true;
        }
      } else {
        // Cierre en el mismo día (ej. 13:00 a 23:00)
        final closeTotalMinutes = closeHour * 60;
        if (currentTotalMinutes >= openTotalMinutes && currentTotalMinutes < closeTotalMinutes) {
          isOpenNow = true;
        }
      }

      if (isOpenNow) {
        final closeFormat = _formatHour(closeHour, 0);
        return VenueScheduleStatus(
          isOpenNow: true,
          badgeType: VenueBadgeType.open,
          badgeLabel: 'Abierto',
          detailedStatus: 'Abierto ahora · Cierra $closeFormat',
          eventNote: todayEvent != null ? 'Hoy: ${todayEvent.title}' : null,
        );
      } else {
        // Aún no abre hoy (o ya cerró en la madrugada de hoy y volverá a abrir hoy por la tarde/noche)
        final openFormat = _formatHour(openHour, openMinute);
        final eventSuffix = todayEvent != null ? ' · ${todayEvent.title}' : '';

        return VenueScheduleStatus(
          isOpenNow: false,
          badgeType: VenueBadgeType.openingToday,
          badgeLabel: 'Abre Hoy',
          detailedStatus: 'Abre hoy a las $openFormat$eventSuffix',
          eventNote: todayEvent != null ? 'Hoy: ${todayEvent.title}' : null,
        );
      }
    }

    // 3. Hoy NO es día de operación y NO hay evento hoy
    // Calcular el próximo día de apertura
    int daysUntilNext = 1;
    while (daysUntilNext <= 7) {
      final nextDay = (weekday + daysUntilNext - 1) % 7 + 1;
      if (scheduleRule.operatingDays.contains(nextDay)) {
        break;
      }
      daysUntilNext++;
    }

    final nextDayIndex = (weekday + daysUntilNext - 1) % 7;
    final nextDayName = _dayNames[nextDayIndex];
    final nextOpenHour = _formatHour(scheduleRule.openHour, scheduleRule.openMinute);

    return VenueScheduleStatus(
      isOpenNow: false,
      badgeType: VenueBadgeType.closedToday,
      badgeLabel: 'Cerrado',
      detailedStatus: 'Cerrado hoy · Abre $nextDayName $nextOpenHour',
    );
  }

  static String _formatHour(int hour, int minute) {
    final period = hour >= 12 && hour < 24 ? 'PM' : 'AM';
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    final mStr = minute == 0 ? '00' : minute.toString().padLeft(2, '0');
    if (minute == 0) {
      return '$h12:00 $period';
    }
    return '$h12:$mStr $period';
  }

  static _ScheduleRule _getRuleForVenue(String venueId) {
    final id = venueId.toLowerCase();

    // 1. Cervecerías de la Costa (10 sucursales en Colima): Base Google Maps es Lunes a Domingo de 11:00 AM a 11:00 PM (23:00 hrs)
    if (id.startsWith('costa_') || id.startsWith('costa-')) {
      return const _ScheduleRule(
        operatingDays: [
          DateTime.monday,
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
          DateTime.friday,
          DateTime.saturday,
          DateTime.sunday,
        ],
        openHour: 11,
        openMinute: 0,
        closeHour: 23,
      );
    }

    // 2. Cervecería Chapultepec (Diario 1:00 PM - 1:00 AM / 2:00 AM en Vie-Sáb)
    if (id == 'cerveceria_chapultepec') {
      return const _ScheduleRule(
        operatingDays: [
          DateTime.monday,
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
          DateTime.friday,
          DateTime.saturday,
          DateTime.sunday,
        ],
        openHour: 13,
        openMinute: 0,
        closeHour: 2,
      );
    }

    // 3. Cervecería Estación Colimita - Centro (Andador Madero): Martes a Domingo 1:00 PM a 12:00 AM (Lunes cerrado)
    if (id == 'colimita_centro') {
      return const _ScheduleRule(
        operatingDays: [
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
          DateTime.friday,
          DateTime.saturday,
          DateTime.sunday,
        ],
        openHour: 13,
        openMinute: 0,
        closeHour: 0,
      );
    }

    // 4. Cervecería Estación Colimita - Constitución: Lunes a Sábado 5:00 PM a 1:00 AM (Domingo cerrado)
    if (id == 'colimita_constitucion') {
      return const _ScheduleRule(
        operatingDays: [
          DateTime.monday,
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
          DateTime.friday,
          DateTime.saturday,
        ],
        openHour: 17,
        openMinute: 0,
        closeHour: 1,
      );
    }

    // 5. Bar La Puerta (Jueves: 7 PM - 3/4 AM con snacks & drinks; Vie-Sáb: 8 PM - 4 AM)
    if (id == 'la_puerta_bar' || id == 'bar_la_puerta') {
      return const _ScheduleRule(
        operatingDays: [DateTime.thursday, DateTime.friday, DateTime.saturday],
        openHour: 19,
        openMinute: 0,
        closeHour: 4,
      );
    }

    // 6. El Guachi / Rooftop (Jueves a Domingo: Rooftop 6 PM - 2 AM; Club: Vie-Sáb hasta 5:30 AM)
    if (id == 'el_guachi') {
      return const _ScheduleRule(
        operatingDays: [DateTime.thursday, DateTime.friday, DateTime.saturday, DateTime.sunday],
        openHour: 18,
        openMinute: 0,
        closeHour: 5,
      );
    }

    // 7. Dos Puntos Cervecería (Miércoles a Sábado 6 PM - 2 AM)
    if (id == 'dos_puntos') {
      return const _ScheduleRule(
        operatingDays: [DateTime.wednesday, DateTime.thursday, DateTime.friday, DateTime.saturday],
        openHour: 18,
        openMinute: 0,
        closeHour: 2,
      );
    }

    // 8. Low Social Club (Jueves a Sábado 10 PM - 5 AM)
    if (id == 'low_social_club') {
      return const _ScheduleRule(
        operatingDays: [DateTime.thursday, DateTime.friday, DateTime.saturday],
        openHour: 22,
        openMinute: 0,
        closeHour: 5,
      );
    }

    // 9. Foro DMT & DMT Rock Bar (Jueves a Sábado 8 PM - 3 AM)
    if (id == 'foro_dmt' || id == 'dmt_rock_bar') {
      return const _ScheduleRule(
        operatingDays: [DateTime.thursday, DateTime.friday, DateTime.saturday],
        openHour: 20,
        openMinute: 0,
        closeHour: 3,
      );
    }

    // 10. Almada Cantina Fina (Martes a Domingo 4:30 PM - 2:00 AM; Dom hasta 12:00 AM; Lunes cerrado)
    if (id == 'almada_cantina') {
      return const _ScheduleRule(
        operatingDays: [DateTime.tuesday, DateTime.wednesday, DateTime.thursday, DateTime.friday, DateTime.saturday, DateTime.sunday],
        openHour: 16,
        openMinute: 30,
        closeHour: 2,
      );
    }

    // 11. Santo Mezcal & Mezcalería Casa Colima (Miércoles/Jueves a Sábado 7 PM - 2 AM)
    if (id == 'mezcaleria_casa_colima') {
      return const _ScheduleRule(
        operatingDays: [DateTime.wednesday, DateTime.thursday, DateTime.friday, DateTime.saturday],
        openHour: 19,
        openMinute: 0,
        closeHour: 2,
      );
    }
    if (id == 'santo_mezcal') {
      return const _ScheduleRule(
        operatingDays: [DateTime.thursday, DateTime.friday, DateTime.saturday],
        openHour: 19,
        openMinute: 0,
        closeHour: 2,
      );
    }

    // 12. La Regional Cantina (Miércoles a Sábado 5 PM - 2 AM)
    if (id == 'la_regional') {
      return const _ScheduleRule(
        operatingDays: [DateTime.wednesday, DateTime.thursday, DateTime.friday, DateTime.saturday],
        openHour: 17,
        openMinute: 0,
        closeHour: 2,
      );
    }

    // 13. Los Toros Barra Taurina (Jueves a Sábado 3 PM - 1 AM)
    if (id == 'los_toros_barra_taurina') {
      return const _ScheduleRule(
        operatingDays: [DateTime.thursday, DateTime.friday, DateTime.saturday],
        openHour: 15,
        openMinute: 0,
        closeHour: 1,
      );
    }

    // 14. El Taurino Bar (Martes a Domingo 2 PM - 12 AM; Lunes cerrado)
    if (id == 'el_taurino') {
      return const _ScheduleRule(
        operatingDays: [DateTime.tuesday, DateTime.wednesday, DateTime.thursday, DateTime.friday, DateTime.saturday, DateTime.sunday],
        openHour: 14,
        openMinute: 0,
        closeHour: 0,
      );
    }

    // 15. El Gustito (Martes a Domingo 1 PM - 12 AM; Lunes cerrado)
    if (id == 'el_gustito') {
      return const _ScheduleRule(
        operatingDays: [DateTime.tuesday, DateTime.wednesday, DateTime.thursday, DateTime.friday, DateTime.saturday, DateTime.sunday],
        openHour: 13,
        openMinute: 0,
        closeHour: 0,
      );
    }

    // 16. La Chintola (Lunes a Domingo 12 PM - 11 PM)
    if (id == 'la_chintola') {
      return const _ScheduleRule(
        operatingDays: [
          DateTime.monday,
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
          DateTime.friday,
          DateTime.saturday,
          DateTime.sunday
        ],
        openHour: 12,
        openMinute: 0,
        closeHour: 23,
      );
    }

    // 17. Paraíso Drinks Colima (Miércoles a Domingo 7:30 PM - 2:30 AM)
    if (id == 'paraiso_drinks') {
      return const _ScheduleRule(
        operatingDays: [DateTime.wednesday, DateTime.thursday, DateTime.friday, DateTime.saturday, DateTime.sunday],
        openHour: 19,
        openMinute: 30,
        closeHour: 3,
      );
    }

    // Regla general para centros nocturnos de Colima: Jueves a Sábado 8 PM - 3 AM
    return const _ScheduleRule(
      operatingDays: [DateTime.thursday, DateTime.friday, DateTime.saturday],
      openHour: 20,
      openMinute: 0,
      closeHour: 3,
    );
  }
}

class _ScheduleRule {
  final List<int> operatingDays;
  final int openHour;
  final int openMinute;
  final int closeHour;

  const _ScheduleRule({
    required this.operatingDays,
    required this.openHour,
    this.openMinute = 0,
    required this.closeHour,
  });
}
