import 'package:app/core/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isStreaming;
  final String? error;
  final String sessionId;
  final String? docId;
  final List<String>? docIds;
  final String category;

  const ChatState({
    required this.messages,
    required this.isStreaming,
    required this.sessionId,
    this.error,
    this.docId,
    this.docIds,
    this.category = 'general',
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isStreaming,
    String? error,
    String? category,
    bool clearError = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isStreaming: isStreaming ?? this.isStreaming,
      error: clearError ? null : (error ?? this.error),
      sessionId: sessionId,
      docId: docId,
      docIds: docIds,
      category: category ?? this.category,
    );
  }

  List<Map<String, dynamic>> get historyForBackend {
    final recent = messages.length > 6
        ? messages.sublist(messages.length - 6)
        : messages;

    // filters
    return recent
        .where((m) => !m.isStreaming && m.content.isNotEmpty)
        .map((m) => m.toJson())
        .toList();
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final String? _docId;
  final List<String>? _docIds;

  ChatNotifier({String? docId, List<String>? docIds}): 
  _docId = docId,
  _docIds = docIds,
  super(ChatState(messages: const [], isStreaming: false, sessionId: const Uuid().v4(),
  docId: docId,
  docIds: docIds
  ));

  Future<void> sendMessage(String question) async {
  if(question.trim().isEmpty) return;
  if(state.isStreaming) return;

  final userMessage = ChatMessage(role: 'user', content: question.trim(), timestamp: DateTime.now());

  // setting stream
  final streamingMessage = ChatMessage(role: 'assistant', content: '', timestamp: DateTime.now(), isStreaming: true);

  state = state.copyWith(
    messages: [...state.messages, userMessage, streamingMessage],
    isStreaming: true,
    clearError: true
  );

  // connecting to SSE stream
  try {
    final stream = ApiClient().queryStream(question:question.trim(),
    docId: _docId,
    docIds: _docIds,
    conversationHistory: state.historyForBackend,
    );
    String accumulatedText = '';
    List<SourceChunk> sourceChunks = [];

    await for (final event in stream) {
      switch (event) {
        case TokenEvent(:final token):
          accumulatedText += token;
          final updated = List<ChatMessage>.from(state.messages);
          updated[updated.length - 1] = streamingMessage.copyWith(
            content: accumulatedText,
            isStreaming: true,
          );
          state = state.copyWith(messages: updated);
          break;

        case SourcesEvent(:final sources):
          sourceChunks = sources;
          break;

        case DoneEvent(:final category):
          final finalMsg = streamingMessage.copyWith(
            content: accumulatedText,
            sources: sourceChunks,
            isStreaming: false,
          );

          final finalList = List<ChatMessage>.from(state.messages);
          finalList[finalList.length - 1] = finalMsg;

          state = state.copyWith(
            messages: finalList,
            isStreaming: false,
            category: category,
          );

          // saving sessions
          _saveSession();
          break;

        case ErrorEvent(:final message):
          _handleError(message);
          break;
      }
    }

  } catch (e){
    _handleError(e.toString());
  }

}

  void clearChat(){
    state = ChatState(messages: const [], isStreaming: false, sessionId: const Uuid().v4(),
    docId: _docId, docIds: _docIds,
    category: state.category
    );
  }

  // past session load
  void loadSession(Map<String, dynamic> sessionData){
    final rawMessages = sessionData['messages'] as List? ?? [];

    final messages = rawMessages.map((msg){
      final map = msg as Map<String, dynamic>;
      return ChatMessage(role: map['role'] ?? 'user', content: map['content'] ?? '', timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now());
    }).toList();

    state = ChatState(messages: messages, isStreaming: false, sessionId: sessionData['session_id'] ?? const Uuid().v4(),
    docId: _docId,
    docIds: _docIds,
    category: sessionData['category'] ?? 'general'
    );


  }

  void _handleError(String msg){
    final msgs = List<ChatMessage>.from(state.messages);
    if(msgs.isNotEmpty && msgs.last.isStreaming){
      msgs.removeLast();
    }

    state = state.copyWith(
      messages: msgs,
      isStreaming: false,
      error: msg,
    );
  }

  Future<void> _saveSession() async {
    if(state.messages.isEmpty) return;
    try {
      await ApiClient().saveSession(sessionId: state.sessionId, messages: state.messages.where((m) => !m.isStreaming).toList(), createdAt: DateTime.now().toIso8601String(), docId: _docId, docIds: _docIds);
    }catch(e){
      print('Session was failed (non -fatal): $e');
    }
  }
}

class ChatParams {
  final String? docId;
  final List<String>? docIds;

  const ChatParams({
    this.docId , this.docIds
  });

  @override
  bool operator ==(Object other) => 
    other is ChatParams && other.docId == docId && _listEquals(other.docIds, docIds);


  @override
  int get hashCode => Object.hash(docId, docIds);

  bool _listEquals(List? a, List? b){
    if(a == null && b == null) return true;
    if(a==null || b == null) return false;
    if(a.length != b.length) return false;
    for (int i = 0; i < a.length; i++){
      if(a[i] != b[i]) return false;
    }
    return true;
  }
}

final chatProvider = StateNotifierProvider.autoDispose.family<ChatNotifier, ChatState, ChatParams>((ref, params) => 
 ChatNotifier(
  docId: params.docId,
  docIds: params.docIds,
 )
 );




