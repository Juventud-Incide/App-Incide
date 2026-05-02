import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/chat_message.dart';

// 1. Usamos Notifier normal, manejando un Mapa (Diccionario) de chats por ID
class ChatNotifier extends Notifier<Map<String, List<ChatMessage>>> {
  @override
  Map<String, List<ChatMessage>> build() {
    return {'Q-002': _mockMessages};
  }

  void addSystemMessage(String chatId, String text) {
    // Obtenemos los mensajes actuales de ese chat (o creamos uno inicial si está vacío)
    final currentMessages =
        state[chatId] ??
        [
          ChatMessage(
            id: 'sys_init',
            content: 'INICIO DEL CHAT - COTIZACIÓN #$chatId',
            isMine: false,
            type: MessageType.system,
            timestamp: DateTime.now(),
          ),
        ];

    final newMessage = ChatMessage(
      id: DateTime.now().toString(),
      content: text,
      isMine: false,
      type: MessageType.system,
      timestamp: DateTime.now(),
    );

    // Clonamos el mapa global y actualizamos solo la lista del chat específico
    state = {
      ...state,
      chatId: [...currentMessages, newMessage],
    };
  }

  void sendTextMessage(String chatId, String text) {
    if (text.trim().isEmpty) return;

    final newMessage = ChatMessage(
      id: DateTime.now().toString(),
      content: text.trim(),
      isMine: true,
      type: MessageType.text,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    final currentMessages = state[chatId] ?? [];

    state = {
      ...state,
      chatId: [...currentMessages, newMessage],
    };
  }
}

// 2. El único Provider sobreviviente en Riverpod 3.0
final chatProvider =
    NotifierProvider<ChatNotifier, Map<String, List<ChatMessage>>>(() {
      return ChatNotifier();
    });

// ==========================================
// DATOS FALSOS BASADOS EN TU MOCKUP VISUAL
// ==========================================
final List<ChatMessage> _mockMessages = [
  ChatMessage(
    id: 'msg_0',
    content: 'HOY, 16 DE FEBRERO',
    isMine: false,
    type: MessageType.system,
    timestamp: DateTime(2026, 2, 16, 8, 0),
  ),
  ChatMessage(
    id: 'msg_1',
    content:
        'Hola Angie, muchas gracias por aceptar la cotización. Quedo agendado para mañana a las 10:00 AM. ¿Me podrías confirmar si los equipos ya están en planta baja o hay que subirlos a un techo?',
    isMine: true,
    type: MessageType.text,
    timestamp: DateTime(2026, 2, 16, 10, 15),
    status: MessageStatus.read,
  ),
  ChatMessage(
    id: 'msg_2',
    content:
        'Hola Ángel. Qué bueno saludarte. Sí, mira te paso la foto, los equipos están en la cochera, pero la instalación de 2 de ellos es en el segundo piso.',
    isMine: false,
    type: MessageType.text,
    timestamp: DateTime(2026, 2, 16, 10, 30),
  ),
  ChatMessage(
    id: 'msg_3',
    content:
        'https://images.unsplash.com/photo-1605810230434-7631ac76ec81?auto=format&fit=crop&q=80&w=400',
    caption:
        'Hola Ángel. Qué bueno saludarte. Sí, mira te paso la foto, los equipos están en la cochera, pero la instalación de 2 de ellos es en el segundo piso.',
    isMine: false,
    type: MessageType.image,
    timestamp: DateTime(2026, 2, 16, 10, 31),
  ),
  ChatMessage(
    id: 'msg_4',
    content:
        'Perfecto, no hay problema, yo llevo el equipo para maniobras. Nos vemos mañana puntual.',
    isMine: true,
    type: MessageType.text,
    timestamp: DateTime(2026, 2, 16, 10, 31),
  ),
];
