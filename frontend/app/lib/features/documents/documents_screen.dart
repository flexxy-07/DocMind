import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/api_client.dart';
import '../../providers/docs_provider.dart';
import '../../widgets/doc_card.dart';
import '../chat/chat_screen.dart';


class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  final _searchController = TextEditingController();
  bool _multiSelectMode   = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  void _enterMultiSelect(String firstDocId) {
    setState(() => _multiSelectMode = true);
    ref.read(selectedDocsProvider.notifier).toggle(firstDocId);
  }

  void _exitMultiSelect() {
    setState(() => _multiSelectMode = false);
    ref.read(selectedDocsProvider.notifier).clearAll();
  }

  void _openMultiDocChat(List<DocRecord> allDocs) {
    final selectedIds = ref.read(selectedDocsProvider);
    final selected    = allDocs.where((d) => selectedIds.contains(d.docId)).toList();

    if (selected.isEmpty) return;

    _exitMultiSelect();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          docIds:   selected.map((d) => d.docId).toList(),
          docNames: selected.map((d) => d.filename).toList(),
        ),
      ),
    );
  }


  Future<void> _deleteDoc(String docId) async {
    try {
      await ApiClient().deleteDocument(docId);
      // Invalidate 
      ref.invalidate(docsProvider);
      ref.invalidate(statsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync  = ref.watch(filteredDocsProvider);
    final selectedIds    = ref.watch(selectedDocsProvider);
    final allDocsAsync   = ref.watch(docsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _buildHeader(selectedIds, allDocsAsync.valueOrNull ?? []),

            if (!_multiSelectMode)
              _StatsStrip(),

            if (!_multiSelectMode)
              _SearchBar(
                controller: _searchController,
                onChanged: (q) =>
                    ref.read(searchQueryProvider.notifier).state = q,
              ),

            const SizedBox(height: 8),

            Expanded(
              child: filteredAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child:   DocCardShimmer(count: 6),
                ),
                error: (e, _) => _ErrorState(
                  message:  e.toString(),
                  onRetry:  () => ref.invalidate(docsProvider),
                ),
                data: (docs) => docs.isEmpty
                    ? _EmptyState(
                        hasSearch: _searchController.text.isNotEmpty,
                        onClear:   () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      )
                    : RefreshIndicator(
                        color:    AppColors.primary,
                        onRefresh: () async {
                          ref.invalidate(docsProvider);
                          ref.invalidate(statsProvider);
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                          itemCount:   docs.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) => DocCard(
                            doc:        docs[i],
                            index:      i,
                            isSelected: selectedIds.contains(docs[i].docId),
                            onTap: _multiSelectMode
                                // In multi-select: tap toggles selection
                                ? () => ref
                                    .read(selectedDocsProvider.notifier)
                                    .toggle(docs[i].docId)
                                // Normal: tap opens chat
                                : () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChatScreen(
                                          docId:    docs[i].docId,
                                          docName:  docs[i].filename,
                                          category: docs[i].category,
                                          isImageDoc: docs[i].isImageDoc,
                                        ),
                                      ),
                                    ),
                            onSelect: !_multiSelectMode
                                ? () => _enterMultiSelect(docs[i].docId)
                                : null,
                            onDelete: !_multiSelectMode
                                ? () => _deleteDoc(docs[i].docId)
                                : null,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: _multiSelectMode
          ? _MultiSelectBar(
              count:       selectedIds.length,
              allDocs:     allDocsAsync.valueOrNull ?? [],
              onCancel:    _exitMultiSelect,
              onChat:      () => _openMultiDocChat(
                               allDocsAsync.valueOrNull ?? []),
            )
          : null,
    );
  }

  Widget _buildHeader(Set<String> selectedIds, List<DocRecord> allDocs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _multiSelectMode
                  ? Text(
                      key:   const ValueKey('multi'),
                      '${selectedIds.length} selected',
                      style: Theme.of(context).textTheme.displayMedium,
                    )
                  : Text(
                      key:   const ValueKey('normal'),
                      'My Documents',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
            ),
          ),
          if (_multiSelectMode)
            TextButton(
              onPressed: _exitMultiSelect,
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.primary),
              ),
            )
          else
            // Refresh button in normal mode
            IconButton(
              icon:      const Icon(Icons.refresh_rounded, size: 20),
              color:     AppColors.textHint,
              onPressed: () {
                ref.invalidate(docsProvider);
                ref.invalidate(statsProvider);
              },
            ),
        ],
      ),
    );
  }
}




class _StatsStrip extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return statsAsync.when(
      loading: () => const SizedBox(height: 60),
      error:   (_, __) => const SizedBox.shrink(),
      data: (stats) {
        if (stats.totalDocs == 0) return const SizedBox.shrink();

        return Container(
          height:  72,
          margin:  const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Total docs count
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:  MainAxisAlignment.center,
                  children: [
                    Text(
                      '${stats.totalDocs}',
                      style: const TextStyle(
                        fontSize:   24,
                        fontWeight: FontWeight.w800,
                        color:      AppColors.textPrimary,
                      ),
                    ),
                    const Text(
                      'documents',
                      style: TextStyle(
                        fontSize: 11,
                        color:    AppColors.textHint,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                const VerticalDivider(color: AppColors.border, width: 1),
                const SizedBox(width: 16),

                Expanded(
                  child: Wrap(
                    spacing:    8,
                    runSpacing: 6,
                    children: stats.byCategory.entries.map((e) {
                      final color = Color(
                        AppConstants.categoryMeta(e.key).color,
                      );
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7, height: 7,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${e.value} ${AppConstants.categoryMeta(e.key).label}',
                            style: const TextStyle(
                              fontSize: 11,
                              color:    AppColors.textSecond,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        )
            .animate()
            .fade(duration: 400.ms)
            .slideY(begin: -0.05, end: 0, duration: 400.ms);
      },
    );
  }
}


class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller:  controller,
        onChanged:   onChanged,
        style: const TextStyle(
          fontSize: 14,
          color:    AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search by name or category…',
          prefixIcon: const Icon(
            Icons.search_rounded,
            size:  20,
            color: AppColors.textHint,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    controller.clear();
                    onChanged('');
                  },
                  child: const Icon(
                    Icons.close_rounded,
                    size:  18,
                    color: AppColors.textHint,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}


class _MultiSelectBar extends StatelessWidget {
  final int count;
  final List<DocRecord> allDocs;
  final VoidCallback onCancel;
  final VoidCallback onChat;

  const _MultiSelectBar({
    required this.count,
    required this.allDocs,
    required this.onCancel,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16, 12, 16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset:     const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecond,
              side: const BorderSide(color: AppColors.border),
            ),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: GradientButton(
              label:     count == 0
                  ? 'Select documents'
                  : 'Chat with $count doc${count == 1 ? '' : 's'}',
              icon:      Icons.chat_outlined,
              onTap:     count > 0 ? onChat : null,
              isLoading: false,
              width:     double.infinity,
            ),
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: 0.3, end: 0, duration: 300.ms, curve: Curves.easeOut)
        .fade(duration: 200.ms);
  }
}


class _EmptyState extends StatelessWidget {
  final bool hasSearch;
  final VoidCallback onClear;

  const _EmptyState({required this.hasSearch, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasSearch
                ? Icons.search_off_rounded
                : Icons.folder_open_rounded,
            size:  64,
            color: AppColors.textHint.withOpacity(0.4),
          )
              .animate()
              .fade(duration: 400.ms)
              .scale(duration: 400.ms, curve: Curves.elasticOut),

          const SizedBox(height: 16),

          Text(
            hasSearch ? 'No results found' : 'No documents yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            hasSearch
                ? 'Try a different search term'
                : 'Upload a PDF or image to get started',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          if (hasSearch) ...[
            const SizedBox(height: 20),
            OutlinedButton.icon(
              icon:      const Icon(Icons.close_rounded, size: 16),
              label:     const Text('Clear search'),
              onPressed: onClear,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecond,
                side: const BorderSide(color: AppColors.border),
              ),
            ),
          ],
        ],
      ),
    );
  }
}



class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size:  56,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load documents',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Check that the backend is running',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GradientButton(
              label: 'Retry',
              icon:  Icons.refresh_rounded,
              onTap: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}