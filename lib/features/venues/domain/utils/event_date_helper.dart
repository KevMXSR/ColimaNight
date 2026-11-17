/// Utilidades para el cálculo, formateo y control de vigencia estricta de eventos en tiempo real
class EventDateHelper {
  static const List<String> _dayNames = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  static const List<String> _monthNames = [
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Oct',
    'Nov',
    'Dic',
  ];

  /// Calcula la fecha de la próxima ocurrencia de un día de la semana.
  /// Por defecto [allowAutoRollover] es false para evitar que eventos pasados
  /// se sigan reprogramando indefinidamente semana tras semana.
  static DateTime getUpcomingWeekday(
    int targetWeekday, {
    int hour = 22,
    int minute = 0,
    DateTime? referenceDate,
    bool allowAutoRollover = false,
  }) {
    final now = referenceDate ?? DateTime.now();
    int difference = targetWeekday - now.weekday;

    // Si el día ya concluyó en la semana y allowAutoRollover es true,
    // se traslada a la próxima semana; de lo contrario, se mantiene en la semana actual.
    if (difference < 0 && allowAutoRollover) {
      difference += 7;
    }

    return DateTime(
      now.year,
      now.month,
      now.day + difference,
      hour,
      minute,
    );
  }

  /// Formatea un objeto [DateTime] al estilo cinematográfico de Colima Night:
  /// Ejemplo: 'Viernes 6 Nov • 10:30 PM'
  static String formatEventDate(DateTime dt) {
    final dayName = _dayNames[dt.weekday - 1];
    final monthName = _monthNames[dt.month - 1];
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final hour12 = dt.hour == 0
        ? 12
        : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minuteStr = dt.minute.toString().padLeft(2, '0');

    return '$dayName ${dt.day} $monthName • $hour12:$minuteStr $period';
  }

  /// Verifica si una fecha dada corresponde al día de hoy en tiempo real
  static bool isToday(DateTime dt, {DateTime? referenceDate}) {
    final now = referenceDate ?? DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  /// Calcula la fecha y hora de expiración predeterminada (06:00 AM del día siguiente)
  static DateTime calculateDefaultExpiration(DateTime eventDate) {
    return DateTime(
      eventDate.year,
      eventDate.month,
      eventDate.day + 1,
      6,
      0,
    );
  }

  /// Valida si un evento sigue vigente y no ha concluido su ciclo operativo nocturno.
  /// Los eventos concluyen a las 06:00 AM del día posterior a su fecha programada.
  static bool isEventActive(DateTime? eventDate, {DateTime? expiresAt, DateTime? referenceDate}) {
    if (eventDate == null) return false;
    final now = referenceDate ?? DateTime.now();

    if (expiresAt != null) {
      return now.isBefore(expiresAt);
    }

    // Corte a las 06:00 AM del día siguiente
    final cutoffTime = DateTime(
      eventDate.year,
      eventDate.month,
      eventDate.day + 1,
      6,
      0,
    );

    return now.isBefore(cutoffTime);
  }
}
