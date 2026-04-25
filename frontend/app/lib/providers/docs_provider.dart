import 'package:app/core/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final docsProvider = FutureProvider.autoDispose<List<DocRecord>>((ref) async {
  return ApiClient().listDocuments();
});

final statsProvider = FutureProvider.autoDispose<AppStats>((ref) async {
  return ApiClient().getStats();
});

class SelectedDocsNotifier extends StateNotifier<Set<String>> {
  // will start with no docs selected
  SelectedDocsNotifier() : super({});

  void toggle(String docId){
    if(state.contains(docId)){
      state = Set.from(state)..remove(docId);
    }else{
      state = Set.from(state)..add(docId);
    }
  }

  void selectAll(List<String> docIds){
    state = Set.from(docIds);
  }
  void clearAll(){
    state = {};
  }
  bool isSelected(String docId) => state.contains(docId);
}

final selectedDocsProvider = StateNotifierProvider<SelectedDocsNotifier, Set<String>>(
  (ref) => SelectedDocsNotifier(),
);


final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final filteredDocsProvider = Provider.autoDispose<AsyncValue<List<DocRecord>>>((ref){
  final docsAsync = ref.watch(docsProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();

  if(!docsAsync.hasValue) return docsAsync;

  final docs = docsAsync.value!;

  if(query.isEmpty) return AsyncValue.data(docs);

  //filter 
  final filtered = docs.where((doc){
    return doc.filename.toLowerCase().contains(query) || doc.category.toLowerCase().contains(query);
  }).toList();
  return AsyncValue.data(filtered);
});

