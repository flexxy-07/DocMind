import 'package:app/core/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../providers/upload_provider.dart';
import '../../providers/docs_provider.dart';
import '../../widgets/category_badge.dart';
import '../chat/chat_screen.dart';


class UploadScreen extends ConsumerWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the upload state — widget rebuilds on every state change
    final uploadState = ref.watch(uploadProvider);

    return Scaffold(
      // Gradient background — darkest at top, slightly lighter at bottom
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            // Switch between the 4 states
            child: switch (uploadState) {
              UploadIdle() => _IdleView(onPick: () => _pickFile(context, ref)),
              UploadUploading() => _UploadingView(state: uploadState),
              UploadDone(:final result) => _DoneView(
                    result: result,
                    onReset: () {
                      ref.read(uploadProvider.notifier).reset();
                      // Invalidate docs list so it refreshes
                      ref.invalidate(docsProvider);
                    },
                  ),
              UploadError(:final message) => _ErrorView(
                    message: message,
                    onRetry: () => ref.read(uploadProvider.notifier).reset(),
                  ),
            },
          ),
        ),
      ),
    );
  }

  Future<void> _pickFile(BuildContext context, WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: AppConstants.allowedExtensions,
      // withData=true loads file bytes into memory
      // Required because we read file.bytes to upload
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) return;

    // Hand off to the provider — it handles all validation + upload
    await ref.read(uploadProvider.notifier).upload(
      fileBytes: file.bytes!,
      filename:  file.name,
    );
  }
}



class _IdleView extends StatelessWidget {
  final VoidCallback onPick;

  const _IdleView({required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 32),

        
        Text(
          'DocMind',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ).createShader(const Rect.fromLTWH(0, 0, 200, 50)),
          ),
        )
            .animate()
            .fade(duration: 500.ms)
            .slideY(begin: -0.1, end: 0, duration: 500.ms),

        Text(
          'Ask anything about your documents',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        )
            .animate(delay: 100.ms)
            .fade(duration: 400.ms),

        const SizedBox(height: 48),

        // Drop zone
        _DropZone(onTap: onPick)
            .animate(delay: 200.ms)
            .fade(duration: 400.ms)
            .scale(
              begin: const Offset(0.96, 0.96),
              end:   const Offset(1, 1),
              duration: 400.ms,
            ),

        const SizedBox(height: 32),

        // Supported formats
        _FormatsRow()
            .animate(delay: 300.ms)
            .fade(duration: 400.ms),

        const Spacer(),

        // Feature highlights
        const _FeatureRow()
            .animate(delay: 400.ms)
            .fade(duration: 400.ms),

        const SizedBox(height: 24),
      ],
    );
  }
}


class _DropZone extends StatefulWidget {
  final VoidCallback onTap;
  const _DropZone({required this.onTap});

  @override
  State<_DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<_DropZone> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:   (_) => setState(() => _pressed = true),
      onTapUp:     (_) => setState(() => _pressed = false),
      onTapCancel: ()  => setState(() => _pressed = false),
      onTap:       widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width:  double.infinity,
        height: 240,
        decoration: BoxDecoration(
          // Scale down slightly when pressed — tactile feedback
          color: _pressed
              ? AppColors.primaryGlow
              : AppColors.glass,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _pressed
                ? AppColors.primary
                : AppColors.borderGlow,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color:      AppColors.primary.withOpacity(_pressed ? 0.2 : 0.1),
              blurRadius: _pressed ? 32 : 20,
              spreadRadius: _pressed ? 4 : 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated icon
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:      AppColors.primary.withOpacity(0.4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(
                Icons.upload_file_rounded,
                size:  36,
                color: Colors.white,
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(1, 1),
                  end:   const Offset(1.06, 1.06),
                  duration: 1500.ms,
                  curve: Curves.easeInOut,
                ),
            const SizedBox(height: 20),
            Text(
              'Tap to upload a document',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'PDF, image, or text file · max 20 MB',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}


class _FormatsRow extends StatelessWidget {
  final _formats = const ['PDF', 'JPG', 'PNG', 'WEBP', 'TXT', 'MD'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment:  WrapAlignment.center,
      spacing:    8,
      runSpacing: 8,
      children:   _formats.map((f) => _FormatChip(label: f)).toList(),
    );
  }
}

class _FormatChip extends StatelessWidget {
  final String label;
  const _FormatChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color:        AppColors.bgElevated,
        borderRadius: BorderRadius.circular(8),
        border:       Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize:   12,
          color:      AppColors.textSecond,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}


class _FeatureRow extends StatelessWidget {
  const _FeatureRow();

  final _features = const [
    (Icons.auto_awesome_rounded,    'AI Classification'),
    (Icons.search_rounded,          'Semantic Search'),
    (Icons.chat_bubble_outline_rounded, 'Streaming Chat'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _features.map((f) => _FeatureItem(
        icon:  f.$1,
        label: f.$2,
      )).toList(),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color:    AppColors.textSecond,
          ),
        ),
      ],
    );
  }
}



class _UploadingView extends StatelessWidget {
  final UploadUploading state;

  const _UploadingView({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pulsing AI brain icon
        Container(
          width: 88, height: 88,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color:      AppColors.primary.withOpacity(0.5),
                blurRadius: 30,
              ),
            ],
          ),
          child: const Icon(
            Icons.psychology_rounded,
            size:  44,
            color: Colors.white,
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(
              begin: const Offset(1, 1),
              end:   const Offset(1.08, 1.08),
              duration: 900.ms,
              curve: Curves.easeInOut,
            ),

        const SizedBox(height: 36),

        // Phase label — animates when text changes
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            state.phase,
            key:   ValueKey(state.phase),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),

        const SizedBox(height: 8),

        // Progress percentage
        Text(
          state.progress < 1.0
              ? '${(state.progress * 100).toInt()}%'
              : 'Processing…',
          style: Theme.of(context).textTheme.bodyMedium,
        ),

        const SizedBox(height: 28),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            // null value = indeterminate (spinning) when progress = 1.0
            value:           state.progress < 1.0 ? state.progress : null,
            minHeight:       6,
            backgroundColor: AppColors.bgElevated,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),

        const SizedBox(height: 20),

        Text(
          state.progress < 1.0
              ? 'Uploading your file…'
              : 'Classifying · Chunking · Embedding',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textHint,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}


class _DoneView extends StatelessWidget {
  final IngestResult result;
  final VoidCallback onReset;

  const _DoneView({required this.result, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 48),

          // Success checkmark
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.success.withOpacity(0.4),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.success,
              size:  40,
            ),
          )
              .animate()
              .scale(
                begin:    const Offset(0, 0),
                end:      const Offset(1, 1),
                duration: 500.ms,
                curve:    Curves.elasticOut,
              ),

          const SizedBox(height: 24),

          Text(
            'Document ready!',
            style: Theme.of(context).textTheme.displayMedium,
          )
              .animate(delay: 200.ms)
              .fade(duration: 300.ms)
              .slideY(begin: 0.1, end: 0),

          const SizedBox(height: 6),

          Text(
            result.filename,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          )
              .animate(delay: 250.ms)
              .fade(duration: 300.ms),

          const SizedBox(height: 24),

          // Category badge — pops in with elastic animation
          CategoryBadge(
            category: result.category,
            large:    true,
            animate:  true,
          ),

          const SizedBox(height: 28),

          // Result stats card
          _ResultCard(result: result)
              .animate(delay: 500.ms)
              .fade(duration: 400.ms)
              .slideY(begin: 0.08, end: 0),

          const SizedBox(height: 32),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon:      const Icon(Icons.upload_file_outlined, size: 18),
                  label:     const Text('Upload another'),
                  onPressed: onReset,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecond,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GradientButton(
                  label: 'Ask questions',
                  icon:  Icons.chat_outlined,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        docId:    result.docId,
                        docName:  result.filename,
                        category: result.category,
                        isImageDoc: result.isImageDoc,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
              .animate(delay: 600.ms)
              .fade(duration: 300.ms),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}


class _ResultCard extends StatelessWidget {
  final IngestResult result;

  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        children: [
          _StatRow('Pages',          '${result.pageCount}'),
          const Divider(color: AppColors.border, height: 20),
          _StatRow('Chunks indexed', '${result.chunkCount}'),
          const Divider(color: AppColors.border, height: 20),
          _StatRow(
            'Document type',
            result.isImageDoc ? 'Scanned / Image' : 'Text PDF',
          ),
          const Divider(color: AppColors.border, height: 20),
          _StatRow('Confidence', result.categoryConfidence.toUpperCase()),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color:    AppColors.textSecond,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize:   13,
            fontWeight: FontWeight.w600,
            color:      AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}




class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color:  AppColors.error.withOpacity(0.1),
            shape:  BoxShape.circle,
            border: Border.all(
              color: AppColors.error.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.error_outline_rounded,
            color: AppColors.error,
            size:  40,
          ),
        )
            .animate()
            .shake(duration: 500.ms, hz: 3),

        const SizedBox(height: 24),

        Text(
          'Upload failed',
          style: Theme.of(context).textTheme.titleLarge,
        ),

        const SizedBox(height: 8),

        Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        GradientButton(
          label: 'Try again',
          icon:  Icons.refresh_rounded,
          onTap: onRetry,
        ),
      ],
    );
  }
}