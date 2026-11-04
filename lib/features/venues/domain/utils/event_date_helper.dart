/// Utilidades para el cálculo y formateo de fechas de eventos en tiempo real
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

  /// Calcula la fecha de la próxima ocurrencia de un día de la semana para la semana activa.
  /// Si hoy es el mismo día y la hora aún no concluye, retorna el día de hoy.
  static DateTime getUpcomingWeekday(
    int targetWeekday, {
    int hour = 22,
    int minute = 0,
    DateTime? referenceDate,
  }) {
    final now = referenceDate ?? DateTime.now();
    int difference = targetWeekday - now.weekday;

    // Si el día ya pasó en la semana actual (ej. hoy es domingo y el evento era viernes),
    // se programa para la siguiente semana
    if (difference < 0) {
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
}
