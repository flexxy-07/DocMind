import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system.dart';
import '../../providers/docs_provider.dart';
import '../../core/api_client.dart';
import '../../widgets/glass_input.dart';
import 'views/documents_list_view.dart';
import 'views/documents_empty_view.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  final _searchController = TextEditingController();

  Future<void> _deleteDoc(String docId) async {
    try {
      await ApiClient().deleteDocument(docId);
      ref.invalidate(docsProvider);
      ref.invalidate(statsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete failed: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredDocsProvider);

    return Scaffold(
      backgroundColor: ObsidianColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearch(),
            const SizedBox(height: 16),
            Expanded(
              child: filteredAsync.when(
                data: (docs) => docs.isEmpty
                    ? DocumentsEmptyView(
                        isSearch: _searchController.text.isNotEmpty,
                        onClear: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).state = '';
                        },
                      )
                    : DocumentsListView(
                        docs: docs,
                        onDelete: _deleteDoc,
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'ARCHIVES',
            style: ObsidianTypography.displayMedium.copyWith(fontSize: 24),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: ObsidianColors.onSurfaceVariant),
            onPressed: () {
              ref.invalidate(docsProvider);
              ref.invalidate(statsProvider);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassInput(
        controller: _searchController,
        hintText: 'FILTER BY NAME OR CATEGORY...',
        prefixIcon: Icons.search_rounded,
        onSubmitted: (q) => ref.read(searchQueryProvider.notifier).state = q,
      ),
    );
  }
}