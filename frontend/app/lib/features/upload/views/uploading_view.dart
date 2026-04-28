import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/design_system.dart';
import '../../../providers/upload_provider.dart';

class UploadingView extends StatelessWidget {
  final UploadUploading state;

  const UploadingView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Machined Processing Indicator
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                value: state.progress < 1.0 ? state.progress : null,
                strokeWidth: 2,
                color: ObsidianColors.primary,
                backgroundColor: ObsidianColors.surfaceContainerHigh,
              ),
            ),
            const Icon(
              Icons.bolt_rounded,
              size: 40,
              color: ObsidianColors.primary,
            ).animate(onPlay: (c) => c.repeat()).rotate(duration: 2000.ms),
          ],
        ),

        const SizedBox(height: 48),

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            state.phase.toUpperCase(),
            key: ValueKey(state.phase),
            style: ObsidianTypography.technicalLabel.copyWith(
              fontSize: 16,
              letterSpacing: 2.0,
            ),
          ),
        ),

        const SizedBox(height: 12),

        Text(
          '${(state.progress * 100).toInt()}% READY',
          style: ObsidianTypography.bodyMedium.copyWith(
            color: ObsidianColors.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 48),

        Text(
          state.progress < 1.0
              ? 'TRANSFERRING DATA TO ARCHIVE'
              : 'DECODING',
          style: ObsidianTypography.labelSmall.copyWith(
            letterSpacing: 1.0,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ).animate().fade(),
    );
  }
}
