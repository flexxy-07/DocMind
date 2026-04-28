import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/design_system.dart';
import '../../../widgets/technical_button.dart';

class UploadErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const UploadErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
          Icons.warning_amber_rounded,
          color: ObsidianColors.accent,
          size: 64,
        ).animate().shake(duration: 500.ms, hz: 4),

        const SizedBox(height: 24),

        Text(
          'INGESTION FAILED',
          style: ObsidianTypography.technicalLabel.copyWith(fontSize: 18),
        ),

        const SizedBox(height: 12),

        Text(
          message.toUpperCase(),
          style: ObsidianTypography.bodyMedium.copyWith(
            color: ObsidianColors.onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 48),

        TechnicalButton(
          label: 'RETRY',
          onTap: onRetry,
          width: 200,
        ),
      ],
    ).animate().fade(),
    );
  }
}
