enum SenderType { client, provider }

class ChatMessage {
  final String id;
  final String? text;
  final String? imageUrl;
  final SenderType sender;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    this.text,
    this.imageUrl,
    required this.sender,
    required this.timestamp,
    this.isRead = false,
  });
}
