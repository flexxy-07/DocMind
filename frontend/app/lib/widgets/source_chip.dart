import 'package:app/core/api_client.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import '../core/design_system.dart';
import 'obsidian_card.dart';

class SourceChipRow extends StatefulWidget {
  final List<SourceChunk> sources;

  const SourceChipRow({super.key, required this.sources});

  @override
  State<SourceChipRow> createState() => _SourceChipRowState();
}

class _SourceChipRowState extends State<SourceChipRow> {
  int _expanded = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.hub_outlined, size: 12, color: ObsidianColors.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              'INTELLIGENCE SOURCES',
              style: ObsidianTypography.labelSmall,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(widget.sources.length, (i) {
            return _SourceChip(
              source: widget.sources[i],
              index: i,
              isExpanded: _expanded == i,
              onTap: () => setState(() {
                _expanded = _expanded == i ? -1 : i;
              }),
            );
          }),
        ),
        if (_expanded >= 0 && _expanded < widget.sources.length)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: _ExpandedPassage(source: widget.sources[_expanded])
                .animate()
                .fade(duration: 200.ms)
                .slideY(begin: -0.05, end: 0),
          ),
      ],
    );
  }
}

class _SourceChip extends StatelessWidget {
  final SourceChunk source;
  final int index;
  final bool isExpanded;
  final VoidCallback onTap;

  const _SourceChip({
    required this.source,
    required this.index,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final matchPct = (source.score * 100).toInt();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isExpanded ? ObsidianColors.primary : ObsidianColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(ObsidianShapes.radiusXS),
          border: Border.all(
            color: isExpanded ? ObsidianColors.primary : ObsidianColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'S${index + 1}',
              style: ObsidianTypography.technicalLabel.copyWith(
                fontSize: 10,
                color: isExpanded ? ObsidianColors.onPrimary : ObsidianColors.primary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: isExpanded ? ObsidianColors.onPrimary.withOpacity(0.2) : ObsidianColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                '$matchPct%',
                style: ObsidianTypography.technicalLabel.copyWith(
                  fontSize: 9,
                  color: isExpanded ? ObsidianColors.onPrimary : ObsidianColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpandedPassage extends StatelessWidget {
  final SourceChunk source;

  const _ExpandedPassage({required this.source});

  @override
  Widget build(BuildContext context) {
    return ObsidianCard(
      padding: const EdgeInsets.all(16),
      color: ObsidianColors.surfaceContainerLowest,
      showBorder: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_outlined, size: 14, color: ObsidianColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  (source.page != null ? '${source.filename} · P${source.page}' : source.filename).toUpperCase(),
                  style: ObsidianTypography.technicalLabel.copyWith(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            source.text,
            style: ObsidianTypography.bodyMedium.copyWith(height: 1.6),
            maxLines: 8,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}