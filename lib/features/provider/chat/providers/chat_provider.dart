import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/chat_message.dart';
import 'dart:async'; // Necesario para usar la clase Timer
import 'package:app_incide/features/provider/quotes/providers/quotes_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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

    // Lanzamos la simulación de respuesta sin usar 'await' para no bloquear la UI
    simulateClientReply(
      chatId,
      '¡Entendido! Muchas gracias por la información.',
    );
  }

  void sendImageMessage(String chatId, String imagePath, String? caption) {
    // 1. Creas el mensaje de tipo imagen pasándole la ruta local del archivo
    final newMessage = ChatMessage(
      id: DateTime.now().toString(),
      content: imagePath,
      caption: caption,
      isMine: true,
      type: MessageType.image,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    final currentMessages = state[chatId] ?? [];

    state = {
      ...state,
      chatId: [...currentMessages, newMessage],
    };
  }

  void sendDocumentMessage(String chatId, String filePath, String? caption) {
    final newMessage = ChatMessage(
      id: DateTime.now().toString(),
      content: filePath,
      caption: caption,
      isMine: true,
      type: MessageType.document,
      timestamp: DateTime.now(),
    );

    final currentMessages = state[chatId] ?? [];

    state = {
      ...state,
      chatId: [...currentMessages, newMessage],
    };
  }

  // Función para marcar como leídos los mensajes recibidos al abrir el chat
  void markMessagesAsRead(String chatId) {
    final currentMessages = state[chatId];
    if (currentMessages == null || currentMessages.isEmpty) return;

    bool changed = false;
    final updatedMessages = currentMessages.map((msg) {
      // Si el mensaje NO es mío y su estado NO es 'read', lo actualizamos
      if (!msg.isMine && msg.status != MessageStatus.read) {
        changed = true;
        return msg.copyWith(status: MessageStatus.read);
      }
      return msg;
    }).toList();

    // Solo repintamos el estado si realmente hubo cambios (optimización de memoria)
    if (changed) {
      state = {...state, chatId: updatedMessages};
    }
  }

  // Agrega esto dentro de tu clase ChatNotifier
  Future<void> simulateClientReply(String chatId, String text) async {
    // 1. Encendemos el indicador de "Escribiendo..." para este chat
    ref.read(typingProvider.notifier).setTyping(chatId, true);

    // 2. Simulamos el tiempo que tarda la persona en escribir (ej. 3 segundos)
    await Future.delayed(const Duration(seconds: 3));

    // 3. Apagamos el indicador
    ref.read(typingProvider.notifier).setTyping(chatId, false);

    // 4. Verificamos la "Presencia" del usuario
    final currentActiveChat = ref.read(activeChatProvider);
    final isUserInThisChat = currentActiveChat == chatId;

    // 5. Creamos el mensaje. Si el usuario está viendo el chat, nace como 'read'.
    // Si está en el menú, nace como 'delivered' (lo que sumará +1 al globo rojo).
    final newMessage = ChatMessage(
      id: DateTime.now().toString(),
      content: text,
      isMine: false,
      type: MessageType.text,
      timestamp: DateTime.now(),
      status: isUserInThisChat ? MessageStatus.read : MessageStatus.delivered,
    );

    // 6. Insertamos el mensaje en la memoria
    final currentMessages = state[chatId] ?? [];
    state = {
      ...state,
      chatId: [...currentMessages, newMessage],
    };
  }

  // Guardamos el temporizador en memoria para poder cancelarlo si el usuario se arrepiente
  Timer? _completionTimer;

  void toggleServiceCompletion(String chatId, bool isCompleting) {
    if (isCompleting) {
      // 1. Mensaje de sistema inicial
      addSystemMessage(
        chatId,
        'Has marcado este servicio como completado. A la espera de confirmación del cliente.',
      );
      ref.read(quotesProvider.notifier).toggleProviderCompletion(chatId, true);

      // 2. Simulamos al cliente desde su app confirmando después de 5 segundos
      _completionTimer?.cancel();
      _completionTimer = Timer(const Duration(seconds: 5), () {
        final quotes = ref.read(quotesProvider);
        final currentQuote = quotes.firstWhere((q) => q.id == chatId);

        if (currentQuote.providerMarkedCompleted) {
          ref
              .read(quotesProvider.notifier)
              .toggleClientCompletion(chatId, true);
          addSystemMessage(
            chatId,
            'El cliente ha confirmado la finalización. El servicio ha sido cerrado con éxito.',
          );
        }
      });
    } else {
      // 4. El usuario canceló la finalización ANTES o DESPUÉS de que el cliente aceptara
      _completionTimer?.cancel();

      addSystemMessage(
        chatId,
        'Has cancelado la finalización. El servicio vuelve a estar en curso.',
      );
      ref.read(quotesProvider.notifier).toggleProviderCompletion(chatId, false);
    }
  }

  // Simula la petición a la base de datos para cargar mensajes antiguos
  Future<void> loadOlderMessages(String chatId) async {
    // Simulamos un retraso de red de 1.5 segundos
    await Future.delayed(const Duration(milliseconds: 1500));

    // Generamos unos mensajes antiguos falsos
    final olderMessages = List.generate(
      10,
      (index) => ChatMessage(
        id: 'old_msg_${DateTime.now().millisecondsSinceEpoch}_$index',
        content: 'Mensaje antiguo del historial #$index',
        isMine: index % 2 == 0, // Alternamos entre tuyos y del cliente
        type: MessageType.text,
        // Les ponemos fechas más viejas restando días/horas
        timestamp: DateTime.now().subtract(Duration(days: 1, hours: index)),
      ),
    );

    // Obtenemos los mensajes que ya tenemos para este chat específico
    final currentChatMessages = state[chatId] ?? [];

    state = {
      ...state,
      chatId: [...olderMessages.reversed, ...currentChatMessages],
    };
  }
}

// ==========================================
// 1. PROVIDER DE PRESENCIA (Chat Activo)
// ==========================================
class ActiveChatNotifier extends Notifier<String?> {
  @override
  String? build() => null; // Inicia sin ningún chat abierto

  void setActiveChat(String? chatId) {
    state = chatId;
  }
}

// ==========================================
// 2. PROVIDER DE ESCRIBIENDO (Typing)
// ==========================================
class TypingNotifier extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() => {}; // Inicia con un mapa vacío

  void setTyping(String chatId, bool isTyping) {
    // Clonamos el mapa y actualizamos solo el estado del chat específico
    state = {...state, chatId: isTyping};
  }
}

final chatProvider =
    NotifierProvider<ChatNotifier, Map<String, List<ChatMessage>>>(() {
      return ChatNotifier();
    });

final activeChatProvider = NotifierProvider<ActiveChatNotifier, String?>(() {
  return ActiveChatNotifier();
});

final typingProvider = NotifierProvider<TypingNotifier, Map<String, bool>>(() {
  return TypingNotifier();
});

// Proveedor derivado que calcula los mensajes no leídos de un chat específico
final unreadCountProvider = Provider.family<int, String>((ref, chatId) {
  final messages = ref.watch(chatProvider)[chatId] ?? [];

  // 2. Filtramos y contamos
  return messages.where((msg) {
    final isFromOther = !msg.isMine; // Que lo haya enviado la otra persona
    final isNotSystem =
        msg.type != MessageType.system; // Ignoramos mensajes del sistema
    final isUnread =
        msg.status != MessageStatus.read; // Que no esté marcado como leído

    return isFromOther && isNotSystem && isUnread;
  }).length;
});

/// Proveedor global que escucha los cambios de conectividad en tiempo real.
final networkStreamProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
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
    // status: MessageStatus.read,
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
    // status: MessageStatus.read,
  ),
  ChatMessage(
    id: 'msg_4',
    content:
        'Perfecto, no hay problema, yo llevo el equipo para maniobras. Nos vemos mañana puntual.',
    isMine: true,
    type: MessageType.text,
    timestamp: DateTime(2026, 2, 16, 10, 31),
    status: MessageStatus.sent,
  ),
];
