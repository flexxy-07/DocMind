import 'package:app/core/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/category_badge.dart';



// Can be opened in two modes:
//   Single doc:
//     ChatScreen(docId: "abc", docName: "contract.pdf", category: "legal")
//   Multi-doc:
//     ChatScreen(docIds: ["abc", "xyz"], docNames: ["a.pdf", "b.pdf"])

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
  }) : assert(
          docId != null || (docIds != null && docIds.length > 0),
          'Provide either docId (single) or docIds (multi)',
        );

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _inputController  = TextEditingController();
  final _scrollController = ScrollController();
  final _inputFocusNode   = FocusNode();
  bool _showSuggestions   = true;

  // Build the ChatParams that identifies this chat session
  late final ChatParams _params = ChatParams(
    docId:  widget.docId,
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
    setState(() => _showSuggestions = false);

    
    _scrollToBottom(delayMs: 50);

    await ref.read(chatProvider(_params).notifier).sendMessage(question);


    _scrollToBottom(delayMs: 100);
  }

  @override
  Widget build(BuildContext context) {
    final chatState   = ref.watch(chatProvider(_params));
    final isMultiDoc  = widget.docIds != null;
    final screenWidth = MediaQuery.of(context).size.width;
    
    final contentWidth = screenWidth > 700 ? 700.0 : screenWidth;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _buildAppBar(chatState, isMultiDoc),
      body: Center(
        child: SizedBox(
          width: contentWidth,
          child: Column(
            children: [
              // ── Message list ────────────────────────────
              Expanded(
                child: chatState.messages.isEmpty && _showSuggestions
                    ? _EmptyState(
                        category:  chatState.category.isNotEmpty
                            ? chatState.category
                            : (widget.category ?? 'general'),
                        isMultiDoc: isMultiDoc,
                        docNames:  widget.docNames,
                        onSuggest: _send,
                      )
                    : _MessageList(
                        messages:       chatState.messages,
                        scrollController: _scrollController,
                        error:          chatState.error,
                      ),
              ),

              _InputBar(
                controller:  _inputController,
                focusNode:   _inputFocusNode,
                isStreaming: chatState.isStreaming,
                onSend:      _send,
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ChatState chatState, bool isMultiDoc) {
    return AppBar(
      backgroundColor: AppColors.bg,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_rounded, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: isMultiDoc
          ? _MultiDocTitle(docNames: widget.docNames ?? [])
          : _SingleDocTitle(
              docName:  widget.docName ?? '',
              category: chatState.category.isNotEmpty
                  ? chatState.category
                  : (widget.category ?? 'general'),
            ),
      actions: [
        if (chatState.messages.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            color: AppColors.textHint,
            onPressed: () {
              ref.read(chatProvider(_params).notifier).clearChat();
              setState(() => _showSuggestions = true);
            },
            tooltip: 'Clear conversation',
          ),
        // Doc info bottom sheet
        IconButton(
          icon: const Icon(Icons.info_outline_rounded, size: 20),
          color: AppColors.textHint,
          onPressed: () => _showInfo(context),
        ),
      ],
    );
  }

  void _showInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _InfoSheet(
        docId:    widget.docId,
        docName:  widget.docName,
        category: widget.category,
        docIds:   widget.docIds,
        docNames: widget.docNames,
      ),
    );
  }
}


class _SingleDocTitle extends StatelessWidget {
  final String docName;
  final String category;

  const _SingleDocTitle({required this.docName, required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          docName,
          style: const TextStyle(
            fontSize:   14,
            fontWeight: FontWeight.w600,
            color:      AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        CategoryBadge(category: category, large: false, animate: false),
      ],
    );
  }
}

class _MultiDocTitle extends StatelessWidget {
  final List<String> docNames;

  const _MultiDocTitle({required this.docNames});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${docNames.length} documents',
          style: const TextStyle(
            fontSize:   14,
            fontWeight: FontWeight.w600,
            color:      AppColors.textPrimary,
          ),
        ),
        Text(
          docNames.take(2).join(', ') +
              (docNames.length > 2 ? ' +${docNames.length - 2} more' : ''),
          style: const TextStyle(fontSize: 11, color: AppColors.textHint),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}




class _MessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final ScrollController scrollController;
  final String? error;

  const _MessageList({
    required this.messages,
    required this.scrollController,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      itemCount: messages.length + (error != null ? 1 : 0),
      itemBuilder: (context, i) {
        // Error banner at the end
        if (i == messages.length && error != null) {
          return _ErrorBanner(message: error!);
        }
        return ChatBubble(
          message: messages[i],
          index:   i,
        );
      },
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:        AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                  color: AppColors.error, fontSize: 13),
            ),
          ),
        ],
      ),
    ).animate().shake(hz: 2, duration: 400.ms);
  }
}



class _EmptyState extends StatelessWidget {
  final String category;
  final bool isMultiDoc;
  final List<String>? docNames;
  final void Function(String) onSuggest;

  const _EmptyState({
    required this.category,
    required this.isMultiDoc,
    required this.onSuggest,
    this.docNames,
  });


  static const _suggestions = {
    'legal': [
      'Summarise the key obligations in this contract',
      'What are the payment terms?',
      'What are the grounds for termination?',
      'Are there any penalty clauses?',
    ],
    'health': [
      'What is the diagnosis?',
      'What medications are prescribed?',
      'What follow-up is recommended?',
      'Are there any warnings or contraindications?',
    ],
    'finance': [
      'What is the total amount due?',
      'What are the key financial figures?',
      'Summarise the revenue and expenses',
      'What dates are mentioned?',
    ],
    'education': [
      'Summarise the main topics covered',
      'What are the key learning objectives?',
      'List the most important concepts',
      'What examples are given?',
    ],
    'research': [
      'What is the main finding of this paper?',
      'What methodology was used?',
      'What are the limitations of this study?',
      'What do the authors conclude?',
    ],
    'general': [
      'Summarise this document',
      'What are the key points?',
      'What are the main conclusions?',
      'What dates or deadlines are mentioned?',
    ],
  };

  
  static const _multiSuggestions = [
    'Which document mentions the earliest deadline?',
    'Compare the key terms across documents',
    'Which document has the strictest conditions?',
    'Summarise the main points of each document',
  ];

  @override
  Widget build(BuildContext context) {
    final suggestions = isMultiDoc
        ? _multiSuggestions
        : (_suggestions[category] ?? _suggestions['general']!);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      children: [
        
        Center(
          child: Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:      AppColors.primary.withOpacity(0.3),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const Icon(
              Icons.chat_bubble_outline_rounded,
              color: Colors.white,
              size:  30,
            ),
          )
              .animate()
              .scale(duration: 400.ms, curve: Curves.elasticOut),
        ),

        const SizedBox(height: 16),

        Center(
          child: Text(
            isMultiDoc ? 'Ask across all documents' : 'Ready to answer',
            style: Theme.of(context).textTheme.titleLarge,
          )
              .animate(delay: 100.ms)
              .fade(duration: 300.ms),
        ),

        const SizedBox(height: 6),

        Center(
          child: Text(
            isMultiDoc
                ? 'Searching ${docNames?.length ?? 0} documents'
                : 'Try one of these to get started',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          )
              .animate(delay: 150.ms)
              .fade(duration: 300.ms),
        ),

        const SizedBox(height: 28),

        // Suggestion chips
        ...List.generate(suggestions.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SuggestionCard(
              text:    suggestions[i],
              delay:   Duration(milliseconds: 200 + i * 80),
              onTap:   () => onSuggest(suggestions[i]),
            ),
          );
        }),
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final String text;
  final Duration delay;
  final VoidCallback onTap;

  const _SuggestionCard({
    required this.text,
    required this.delay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color:        AppColors.glass,
          borderRadius: BorderRadius.circular(14),
          border:       Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.lightbulb_outline_rounded,
              size:  16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  color:    AppColors.textPrimary,
                  height:   1.4,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size:  12,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    )
        .animate(delay: delay)
        .fade(duration: 300.ms)
        .slideX(begin: 0.04, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }
}




class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isStreaming;
  final void Function(String) onSend;

  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.isStreaming,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, bottomPad + 10),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Text field — expands vertically up to 5 lines
          Expanded(
            child: TextField(
              controller:    controller,
              focusNode:     focusNode,
              enabled:       !isStreaming,
              maxLines:      5,
              minLines:      1,
              textInputAction: TextInputAction.newline,
              // Ctrl+Enter / Cmd+Enter sends on desktop/web
              onSubmitted:   (_) {},
              style: const TextStyle(
                fontSize: 14,
                color:    AppColors.textPrimary,
                height:   1.45,
              ),
              decoration: InputDecoration(
                hintText: isStreaming
                    ? 'Waiting for response…'
                    : 'Ask anything about this document…',
                hintStyle: TextStyle(
                  color:   isStreaming ? AppColors.textHint : AppColors.textHint,
                  fontSize: 14,
                ),
                filled:       true,
                fillColor:    AppColors.bgElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:   BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Send / loading button
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isStreaming
                // Spinner while waiting
                ? Container(
                    key:    const ValueKey('loading'),
                    width:  46, height: 46,
                    decoration:const BoxDecoration(
                      color:  AppColors.primaryGlow,
                      shape:  BoxShape.circle,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color:       AppColors.primary,
                      ),
                    ),
                  )
                // Send button
                : GestureDetector(
                    key:    const ValueKey('send'),
                    onTap:  () => onSend(controller.text),
                    child: Container(
                      width: 46, height: 46,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape:    BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:      AppColors.primary.withOpacity(0.4),
                            blurRadius: 12,
                            offset:     const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size:  20,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}


class _InfoSheet extends StatelessWidget {
  final String? docId;
  final String? docName;
  final String? category;
  final List<String>? docIds;
  final List<String>? docNames;

  const _InfoSheet({
    this.docId, this.docName, this.category,
    this.docIds, this.docNames,
  });

  @override
  Widget build(BuildContext context) {
    final isMulti = docIds != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color:        AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            isMulti ? 'Multi-document session' : 'Document info',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          if (!isMulti) ...[
            _InfoRow('File',     docName ?? '-'),
            _InfoRow('Category', category ?? '-'),
            _InfoRow('Doc ID',   docId ?? '-'),
          ] else ...[
            Text(
              '${docIds!.length} documents in this session',
              style: const TextStyle(color: AppColors.textSecond),
            ),
            const SizedBox(height: 12),
            ...?docNames?.map((name) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Text('📄', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 13,
                        color:    AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color:   AppColors.textHint,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color:      AppColors.textPrimary,
                fontSize:   13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}