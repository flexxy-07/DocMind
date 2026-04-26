import 'dart:async';
import 'dart:convert';

import 'package:app/core/constants.dart';
import 'package:dio/dio.dart';

class DocRecord {
  final String docId;
  final String filename;
  final String category;
  final String categoryConfidence;
  final int chunkCount;
  final int pageCount;
  final bool isImageDoc;
  final String storageUrl;
  final String uploadedAt;

  const DocRecord({
    required this.docId,
    required this.filename,
    required this.category,
    required this.categoryConfidence,
    required this.chunkCount,
    required this.pageCount,
    required this.isImageDoc,
    required this.storageUrl,
    required this.uploadedAt,
  });

  DateTime get createdAt {
    try {
      return DateTime.parse(uploadedAt);
    } catch (_) {
      return DateTime.now();
    }
  }

  factory DocRecord.fromJson(Map<String, dynamic> js) => DocRecord(
    docId: js['doc_id'] ?? '',
    filename: js['filename'] ?? '',
    category: js['category'] ?? 'general',
    categoryConfidence: js['category_confidence'] ?? 'low',
    chunkCount: js['chunk_count'] ?? 0,
    pageCount: js['page_count'] ?? 1,
    isImageDoc: js['is_image_doc'] ?? false,
    storageUrl: js['storage_url'] ?? '',
    uploadedAt: js['uploaded_at'] ?? '',
  );
}

class SourceChunk {
  final String text;
  final int? page;
  final double score;
  final String docId;
  final String filename;

  const SourceChunk({
    required this.text,
    this.page,
    required this.score,
    required this.docId,
    required this.filename,
  });

  factory SourceChunk.fromJson(Map<String, dynamic> j) => SourceChunk(
    text: j['text'] ?? '',
    page: j['page'],
    score: (j['score'] as num?)?.toDouble() ?? 0.0,
    docId: j['doc_id'] ?? '',
    filename: j['filename'] ?? '',
  );
}

class IngestResult {
  final String docId;
  final String filename;
  final String category;
  final String categoryConfidence;
  final int chunkCount;
  final int pageCount;
  final bool isImageDoc;
  final String storageUrl;
  final String message;

  const IngestResult({
    required this.docId,
    required this.filename,
    required this.category,
    required this.categoryConfidence,
    required this.chunkCount,
    required this.pageCount,
    required this.isImageDoc,
    required this.storageUrl,
    required this.message,
  });

  factory IngestResult.fromJson(Map<String, dynamic> j) => IngestResult(
    docId: j['doc_id'] ?? '',
    filename: j['filename'] ?? '',
    category: j['category'] ?? 'general',
    categoryConfidence: j['category_confidence'] ?? 'low',
    chunkCount: j['chunk_count'] ?? 0,
    pageCount: j['page_count'] ?? 1,
    isImageDoc: j['is_image_doc'] ?? false,
    storageUrl: j['storage_url'] ?? '',
    message: j['message'] ?? '',
  );
}

class ChatMessage {
  final String role; // like user or assit
  final String content;
  final List<SourceChunk> sources;
  final DateTime timestamp;
  final bool isStreaming;

  const ChatMessage({
    required this.role,
    required this.content,
    this.sources = const [],
    required this.timestamp,
    this.isStreaming = false,
  });

  ChatMessage copyWith({
    String? content,
    List<SourceChunk>? sources,
    bool? isStreaming,
  }) {
    return ChatMessage(
      role: role,
      content: content ?? this.content,
      sources: sources ?? this.sources,
      timestamp: timestamp,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
  };
}

class AppStats {
  final int totalDocs;
  final Map<String, int> byCategory;
  final int totalSessions;

  const AppStats({
    required this.totalDocs,
    required this.byCategory,
    required this.totalSessions,
  });

  factory AppStats.fromJson(Map<String, dynamic> js) => AppStats(
    totalDocs: js['total_docs'] ?? 0,
    byCategory: Map<String, int>.from(js['by_category'] ?? {}),
    totalSessions: js['total_sessions'] ?? 0,
  );
}

// stream reponses

sealed class StreamEvent {}

class TokenEvent extends StreamEvent {
  final String token;
  TokenEvent(this.token);
}

class SourcesEvent extends StreamEvent {
  final List<SourceChunk> sources;
  SourcesEvent(this.sources);
}

class DoneEvent extends StreamEvent {
  final String category;
  DoneEvent(this.category);
}

class ErrorEvent extends StreamEvent {
  final String message;
  ErrorEvent(this.message);
}

// client
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // health
  Future<Map<String, dynamic>> healthCheck() async {
    final res = await _dio.get(AppConstants.healthUrl);
    return res.data as Map<String, dynamic>;
  }

  // ingest
  Future<IngestResult> ingestDocument({
    required List<int> fileBytes,
    required String filename,
    required void Function(double progress) onProgress,
  }) async {
    // FormData is Dio's way of building a multipart/form-data request.
    // This is the format browsers use for file uploads — FastAPI's
    // UploadFile expects exactly this format.
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(fileBytes, filename: filename),
    });

    final res = await _dio.post(
      AppConstants.ingestUrl,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        receiveTimeout: const Duration(minutes: 5),
      ),
      onSendProgress: (sent, total) {
        if (total > 0) onProgress(sent / total);
      },
    );

    return IngestResult.fromJson(res.data as Map<String, dynamic>);
  }

  // not streaming query:
  Future<Map<String, dynamic>> query({
    required String question,
    String? docId,
    List<Map<String, dynamic>> conversationHistory = const [],
  }) async {
    final res = await _dio.post(
      AppConstants.queryUrl,
      data: {
        'question': question,
        if (docId != null) 'doc_id': docId,
        'conversation_history': conversationHistory,
      },
    );
    return res.data as Map<String, dynamic>;
  }

  // streaming query
  Stream<StreamEvent> queryStream({
    required String question,
    String? docId,
    List<String>? docIds,
    List<Map<String, dynamic>> conversationHistory = const[],
  }){
    final controller = StreamController<StreamEvent>();
    _doStream(
      question: question,
      docId : docId,
      docIds : docIds,
      conversationHistory: conversationHistory,
      controller: controller,
    );

    return controller.stream;
  }

  Future<void> _doStream({
    required String question,
    String? docId,
    List<String>? docIds,
    required List<Map<String, dynamic>> conversationHistory,
    required StreamController<StreamEvent> controller,
  }) async {
    try {
      final res = await _dio.post(
        AppConstants.streamUrl,
        data: {
          'question' : question,
          if(docId != null) 'doc_id': docId,
          if(docIds != null) 'doc_ids': docIds,
          'conversation_history': conversationHistory,
        },
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: const Duration(minutes: 5),
        )
      );

      final byteStream = res.data.stream as Stream<List<int>>;

      // accumulate until we see \n\n
      final buffer = StringBuffer();

      await for (final bytes in byteStream){
        // decoding the bytes to UTF-8 and adding it to buffer
        buffer.write(utf8.decode(bytes, allowMalformed: true));

        final raw = buffer.toString();
        final lines = raw.split('\n');

        buffer.clear();
        buffer.write(lines.last);

        // for all comleted lines
        for (int i = 0; i< lines.length - 1; i++){
          final line = lines[i].trim();

          // events start with 'data: '
          if(!line.startsWith('data: ')) continue;

          final jsonStr = line.substring(6); // removing the 'data' : prefix
          if(jsonStr.isEmpty) continue;

          try{
            final data = json.decode(jsonStr) as Map<String, dynamic>;
            final type = data['type'] as String? ?? '';

            switch(type){
              case 'token':
              controller.add(TokenEvent(data['content'] as String? ?? ''));

              case 'sources':
              // after the answer is done
              final rawSources = data['content'] as List? ?? [];
              final sources = rawSources.map((s) => SourceChunk.fromJson(s as Map<String, dynamic>)).toList();
              controller.add(SourcesEvent(sources));

              case 'done' : 
              controller.add(DoneEvent(data['category'] as String? ?? 'general'));

              case 'error' :
              controller.add(ErrorEvent(data['content'] as String? ?? 'Unknown error'));
            }
          }catch (e){
            // if one json is malformed, skip it dont crash
            continue;
          }
        }
      }
    } on DioException catch (e) {
      controller.add(ErrorEvent(_parseDioError(e)));
    } catch (e) {
      controller.add(ErrorEvent('Unexpected error: $e'));
    } finally {
      // if not done, flutter will keep waiting forever
      await controller.close();
    }
  }

  Future<Map<String, dynamic>> queryMulti({
    required String question,
    required List<String> docIds,
    List<Map<String, dynamic>> conversationHistory = const [],
  }) async {
    final res = await _dio.post(
      AppConstants.multiUrl,
      data: {
        'question':             question,
        'doc_ids':              docIds,
        'conversation_history': conversationHistory,
      },
    );
    return res.data as Map<String, dynamic>;
  }

  Future<List<DocRecord>> listDocuments() async {
    final res  = await _dio.get(AppConstants.docsUrl);
    final list = res.data as List;
    return list
        .map((item) => DocRecord.fromJson(item as Map<String, dynamic>))
        .toList();
  }
  Future<DocRecord> getDocument(String docId) async {
    final res = await _dio.get('${AppConstants.docsUrl}/$docId');
    return DocRecord.fromJson(res.data as Map<String, dynamic>);
  }
 
  Future<void> deleteDocument(String docId) async {
    await _dio.delete('${AppConstants.docsUrl}/$docId');
  }
 
  Future<AppStats> getStats() async {
    final res = await _dio.get(AppConstants.statsUrl);
    return AppStats.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> listSessions({String? docId}) async {
    final res = await _dio.get(
      AppConstants.sessionsUrl,
      queryParameters: docId != null ? {'doc_id': docId} : null,
    );
    return (res.data as List)
        .map((s) => s as Map<String, dynamic>)
        .toList();
  }

  Future<void> saveSession({
    required String sessionId,
    String? docId,
    List<String>? docIds,
    required List<ChatMessage> messages,
    required String createdAt,
  }) async {
    await _dio.post(
      AppConstants.sessionsUrl,
      data: {
        'session_id': sessionId,
        if (docId != null)   'doc_id':  docId,
        if (docIds != null)  'doc_ids': docIds,
        'messages':   messages.map((m) => m.toJson()).toList(),
        'created_at': createdAt,
      },
    );
  }

  Future<void> deleteSession(String sessionId) async {
    await _dio.delete('${AppConstants.sessionsUrl}/$sessionId');
  }

  String _parseDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
        return 'Connection timed out. Check your network.';
      case DioExceptionType.receiveTimeout:
        return 'Server took too long to respond.';
      case DioExceptionType.connectionError:
        return 'Cannot connect to server. Is the backend running?';
      case DioExceptionType.badResponse:
        // Try to extract the FastAPI error detail from the response body
        final data = e.response?.data;
        if (data is Map && data.containsKey('detail')) {
          return data['detail'].toString();
        }
        return 'Server error ${e.response?.statusCode}';
      default:
        return 'Network error: ${e.message}';
    }
  }
}
