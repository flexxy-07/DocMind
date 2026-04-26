import 'package:app/core/api_client.dart';
import 'package:app/core/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:app/widgets/source_chip.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final int index;

  const ChatBubble({super.key, required this.message, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: message.role == 'user'
          ? _UserBubble(message: message, index: index)
          : _AssistantBubble(message: message, index: index),
    );
  }
}

class _UserBubble extends StatelessWidget {
  final ChatMessage message;
  final int index;

  const _UserBubble({required this.message, required this.index});

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        FadeEffect(duration: 200.ms),
        SlideEffect(
          begin: const Offset(0.05, 0),
          end: Offset.zero,
          duration: 200.ms,
          curve: Curves.easeOut,
        ),
      ],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),

                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                message.content,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// assistant

class _AssistantBubble extends StatelessWidget {
  final ChatMessage message;
  final int index;

  const _AssistantBubble({required this.message, required this.index});

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: [
        FadeEffect(duration: 200.ms),
        SlideEffect(
          begin: const Offset(-0.05, 0),
          end: Offset.zero,
          duration: 200.ms,
          curve: Curves.easeOut,
        ),
      ],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _AIAvatar(),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.glass,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(18),
                      topLeft: Radius.circular(4),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: message.isStreaming && message.content.isEmpty
                      ? const _TypingDots()
                      : MarkdownBody(
                          data: message.content,
                          styleSheet: _markdownStyle(),
                          softLineBreak: true,
                        ),
                ),

                if (!message.isStreaming && message.sources.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4),
                    child: SourceChipRow(sources: message.sources),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

MarkdownStyleSheet _markdownStyle() {
  return MarkdownStyleSheet(
    p: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6),
    strong: const TextStyle(
      fontSize: 14,
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w700,
    ),
    em: const TextStyle(
      fontSize: 14,
      color: AppColors.textSecond,
      fontStyle: FontStyle.italic,
    ),
    code: const TextStyle(
      fontSize: 13,
      fontFamily: 'monospace',
      color: AppColors.secondary,
      backgroundColor: AppColors.bgElevated,
    ),
    codeblockDecoration: BoxDecoration(
      color: AppColors.bgElevated,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.border),
    ),
    blockquote: const TextStyle(color: AppColors.textSecond, fontSize: 14),
    blockquoteDecoration: const BoxDecoration(
      border: Border(left: BorderSide(color: AppColors.primary, width: 3)),
    ),
    listBullet: const TextStyle(color: AppColors.primary, fontSize: 14),
    h1: const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    h2: const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    h3: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
  );
}

class _AIAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.psychology_rounded,
        size: 18,
        color: Colors.white,
      ),
    );
  }
}

class _TypingDots extends StatelessWidget {
  const _TypingDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
            )
            .animate(onPlay: (c) => c.repeat())
            .moveY(
              begin: 0,
              end: -6,
              delay: Duration(milliseconds: i * 150),
              duration: 400.ms,
              curve: Curves.easeInOut,
            )
            .then()
            .moveY(
              begin: -6,
              end: 0,
              duration: 400.ms,
              curve: Curves.easeInOut,
            );
      }),
    );
  }
}
