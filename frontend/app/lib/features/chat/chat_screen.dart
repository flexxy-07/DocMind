import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/design_system.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/glass_input.dart';
import '../../widgets/category_badge.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String? docId;
  final String? docName;
  final String? category;
  final bool isImageDoc;
  final List<String>? docIds;
  final List<String>? docNames;

  const ChatScreen({
    super.key,
    this.docId,
    this.docName,
    this.category,
    this.isImageDoc = false,
    this.docIds,
    this.docNames,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  final _inputFocusNode = FocusNode();

  late final ChatParams _params = ChatParams(
    docId: widget.docId,
    docIds: widget.docIds,
    isImageDoc: widget.isImageDoc,
  );

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom({int delayMs = 0}) {
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send(String question) async {
    if (question.trim().isEmpty) return;
    _inputController.clear();
    _scrollToBottom(delayMs: 50);
    await ref.read(chatProvider(_params).notifier).sendMessage(question);
    _scrollToBottom(delayMs: 100);
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider(_params));

    return Scaffold(
      backgroundColor: ObsidianColors.background,
      appBar: _buildAppBar(chatState),
      body: Column(
        children: [
          Expanded(
            child: chatState.messages.isEmpty
                ? _EmptyChatState(
                    onSuggest: _send,
                    category: widget.category ?? 'general',
                  )
                : ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    itemCount: chatState.messages.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 24),
                    itemBuilder: (context, index) {
                      return ChatBubble(
                        message: chatState.messages[index],
                        index: index,
                      );
                    },
                  ),
          ),
          _ChatInputSection(
            controller: _inputController,
            isStreaming: chatState.isStreaming,
            onSend: _send,
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ChatState chatState) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (widget.docName ?? (widget.docNames?.first ?? 'Investigation')).toUpperCase(),
            style: ObsidianTypography.technicalLabel.copyWith(fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (widget.category != null)
            CategoryBadge(category: widget.category!, large: false, animate: false),
        ],
      ),
      actions: [
        if (chatState.messages.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 22),
            onPressed: () => ref.read(chatProvider(_params).notifier).clearChat(),
          ),
      ],
    );
  }
}

class _ChatInputSection extends StatelessWidget {
  final TextEditingController controller;
  final bool isStreaming;
  final ValueChanged<String> onSend;

  const _ChatInputSection({
    required this.controller,
    required this.isStreaming,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad + 16),
      decoration: const BoxDecoration(
        color: ObsidianColors.surfaceContainerLowest,
        border: Border(
          top: BorderSide(color: ObsidianColors.border),
        ),
      ),
      child: GlassInput(
        controller: controller,
        hintText: 'QUERY ARCHIVE...',
        onSubmitted: onSend,
        suffixIcon: IconButton(
          icon: isStreaming 
              ? const SizedBox(
                  width: 20, height: 20, 
                  child: CircularProgressIndicator(strokeWidth: 2, color: ObsidianColors.primary))
              : const Icon(Icons.send_rounded, color: ObsidianColors.primary),
          onPressed: isStreaming ? null : () => onSend(controller.text),
        ),
      ),
    );
  }
}

class _EmptyChatState extends StatelessWidget {
  final ValueChanged<String> onSuggest;
  final String category;

  const _EmptyChatState({required this.onSuggest, required this.category});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome_rounded, size: 48, color: ObsidianColors.primary)
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scale(duration: 1000.ms),
          const SizedBox(height: 24),
          Text(
            'READY FOR INTELLIGENCE RETRIEVAL',
            style: ObsidianTypography.technicalLabel,
          ),
        ],
      ),
    );
  }
}