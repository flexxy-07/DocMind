import 'package:app/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/design_system.dart';

class CategoryBadge extends StatelessWidget {
  final String category;
  final bool large;
  final bool animate;

  const CategoryBadge({
    super.key,
    required this.category,
    required this.large,
    required this.animate,
  });

  @override
  Widget build(BuildContext context) {
    final meta = AppConstants.categoryMeta(category);
    // Use categorical colors for badges but keep them technical
    final color = Color(meta.color).withOpacity(0.8);

    Widget badge = Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 12 : 8,
        vertical: large ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ObsidianShapes.radiusXS),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        meta.label.toUpperCase(),
        style: ObsidianTypography.labelSmall.copyWith(
          color: color,
          fontSize: large ? 12 : 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );

    if (animate) {
      badge = badge.animate().fade(duration: 400.ms).slideX(begin: 0.1, end: 0);
    }
    return badge;
  }
}
