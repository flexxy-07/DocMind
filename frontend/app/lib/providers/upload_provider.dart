import 'package:app/core/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

sealed class UploadState {}

class UploadIdle extends UploadState {}

class UploadUploading extends UploadState {
  final double progress;
  final String phase;
  UploadUploading({required this.progress, required this.phase});
}

class UploadDone extends UploadState {
  final IngestResult result;
  UploadDone(this.result);
}

class UploadError extends UploadState {
  final String message;
  UploadError(this.message);
}

class UploadNotifier extends StateNotifier<UploadState> {
  UploadNotifier() : super(UploadIdle());

  Future<void> upload({
    required List<int> fileBytes,
    required String filename,
  }) async {
    // Validation before sending the the backend
    final ext = filename.split('.').last.toLowerCase();
    const allowed = ['pdf', 'jpg', 'jpeg', 'png', 'webp', 'txt', 'md'];

    if (!allowed.contains(ext)) {
      state = UploadError('File type ".$ext" is not supported.');
      return;
    }

    final sizeMB = fileBytes.length / (1024 * 1024);
    if (sizeMB > 20) {
      state = UploadError(
        'File is ${sizeMB.toStringAsFixed(1)}MB. Maximum is 20MB.',
      );
      return;
    }

    // uploding
    state = UploadUploading(progress: 0.0, phase: 'Uploading file...');

    try {
      final result = await ApiClient().ingestDocument(
        fileBytes: fileBytes,
        filename: filename,
        onProgress: (progress) {
          // wiill be called repeatedly as bytes are sent to the backend
          // from 0.0 to 1.0
          if (progress < 0.5) {
            state = UploadUploading(
              progress: progress,
              phase: 'Uploading file...',
            );
          } else {
            state = UploadUploading(
              progress: 1.0,
              phase: 'Analysing document...',
            );
          }
        },
      );

      // success
      state = UploadDone(result);
    } on Exception catch (e) {
      state = UploadError(_friendlyError(e.toString()));
    }
  }

  // triggered when upload another is selected
  void reset() => state = UploadIdle();

  String _friendlyError(String raw) {
    if (raw.contains('Cannot connect') || raw.contains('connection')) {
      return 'Cannot reach the server. Is the backend running?';
    }
    if (raw.contains('timed out')) {
      return 'Upload timed out. Try a smaller file.';
    }
    if (raw.contains('413')) {
      return 'File too large. Maximum size is 20MB.';
    }
    if (raw.contains('422')) {
      return 'Could not extract text from this file.';
    }
    return 'Upload failed. Please try again.';
  }
}

final uploadProvider = StateNotifierProvider.autoDispose<UploadNotifier, UploadState>((ref) => UploadNotifier(),);