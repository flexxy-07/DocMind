import 'package:app/core/api_client.dart';
import 'package:app/core/theme.dart';
import 'package:flutter/material.dart';

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
        const Row(
          children: [
            Icon(
              Icons.format_quote_rounded,
              size: 12,
              color: AppColors.textHint,
            ),
            SizedBox(width: 4),
            Text(
              'Sources',
              style: const TextStyle(fontSize: 11, color: AppColors.textHint),
            ),
          ],
        ),
        SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(widget.sources.length, (i) {
            return _SourceChip(
              source: widget.sources[i],
              index: i,
              isExanded: _expanded == i,
              onTap: () => setState(() {
                _expanded = _expanded == i ? -1 : i;
              }),
            );
          }),
        ),
        if (_expanded >= 0 && _expanded < widget.sources.length)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _ExpandedPassage(source: widget.sources[_expanded])
                .animate()
                .fade(duration: 200.ms)
                .slideY(
                  begin: -0.05,
                  end: 0,
                  duration: 200.ms,
                  curve: Curves.easeOut,
                ),
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
 
    final Color chipColor;
    if (matchPct >= 80) {
      chipColor = AppColors.primary;
    } else if (matchPct >= 60) {
      chipColor = AppColors.secondary;
    } else {
      chipColor = AppColors.textHint;
    }
 
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isExpanded
              ? chipColor.withOpacity(0.15)
              : AppColors.bgElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isExpanded
                ? chipColor.withOpacity(0.5)
                : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.article_outlined,
              size:  11,
              color: isExpanded ? chipColor : AppColors.textHint,
            ),
            const SizedBox(width: 4),
            Text(
              source.page != null
                  ? 'S${index + 1} · p${source.page}'
                  : 'S${index + 1}',
              style: TextStyle(
                fontSize:   11,
                fontWeight: FontWeight.w500,
                color: isExpanded ? chipColor : AppColors.textSecond,
              ),
            ),
            const SizedBox(width: 4),
            // Match percentage badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color:        chipColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$matchPct%',
                style: TextStyle(
                  fontSize:   9,
                  fontWeight: FontWeight.w700,
                  color:      chipColor,
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:        AppColors.primaryGlow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header — filename and page
          Row(
            children: [
             const Icon(
                Icons.description_outlined,
                size:  12,
                color: AppColors.primary,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  source.page != null
                      ? '${source.filename} · Page ${source.page}'
                      : source.filename,
                  style: const TextStyle(
                    fontSize:   11,
                    fontWeight: FontWeight.w600,
                    color:      AppColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 8),
 
          
          Text(
            source.text,
            style: const TextStyle(
              fontSize: 12,
              color:    AppColors.textSecond,
              height:   1.6,
            ),
            maxLines:  8,
            overflow:  TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}