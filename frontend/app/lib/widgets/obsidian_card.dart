import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/design_system.dart';

class ObsidianCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool showBorder;

  const ObsidianCard({
    super.key,
    required this.child,
    this.borderRadius = ObsidianShapes.radiusLG,
    this.blur = 20.0,
    this.color,
    this.padding = const EdgeInsets.all(24),
    this.onTap,
    this.showBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? ObsidianColors.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder 
            ? Border.all(color: ObsidianColors.border, width: 1) 
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: content,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: content,
      ),
    );
  }
}
