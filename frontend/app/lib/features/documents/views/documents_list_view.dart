import 'package:flutter/material.dart';
import '../../../core/design_system.dart';
import '../../../core/api_client.dart';
import '../../../widgets/obsidian_card.dart';
import '../../../widgets/category_badge.dart';
import '../../chat/chat_screen.dart';

class DocumentsListView extends StatelessWidget {
  final List<DocRecord> docs;
  final Future<void> Function(String) onDelete;

  const DocumentsListView({
    super.key,
    required this.docs,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      itemCount: docs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final doc = docs[index];
        return ObsidianCard(
          padding: const EdgeInsets.all(20),
          showBorder: true,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                docId: doc.docId,
                docName: doc.filename,
                category: doc.category,
                isImageDoc: doc.isImageDoc,
              ),
            ),
          ),
          child: Row(
            children: [
              _DocTypeIcon(isImage: doc.isImageDoc),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.filename.toUpperCase(),
                      style: ObsidianTypography.technicalLabel.copyWith(
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ADDED ${_formatDate(doc.createdAt)}',
                      style: ObsidianTypography.labelSmall,
                    ),
                    const SizedBox(height: 8),
                    CategoryBadge(
                      category: doc.category,
                      large: false,
                      animate: false,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: ObsidianColors.onSurfaceVariant,
                ),
                onPressed: () => _confirmDelete(context, doc),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  void _confirmDelete(BuildContext context, DocRecord doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ObsidianColors.surfaceContainerLowest,
        title: Text(
          'DELETE DOCUMENT?',
          style: ObsidianTypography.technicalLabel,
        ),
        content: Text(
          'THIS ACTION CANNOT BE UNDONE.',
          style: ObsidianTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: ObsidianTypography.technicalLabel),
          ),
          TextButton(
            onPressed: () {
              onDelete(doc.docId);
              Navigator.pop(ctx);
            },
            child: Text(
              'DELETE',
              style: ObsidianTypography.technicalLabel.copyWith(
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DocTypeIcon extends StatelessWidget {
  final bool isImage;
  const _DocTypeIcon({required this.isImage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: ObsidianColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(ObsidianShapes.radiusMD),
      ),
      child: Icon(
        isImage ? Icons.image_outlined : Icons.description_outlined,
        size: 24,
        color: ObsidianColors.primary,
      ),
    );
  }
}
