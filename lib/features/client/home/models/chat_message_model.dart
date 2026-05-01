enum SenderType { client, provider }
enum AttachmentType { image, document }

class Attachment {
  final AttachmentType type;
  final String path;
  final String name;

  Attachment({
    required this.type,
    required this.path,
    required this.name,
  });
}

class ChatMessage {
  final String id;
  final String? text;
  final String? imageUrl;
  final Attachment? attachment;
  final SenderType sender;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    required this.id,
    this.text,
    this.imageUrl,
    this.attachment,
    required this.sender,
    required this.timestamp,
    this.isRead = false,
  });
}
