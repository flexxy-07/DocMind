import 'package:flutter/material.dart';
import '../core/design_system.dart';

class TechnicalButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool isLoading;
  final bool isPrimary;
  final double? width;

  const TechnicalButton({
    super.key,
    required this.label,
    this.onTap,
    this.icon,
    this.isLoading = false,
    this.isPrimary = true,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isPrimary 
        ? ObsidianColors.primary 
        : ObsidianColors.surfaceContainerHigh;
    final foregroundColor = isPrimary 
        ? ObsidianColors.onPrimary 
        : ObsidianColors.primary;

    return SizedBox(
      width: width,
      height: 52,
      child: TextButton(
        onPressed: isLoading ? null : onTap,
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ObsidianShapes.radiusSM),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: foregroundColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label.toUpperCase(),
                    style: ObsidianTypography.technicalLabel.copyWith(
                      color: foregroundColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
