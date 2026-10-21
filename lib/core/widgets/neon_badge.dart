import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum BadgeType {
  capacity,
  livePresence,
  liveMusic,
  vip,
  promo,
  parking,
  custom,
}

class NeonBadge extends StatelessWidget {
  final String label;
  final BadgeType type;
  final IconData? icon;
  final Color? customColor;
  final int? capacityPercent;

  const NeonBadge({
    super.key,
    required this.label,
    this.type = BadgeType.custom,
    this.icon,
    this.customColor,
    this.capacityPercent,
  });

  factory NeonBadge.capacity(int percent) {
    return NeonBadge(
      label: 'Aforo $percent%',
      type: BadgeType.capacity,
      capacityPercent: percent,
      icon: Icons.people_alt_rounded,
    );
  }

  factory NeonBadge.livePresence(int count, {bool showRadius = false}) {
    return NeonBadge(
      label: showRadius ? '$count en vivo (80m)' : '$count en vivo',
      type: BadgeType.livePresence,
      icon: Icons.sensors_rounded,
      customColor: AppColors.neonCyan,
    );
  }

  factory NeonBadge.liveMusic([String text = 'Banda en vivo']) {
    return NeonBadge(
      label: text,
      type: BadgeType.liveMusic,
      icon: Icons.music_note_rounded,
    );
  }

  factory NeonBadge.vip([String text = 'VIP / Host Presente']) {
    return NeonBadge(
      label: text,
      type: BadgeType.vip,
      icon: Icons.star_rounded,
    );
  }

  factory NeonBadge.promo([String text = 'Promo 2x1']) {
    return NeonBadge(
      label: text,
      type: BadgeType.promo,
      icon: Icons.local_fire_department_rounded,
    );
  }

  factory NeonBadge.parking([String text = 'Valet / Parking']) {
    return NeonBadge(
      label: text,
      type: BadgeType.parking,
      icon: Icons.local_parking_rounded,
    );
  }

  Color get _resolvedColor {
    if (customColor != null) return customColor!;
    switch (type) {
      case BadgeType.capacity:
        final cap = capacityPercent ?? 75;
        if (cap >= 85) return AppColors.neonRedAlert;
        if (cap >= 65) return AppColors.neonAmber;
        return AppColors.neonGreen;
      case BadgeType.livePresence:
        return AppColors.neonCyan;
      case BadgeType.liveMusic:
        return AppColors.neonMagenta;
      case BadgeType.vip:
        return AppColors.neonAmber;
      case BadgeType.promo:
        return AppColors.neonCyan;
      case BadgeType.parking:
        return const Color(0xFF4D96FF);
      case BadgeType.custom:
        return AppColors.neonCyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _resolvedColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: color.withOpacity(0.6),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.25),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (type == BadgeType.capacity || type == BadgeType.livePresence) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color,
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
          ],
          if (icon != null && type != BadgeType.capacity) ...[
            Icon(
              icon,
              size: 13,
              color: color,
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label.toUpperCase(),
            style: AppTypography.badgeLabel.copyWith(
              color: color,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
