import 'package:flutter/material.dart';

import '../../../core/theme/theme_ext.dart';
import '../model/companion_message.dart';
import 'typing_indicator.dart';

/// A single chat bubble. User turns sit right in a calm teal tint; the
/// companion sits left on an elevated surface. A still-empty streaming turn
/// shows the typing indicator; a failed turn reads gently, never alarmingly.
class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final CompanionMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final isTyping = message.streaming && message.text.isEmpty;

    final bg = isUser
        ? context.colors.primaryContainer
        : (message.failed
            ? context.palette.field
            : context.palette.surfaceElevated);
    final fg = isUser
        ? context.colors.onPrimaryContainer
        : (message.failed ? context.palette.muted : context.colors.onSurface);

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isUser ? 18 : 4),
      bottomRight: Radius.circular(isUser ? 4 : 18),
    );

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: radius,
          boxShadow: isUser
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: isTyping
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: TypingIndicator(),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.failed) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cloud_off_outlined,
                            size: 16, color: context.palette.muted,),
                        const SizedBox(width: 6),
                        Text(
                          'Not sent',
                          style: context.text.labelSmall
                              ?.copyWith(color: context.palette.muted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  SelectableText(
                    message.text,
                    style: context.text.bodyLarge?.copyWith(
                      color: fg,
                      height: 1.4,
                      fontStyle:
                          message.failed ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
