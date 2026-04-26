import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/design_system.dart';
import '../../../core/api_client.dart';
import '../../../widgets/obsidian_card.dart';
import '../../../widgets/technical_button.dart';
import '../../../widgets/category_badge.dart';
import '../../chat/chat_screen.dart';

class UploadDoneView extends StatelessWidget {
  final IngestResult result;
  final VoidCallback onReset;

  const UploadDoneView({super.key, required this.result, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.verified_rounded,
          color: ObsidianColors.primary,
          size: 64,
        ).animate().scale(
              begin: const Offset(0, 0),
              end: const Offset(1, 1),
              duration: 500.ms,
              curve: Curves.elasticOut,
            ),

        const SizedBox(height: 24),

        Text(
          'INTELLIGENCE EXTRACTED',
          style: ObsidianTypography.technicalLabel.copyWith(fontSize: 18),
        ).animate(delay: 200.ms).fade().slideY(begin: 0.1, end: 0),

        const SizedBox(height: 8),

        Text(
          result.filename,
          style: ObsidianTypography.bodyMedium.copyWith(
            color: ObsidianColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ).animate(delay: 300.ms).fade(),

        const SizedBox(height: 32),

        CategoryBadge(
          category: result.category,
          large: true,
          animate: true,
        ),

        const SizedBox(height: 48),

        ObsidianCard(
          padding: const EdgeInsets.all(20),
          showBorder: true,
          child: Column(
            children: [
              _StatRow('PAGES', '${result.pageCount}'),
              const Divider(height: 24),
              _StatRow('CHUNKS', '${result.chunkCount}'),
              const Divider(height: 24),
              _StatRow('CONFIDENCE', result.categoryConfidence.toUpperCase()),
            ],
          ),
        ).animate(delay: 500.ms).fade().slideY(begin: 0.05, end: 0),

        const SizedBox(height: 48),

        Row(
          children: [
            Expanded(
              child: TechnicalButton(
                label: 'RESET',
                isPrimary: false,
                onTap: onReset,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TechnicalButton(
                label: 'BEGIN QUERY',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      docId: result.docId,
                      docName: result.filename,
                      category: result.category,
                      isImageDoc: result.isImageDoc,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ).animate(delay: 700.ms).fade(),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: ObsidianTypography.labelSmall.copyWith(
            color: ObsidianColors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: ObsidianTypography.technicalLabel,
        ),
      ],
    );
  }
}
