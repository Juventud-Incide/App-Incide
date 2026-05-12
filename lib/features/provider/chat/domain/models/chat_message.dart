/// Tipos de mensajes soportados en el chat
enum MessageType {
  text,
  image,
  document,
  system, // Para fechas o alertas como "Servicio Completado"
}

/// Estado de lectura del mensaje (las famosas palomitas)
enum MessageStatus { sent, delivered, read }

class ChatMessage {
  final String id;
  final String content; // El texto o la URL de la imagen/documento
  final String? caption; // Texto opcional debajo de una imagen
  final bool
  isMine; // true = lo envió el proveedor, false = lo envió el Cliente
  final MessageType type;
  final DateTime timestamp;
  final MessageStatus status;

  ChatMessage({
    required this.id,
    required this.content,
    this.caption,
    required this.isMine,
    required this.type,
    required this.timestamp,
    this.status = MessageStatus.sent,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    String? caption,
    bool? isMine,
    MessageType? type,
    DateTime? timestamp,
    MessageStatus? status,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      caption: caption ?? this.caption,
      isMine: isMine ?? this.isMine,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
    );
  }
}
