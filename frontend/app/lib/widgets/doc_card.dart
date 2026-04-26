import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/api_client.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import 'category_badge.dart';




class DocCard extends StatelessWidget {
  final DocRecord doc;
  final int index;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final bool isSelected;
  final VoidCallback? onSelect;

  const DocCard({
    super.key,
    required this.doc,
    required this.onTap,
    this.index = 0,
    this.onDelete,
    this.isSelected = false,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Animate(
      
      effects: [
        FadeEffect(
          delay:    Duration(milliseconds: index * 50),
          duration: 300.ms,
        ),
        SlideEffect(
          begin:    const Offset(0, 0.06),
          end:      Offset.zero,
          delay:    Duration(milliseconds: index * 50),
          duration: 300.ms,
          curve:    Curves.easeOut,
        ),
      ],
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    final categoryColor = Color(AppConstants.categoryMeta(doc.category).color);

    return GestureDetector(
      onTap:      onTap,
      onLongPress: onSelect,  // long press enters multi-select mode
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          // When selected highlight
          color: isSelected
              ? AppColors.primaryGlow
              : AppColors.glass,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.glassBorder,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color:      Colors.black.withOpacity(0.25),
              blurRadius: 12,
              offset:     const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
           
            _FileIcon(
              isImageDoc:     doc.isImageDoc,
              categoryColor:  categoryColor,
            ),
            const SizedBox(width: 12),
            // info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filename
                  Text(
                    doc.filename,
                    style: const TextStyle(
                      fontSize:   14,
                      fontWeight: FontWeight.w600,
                      color:      AppColors.textPrimary,
                    ),
                    maxLines:  1,
                    overflow:  TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),

                  // category badge + meta info
                  Row(
                    children: [
                      CategoryBadge(category: doc.category, large: true, animate: true),
                      const SizedBox(width: 8),
                      Text(
                        doc.isImageDoc
                            ? 'Image · ${doc.pageCount}p'
                            : '${doc.chunkCount} chunks · ${doc.pageCount}p',
                        style: const TextStyle(
                          fontSize: 11,
                          color:    AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Right side actions 
            if (isSelected)
              // Checkmark when in multi-select mode
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  color:  AppColors.primary,
                  shape:  BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size:  14,
                  color: Colors.white,
                ),
              )
            else ...[
              
              if (onDelete != null)
                _DeleteButton(onDelete: onDelete!),
              const SizedBox(width: 4),
              // Chevron
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textHint,
                size:  20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}



class _FileIcon extends StatelessWidget {
  final bool isImageDoc;
  final Color categoryColor;

  const _FileIcon({
    required this.isImageDoc,
    required this.categoryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46, height: 46,
      decoration: BoxDecoration(
        color:        categoryColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: categoryColor.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          isImageDoc ? '🖼️' : '📄',
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}




class _DeleteButton extends StatelessWidget {
  final VoidCallback onDelete;

  const _DeleteButton({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _confirm(context),
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color:        AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          size:  16,
          color: AppColors.error,
        ),
      ),
    );
  }

  void _confirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text(
          'Delete document?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'This removes the document and all its indexed chunks. '
          'This cannot be undone.',
          style: TextStyle(color: AppColors.textSecond),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecond),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color:      AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}




class DocCardShimmer extends StatelessWidget {
  final int count;

  const DocCardShimmer({super.key, this.count = 5});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _ShimmerCard()
              .animate(onPlay: (c) => c.repeat())
              .shimmer(
                duration: 1200.ms,
                delay:    Duration(milliseconds: i * 100),
                color:    AppColors.bgElevated,
              ),
        ),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      decoration: BoxDecoration(
        color:        AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // File icon placeholder
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color:        AppColors.bgElevated,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          // Text placeholders
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment:  MainAxisAlignment.center,
              children: [
                Container(
                  height: 14, width: double.infinity,
                  decoration: BoxDecoration(
                    color:        AppColors.bgElevated,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 11, width: 140,
                  decoration: BoxDecoration(
                    color:        AppColors.bgElevated,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}