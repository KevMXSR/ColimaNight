import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../providers/venue_providers.dart';
import 'weekly_events_sheet.dart';

class FilterChipsBar extends ConsumerWidget {
  const FilterChipsBar({super.key});

  IconData _iconForFilter(VenueFilterChip filter) {
    switch (filter) {
      case VenueFilterChip.all:
        return Icons.explore_rounded;
      case VenueFilterChip.events:
        return Icons.event_available_rounded;
      case VenueFilterChip.liveMusic:
        return Icons.music_note_rounded;
      case VenueFilterChip.promos:
        return Icons.local_offer_rounded;
      case VenueFilterChip.parking:
        return Icons.local_parking_rounded;
      case VenueFilterChip.highCapacity:
        return Icons.local_fire_department_rounded;
      case VenueFilterChip.vip:
        return Icons.star_rounded;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilter = ref.watch(selectedFilterChipProvider);

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: VenueFilterChip.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = VenueFilterChip.values[index];
          final isSelected = filter == activeFilter;

          return GestureDetector(
            onTap: () {
              ref.read(selectedFilterChipProvider.notifier).state = filter;
              if (filter == VenueFilterChip.events) {
                WeeklyEventsSheet.show(context);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.neonViolet.withOpacity(0.3)
                    : AppColors.surfaceElevated.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? AppColors.neonCyan
                      : AppColors.glassBorder,
                  width: isSelected ? 1.4 : 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.neonCyan.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 0.5,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    _iconForFilter(filter),
                    size: 15,
                    color: isSelected ? AppColors.neonCyan : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    filter.label,
                    style: AppTypography.badgeLabel.copyWith(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
