import 'dart:typed_data';

enum SenderType { client, provider, system }
enum AttachmentType { image, document }
enum SystemEventType { providerRequestedCompletion, clientConfirmedCompletion, readOnlyLock }

class Attachment {
  final AttachmentType type;
  final String path;
  final String name;
  final Uint8List? bytes;

  Attachment({
    required this.type,
    required this.path,
    required this.name,
    this.bytes,
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
  final SystemEventType? systemEvent;

  ChatMessage({
    required this.id,
    this.text,
    this.imageUrl,
    this.attachment,
    required this.sender,
    required this.timestamp,
    this.isRead = false,
    this.systemEvent,
  });
}
