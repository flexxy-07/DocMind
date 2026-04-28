import 'package:flutter/material.dart';
import '../core/design_system.dart';

class GlassInput extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool isPassword;
  final ValueChanged<String>? onSubmitted;
  final TextInputType keyboardType;

  const GlassInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.onSubmitted,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<GlassInput> createState() => _GlassInputState();
}

class _GlassInputState extends State<GlassInput> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: ObsidianColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(ObsidianShapes.radiusMD),
          ),
          child: Focus(
            onFocusChange: (focused) => setState(() => _isFocused = focused),
            child: TextField(
              controller: widget.controller,
              obscureText: widget.isPassword,
              onSubmitted: widget.onSubmitted,
              keyboardType: widget.keyboardType,
              style: ObsidianTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: ObsidianTypography.bodyMedium.copyWith(
                  color: ObsidianColors.onSurfaceVariant,
                ),
                prefixIcon: widget.prefixIcon != null 
                    ? Icon(widget.prefixIcon, size: 20, color: ObsidianColors.onSurfaceVariant)
                    : null,
                suffixIcon: widget.suffixIcon,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
        ),
        // Focus indicator (The "Engraved" line)
        LayoutBuilder(
          builder: (context, constraints) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _isFocused ? constraints.maxWidth : 0,
              color: ObsidianColors.primary,
            );
          },
        ),
      ],
    );
  }
}
