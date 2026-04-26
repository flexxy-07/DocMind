import 'package:app/core/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../core/design_system.dart';
import 'obsidian_card.dart';
import 'source_chip.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final int index;

  const ChatBubble({super.key, required this.message, required this.index});

  @override
  Widget build(BuildContext context) {
    final isAssistant = message.role != 'user';

    return Row(
      mainAxisAlignment: isAssistant ? MainAxisAlignment.start : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isAssistant) ...[
          _TechnicalAvatar(),
          const SizedBox(width: 12),
        ],
        Flexible(
          child: Column(
            crossAxisAlignment: isAssistant ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              if (isAssistant)
                ObsidianCard(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  color: ObsidianColors.surfaceContainerHigh.withOpacity(0.6),
                  child: message.isStreaming && message.content.isEmpty
                      ? _TechnicalTypingIndicator()
                      : MarkdownBody(
                          data: message.content,
                          styleSheet: _obsidianMarkdownStyle(),
                        ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: ObsidianColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(ObsidianShapes.radiusMD),
                  ),
                  child: Text(
                    message.content,
                    style: ObsidianTypography.bodyMedium,
                  ),
                ),
              
              if (isAssistant && !message.isStreaming && message.sources.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SourceChipRow(sources: message.sources),
                ),
            ],
          ),
        ),
      ],
    ).animate().fade(duration: 300.ms).slideY(begin: 0.05, end: 0);
  }
}

class _TechnicalAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: ObsidianColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(ObsidianShapes.radiusSM),
        border: Border.all(color: ObsidianColors.border),
      ),
      child: const Icon(Icons.bolt_rounded, size: 18, color: ObsidianColors.primary),
    );
  }
}

class _TechnicalTypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Container(
          width: 4,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          color: ObsidianColors.primary.withOpacity(0.3),
        ).animate(onPlay: (c) => c.repeat()).fade(
          delay: Duration(milliseconds: i * 200),
          duration: 600.ms,
        );
      }),
    );
  }
}

MarkdownStyleSheet _obsidianMarkdownStyle() {
  return MarkdownStyleSheet(
    p: ObsidianTypography.bodyMedium.copyWith(height: 1.6),
    strong: ObsidianTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700),
    em: ObsidianTypography.bodyMedium.copyWith(fontStyle: FontStyle.italic),
    code: ObsidianTypography.bodyMedium.copyWith(
      fontFamily: 'monospace',
      color: ObsidianColors.accent,
      backgroundColor: ObsidianColors.surfaceContainerLowest,
    ),
    codeblockDecoration: BoxDecoration(
      color: ObsidianColors.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(ObsidianShapes.radiusSM),
      border: Border.all(color: ObsidianColors.border),
    ),
    h1: ObsidianTypography.displayMedium.copyWith(fontSize: 20),
    h2: ObsidianTypography.displayMedium.copyWith(fontSize: 18),
    h3: ObsidianTypography.displayMedium.copyWith(fontSize: 16),
  );
}
