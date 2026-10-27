import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/venue_providers.dart';
import 'venue_detail_bottom_sheet.dart';

class WeeklyEventsSheet extends ConsumerWidget {
  const WeeklyEventsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const WeeklyEventsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventItems = ref.watch(weeklyEventsProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.glassBorder, width: 1.5),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.neonViolet.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.neonViolet.withOpacity(0.4)),
                      ),
                      child: const Icon(Icons.event_available_rounded, color: AppColors.neonViolet, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CARTELERA DE LA SEMANA',
                          style: AppTypography.h3.copyWith(
                            fontSize: 15,
                            letterSpacing: 0.8,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Eventos verificados en Colima y La Villa',
                          style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.glassBorder, height: 24),

          // Event List
          Expanded(
            child: eventItems.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.event_busy_rounded, size: 48, color: AppColors.textMuted.withOpacity(0.5)),
                          const SizedBox(height: 12),
                          Text(
                            'Sin eventos programados hoy',
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Los eventos se actualizan de acuerdo con las carteleras oficiales de cada establecimiento.',
                            textAlign: TextAlign.center,
                            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: eventItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = eventItems[index];
                      final event = item.event;
                      final venue = item.venue;

                      return Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: event.isToday
                                ? AppColors.neonViolet.withOpacity(0.6)
                                : AppColors.glassBorder,
                            width: event.isToday ? 1.4 : 1.0,
                          ),
                          boxShadow: event.isToday
                              ? [
                                  BoxShadow(
                                    color: AppColors.neonViolet.withOpacity(0.2),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              ref.read(selectedVenueProvider.notifier).state = venue;
                              Navigator.pop(context);
                              VenueDetailBottomSheet.show(context, venue);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Badge de Fecha y Estado
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: event.isToday
                                              ? AppColors.neonViolet
                                              : AppColors.surface,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: event.isToday
                                                ? AppColors.neonViolet
                                                : AppColors.glassBorder,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              event.isToday
                                                  ? Icons.bolt_rounded
                                                  : Icons.calendar_today_rounded,
                                              size: 11,
                                              color: event.isToday
                                                  ? Colors.white
                                                  : AppColors.neonCyan,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              event.isToday ? 'HOY EN VIVO' : event.dateDisplay,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: event.isToday
                                                    ? Colors.white
                                                    : AppColors.neonCyan,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (event.coverPrice != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.neonAmber.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: AppColors.neonAmber.withOpacity(0.35)),
                                          ),
                                          child: Text(
                                            event.coverPrice!,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.neonAmber,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // Título del Evento
                                  Text(
                                    event.title,
                                    style: AppTypography.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (event.artistOrDj != null) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.music_note_rounded, size: 13, color: AppColors.neonViolet),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            event.artistOrDj!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 10),

                                  // Lugar Sede y Botón
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.25),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              const Icon(Icons.location_on_rounded, size: 14, color: AppColors.neonCyan),
                                              const SizedBox(width: 5),
                                              Expanded(
                                                child: Text(
                                                  '${venue.name} • ${venue.category}',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Ver lugar',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.neonCyan,
                                              ),
                                            ),
                                            Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.neonCyan),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
