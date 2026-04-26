import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system.dart';
import '../../../widgets/obsidian_card.dart';
import '../../../providers/docs_provider.dart';

class UploadIdleView extends ConsumerWidget {
  final VoidCallback onPick;

  const UploadIdleView({super.key, required this.onPick});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(docsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Text(
          'DOCMIND',
          style: ObsidianTypography.displayLarge,
        ).animate().fade(duration: 600.ms).slideY(begin: -0.1, end: 0),
        
        Text(
          'Intelligence of the archive.',
          style: ObsidianTypography.bodyMedium.copyWith(
            color: ObsidianColors.onSurfaceVariant,
          ),
        ).animate(delay: 100.ms).fade(),

        const SizedBox(height: 48),

        // Main Upload Card
        ObsidianCard(
          onTap: onPick,
          padding: const EdgeInsets.symmetric(vertical: 64),
          child: Center(
            child: Column(
              children: [
                const Icon(
                  Icons.add_rounded,
                  size: 48,
                  color: ObsidianColors.primary,
                ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                    duration: 2000.ms,
                  ),
                const SizedBox(height: 16),
                Text(
                  'TAP TO INGEST DOCUMENT',
                  style: ObsidianTypography.technicalLabel,
                ),
                const SizedBox(height: 4),
                Text(
                  'PDF, IMAGE, OR TEXT (MAX 20MB)',
                  style: ObsidianTypography.labelSmall,
                ),
              ],
            ),
          ),
        ).animate(delay: 200.ms).fade().scale(begin: const Offset(0.98, 0.98)),

        const SizedBox(height: 48),
        
        Text(
          'RECENT INTELLIGENCE',
          style: ObsidianTypography.technicalLabel.copyWith(
            color: ObsidianColors.onSurfaceVariant,
          ),
        ).animate(delay: 400.ms).fade(),
        
        const SizedBox(height: 16),
        
        Expanded(
          child: docsAsync.when(
            data: (docs) {
              if (docs.isEmpty) {
                return Center(
                  child: Text(
                    'No documents found.',
                    style: ObsidianTypography.bodyMedium,
                  ),
                );
              }
              return ListView.separated(
                itemCount: docs.length > 3 ? 3 : docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  return ObsidianCard(
                    padding: const EdgeInsets.all(16),
                    showBorder: true,
                    onTap: () {
                      // Navigate to chat for this doc
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.description_outlined, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doc.filename,
                                style: ObsidianTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    doc.category.toUpperCase(),
                                    style: ObsidianTypography.labelSmall,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'CONFIDENCE: 98%', // Mocked for design
                                    style: ObsidianTypography.labelSmall.copyWith(
                                      color: ObsidianColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error loading documents.')),
          ),
        ).animate(delay: 500.ms).fade(),
      ],
    );
  }
}
