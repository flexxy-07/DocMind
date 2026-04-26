import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/design_system.dart';
import '../../core/constants.dart';
import '../../providers/upload_provider.dart';
import '../../providers/docs_provider.dart';

import 'views/upload_idle_view.dart';
import 'views/uploading_view.dart';
import 'views/upload_done_view.dart';
import 'views/upload_error_view.dart';

class UploadScreen extends ConsumerWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(uploadProvider);

    return Scaffold(
      backgroundColor: ObsidianColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: switch (uploadState) {
            UploadIdle() => UploadIdleView(
                onPick: () => _pickFile(context, ref),
              ),
            UploadUploading() => UploadingView(state: uploadState),
            UploadDone(:final result) => UploadDoneView(
                result: result,
                onReset: () {
                  ref.read(uploadProvider.notifier).reset();
                  ref.invalidate(docsProvider);
                },
              ),
            UploadError(:final message) => UploadErrorView(
                message: message,
                onRetry: () => ref.read(uploadProvider.notifier).reset(),
              ),
          },
        ),
      ),
    );
  }

  Future<void> _pickFile(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: AppConstants.allowedExtensions,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) return;

    await ref.read(uploadProvider.notifier).upload(
      fileBytes: file.bytes!,
      filename: file.name,
    );
  }
}