import 'package:flutter/material.dart';
import '../domain/models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  // Renderiza el ícono de las palomitas (solo si es un mensaje enviado por el usuario)
  Widget _buildStatusIcon() {
    if (!message.isMine) return const SizedBox.shrink();

    IconData icon;
    Color color;

    switch (message.status) {
      case MessageStatus.sent:
        icon = Icons.check;
        color = Colors.grey;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.grey;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = Colors.blueAccent;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Icon(icon, size: 14, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;

    final bubbleColor = isMine ? const Color(0xFFE6EFFF) : Colors.white;
    final textColor = const Color(0xFF334155);

    // Formateador de tiempo básico (Ej: 10:15 am)
    final isPm = message.timestamp.hour >= 12;
    final hour = message.timestamp.hour > 12
        ? message.timestamp.hour - 12
        : (message.timestamp.hour == 0 ? 12 : message.timestamp.hour);
    final minute = message.timestamp.minute.toString().padLeft(2, '0');
    final timeString = "$hour:$minute ${isPm ? 'pm' : 'am'}";

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(12.0).copyWith(
            bottomRight: isMine
                ? const Radius.circular(0)
                : const Radius.circular(12.0),
            bottomLeft: !isMine
                ? const Radius.circular(0)
                : const Radius.circular(12.0),
          ),
          border: isMine ? null : Border.all(color: Colors.grey[300]!),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: isMine
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (message.type == MessageType.image)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(message.content, fit: BoxFit.cover),
                ),

              if (message.type == MessageType.image && message.caption != null)
                const SizedBox(height: 8.0),

              if (message.type == MessageType.text)
                Text(
                  message.content,
                  style: TextStyle(color: textColor, fontSize: 14, height: 1.3),
                ),
              if (message.type == MessageType.image && message.caption != null)
                Text(
                  message.caption!,
                  style: TextStyle(color: textColor, fontSize: 14, height: 1.3),
                ),

              const SizedBox(height: 4.0),

              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    timeString,
                    style: TextStyle(color: Colors.grey[500], fontSize: 10),
                  ),
                  _buildStatusIcon(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
