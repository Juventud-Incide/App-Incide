enum MessageType { text, image, document, system }

class ChatMessage {
  final String id;
  final String text; // Para texto o la URL de la imagen
  final bool isMine; // true = proveedor, false = cliente
  final MessageType type;
  final DateTime timestamp;
  final bool isRead; // Para las dos palomitas azules

  ChatMessage({
    required this.id,
    required this.text,
    required this.isMine,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });
}
