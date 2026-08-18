import 'package:incide_core/core/constants/app_strings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/chat_message.dart';
import 'dart:async';
import 'package:app_proveedor/features/provider/quotes/providers/quotes_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// 1. Usamos Notifier normal, manejando un Mapa (Diccionario) de chats por ID
class ChatNotifier extends Notifier<Map<String, List<ChatMessage>>> {
  @override
  Map<String, List<ChatMessage>> build() {
    return mockChats;
  }

  void addSystemMessage(String chatId, String text) {
    // Obtenemos los mensajes actuales de ese chat (o creamos uno inicial si está vacío)
    final currentMessages =
        state[chatId] ??
        [
          ChatMessage(
            id: 'sys_init',
            content: AppStrings.chatStartTitle,
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
      addSystemMessage(chatId, AppStrings.chatProviderCompleted);
      ref.read(quotesProvider.notifier).toggleProviderCompletion(chatId, true);

      _completionTimer?.cancel();
      _completionTimer = Timer(const Duration(seconds: 5), () {
        final quotes = ref.read(quotesProvider);
        final currentQuote = quotes.firstWhere((q) => q.id == chatId);

        if (currentQuote.providerMarkedCompleted) {
          addSystemMessage(chatId, AppStrings.chatClientCompleted);

          ref
              .read(quotesProvider.notifier)
              .toggleClientCompletion(chatId, true);

          Future.delayed(const Duration(milliseconds: 500), () {
            addSystemMessage(chatId, AppStrings.chatCompletionConfirmed);
          });
        }
      });
    } else {
      _completionTimer?.cancel();

      addSystemMessage(chatId, AppStrings.chatCancelCompletion);
      ref.read(quotesProvider.notifier).toggleProviderCompletion(chatId, false);
    }
  }

  // Simula la petición a la base de datos para cargar mensajes antiguos
  Future<void> loadOlderMessages(String chatId) async {
    // Simulamos un retraso de red de 1.5 segundos
    await Future.delayed(const Duration(milliseconds: 1500));

    // Generamos unos mensajes antiguos falsos
    final olderMessages = List.generate(
      50,
      (index) => ChatMessage(
        id: 'old_msg_${DateTime.now().millisecondsSinceEpoch}_$index',
        content: 'Mensaje antiguo del historial #$index',
        isMine: index % 2 == 0, // Alternamos entre tuyos y del cliente
        type: MessageType.text,
        // Les ponemos fechas más viejas restando días/horas
        timestamp: DateTime.now().subtract(Duration(days: 1, hours: index)),
        status: MessageStatus.read,
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
final mockChats = <String, List<ChatMessage>>{
  // =================================================================
  // CHAT 1: CONSTRUCCIÓN DE HABITACIÓN (Pendiente - Activo)
  // ID: 'Q-001'
  // =================================================================
  'Q-001': [
    ChatMessage(
      id: 'q001_sys',
      content: 'INICIO DEL CHAT - COTIZACIÓN #Q-001',
      isMine: false,
      type: MessageType.system,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
    ),
    ChatMessage(
      id: 'q001_m1',
      content:
          'Buen día. Necesito ampliar mi casa con un cuarto extra de 4x4m en el patio trasero. ¿Podrían hacerme un presupuesto?',
      isMine: false,
      type: MessageType.text,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
    ),
    ChatMessage(
      id: 'q001_m2',
      content:
          '¡Hola! Claro que sí, con gusto lo revisamos. Para darte un estimado más preciso, ¿tendrás alguna foto del patio donde se planea la construcción?',
      isMine: true,
      type: MessageType.text,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      status: MessageStatus.read,
    ),
    ChatMessage(
      id: 'q001_m3',
      content:
          'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?q=80&w=400&auto=format&fit=crop',
      caption:
          'Te comparto la foto. La idea es levantarlo pegado a la barda del fondo.',
      isMine: false,
      type: MessageType.image,
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    ChatMessage(
      id: 'q001_m4',
      content:
          'Perfecto, ya veo el espacio. El terreno se ve nivelado, lo cual ayuda mucho. Te preparo la cotización desglosada con material y mano de obra, te la envío por aquí en un par de horas.',
      isMine: true,
      type: MessageType.text,
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      status: MessageStatus.sent,
    ),
  ],

  // =================================================================
  // CHAT 2: INSTALACIÓN DE EQUIPOS (Tu Mock Original)
  // ID: 'Q-002'
  // =================================================================
  'Q-002': [
    ChatMessage(
      id: 'q002_sys',
      content: 'INICIO DEL CHAT - COTIZACIÓN #Q-002',
      isMine: false,
      type: MessageType.system,
      timestamp: DateTime(2026, 2, 16, 10, 0),
    ),
    ChatMessage(
      id: 'q002_m1',
      content:
          'Hola Angie, muchas gracias por aceptar la cotización. Quedo agendado para mañana a las 10:00 AM. ¿Me podrías confirmar si los equipos ya están en planta baja o hay que subirlos a un techo?',
      isMine: true,
      type: MessageType.text,
      timestamp: DateTime(2026, 2, 16, 10, 15),
      status: MessageStatus.read,
    ),
    ChatMessage(
      id: 'q002_m2',
      content:
          'Hola Ángel. Qué bueno saludarte. Sí, mira te paso la foto, los equipos están en la cochera, pero la instalación de 2 de ellos es en el segundo piso.',
      isMine: false,
      type: MessageType.text,
      timestamp: DateTime(2026, 2, 16, 10, 30),
    ),
    ChatMessage(
      id: 'q002_m3',
      content:
          'https://images.unsplash.com/photo-1605810230434-7631ac76ec81?auto=format&fit=crop&q=80&w=400',
      caption:
          'Hola Ángel. Qué bueno saludarte. Sí, mira te paso la foto, los equipos están en la cochera, pero la instalación de 2 de ellos es en el segundo piso.',
      isMine: false,
      type: MessageType.image,
      timestamp: DateTime(2026, 2, 16, 10, 31),
    ),
    ChatMessage(
      id: 'q002_m4',
      content:
          'Perfecto, no hay problema, yo llevo el equipo para maniobras. Nos vemos mañana puntual.',
      isMine: true,
      type: MessageType.text,
      timestamp: DateTime(2026, 2, 16, 10, 31),
      status: MessageStatus.sent,
    ),
  ],

  // =================================================================
  // CHAT 3: REPARACIÓN DE TUBERÍA (Completada - Solo Lectura)
  // ID: 'Q-003'
  // =================================================================
  'Q-003': [
    ChatMessage(
      id: 'q003_sys1',
      content: 'INICIO DEL CHAT - COTIZACIÓN #Q-003',
      isMine: false,
      type: MessageType.system,
      timestamp: DateTime.now().subtract(const Duration(days: 5, hours: 10)),
    ),
    ChatMessage(
      id: 'q003_m1',
      content:
          '¡Buenas tardes! Tengo una urgencia. Hay una fuga de agua en el baño principal y ya se me hizo una inundación leve debajo del lavabo, tuve que cerrar la llave de paso.',
      isMine: false,
      type: MessageType.text,
      timestamp: DateTime.now().subtract(const Duration(days: 5, hours: 9)),
    ),
    ChatMessage(
      id: 'q003_m2',
      content:
          'Buenas tardes. No te preocupes, tengo una cuadrilla cerca de la zona. Llegamos en 20 minutos para controlar la fuga.',
      isMine: true,
      type: MessageType.text,
      timestamp: DateTime.now().subtract(
        const Duration(days: 5, hours: 8, minutes: 40),
      ),
      status: MessageStatus.read,
    ),
    ChatMessage(
      id: 'q003_m3',
      content:
          'https://images.unsplash.com/photo-1585704032915-c3400ca199e7?q=80&w=400&auto=format&fit=crop',
      caption:
          'Listo, el problema era el empaque de la manguera flexible (coflex) que ya estaba muy desgastado. Se reemplazó por uno nuevo de acero trenzado y ya abrimos la llave de paso sin problemas.',
      isMine: true,
      type: MessageType.image,
      timestamp: DateTime.now().subtract(const Duration(days: 5, hours: 6)),
      status: MessageStatus.read,
    ),
    ChatMessage(
      id: 'q003_m4',
      content:
          'Excelente trabajo, muchas gracias por la rapidez. Quedo al pendiente de la factura.',
      isMine: false,
      type: MessageType.text,
      timestamp: DateTime.now().subtract(const Duration(days: 5, hours: 5)),
    ),
    ChatMessage(
      id: 'q003_sys2',
      content: 'SERVICIO MARCADO COMO COMPLETADO',
      isMine: false,
      type: MessageType.system,
      timestamp: DateTime.now().subtract(const Duration(days: 5, hours: 4)),
    ),
  ],

  // =================================================================
  // CHAT 4: MANTENIMIENTO MINI SPLIT (Rechazada - Solo Lectura)
  // ID: 'Q-004'
  // =================================================================
  'Q-004': [
    ChatMessage(
      id: 'q004_sys1',
      content: 'INICIO DEL CHAT - COTIZACIÓN #Q-004',
      isMine: false,
      type: MessageType.system,
      timestamp: DateTime.now().subtract(const Duration(days: 10, hours: 8)),
    ),
    ChatMessage(
      id: 'q004_m1',
      content:
          'Hola, buenas tardes. Requiero mantenimiento preventivo para un Mini Split de 1.5 toneladas. El equipo está funcionando bien, pero ya le toca servicio profundo (evaporadora y condensadora) antes de que se nos venga el calor fuerte de este mes.',
      isMine: false,
      type: MessageType.text,
      timestamp: DateTime.now().subtract(const Duration(days: 10, hours: 7)),
    ),
    ChatMessage(
      id: 'q004_m2',
      content:
          'Hola, claro que sí. Es muy buena idea hacerlo ahorita. El servicio profundo con lavado a presión y revisión de gas refrigerante lo tenemos en \$850 MXN. Tenemos disponibilidad para el próximo jueves por la mañana.',
      isMine: true,
      type: MessageType.text,
      timestamp: DateTime.now().subtract(const Duration(days: 10, hours: 5)),
      status: MessageStatus.read,
    ),
    ChatMessage(
      id: 'q004_m3',
      content:
          'Se me complica un poco la fecha, me urgía para esta misma semana por los horarios en los que estoy en casa. De igual forma te agradezco mucho la atención, voy a buscar otra opción más próxima. ¡Gracias!',
      isMine: false,
      type: MessageType.text,
      timestamp: DateTime.now().subtract(const Duration(days: 9, hours: 14)),
    ),
    ChatMessage(
      id: 'q004_m4',
      content:
          'Comprendo perfectamente. Quedamos a la orden para cualquier otro servicio en el futuro. ¡Excelente día!',
      isMine: true,
      type: MessageType.text,
      timestamp: DateTime.now().subtract(const Duration(days: 9, hours: 13)),
      status: MessageStatus.read,
    ),
    ChatMessage(
      id: 'q004_sys2',
      content: 'LA COTIZACIÓN FUE RECHAZADA POR EL CLIENTE',
      isMine: false,
      type: MessageType.system,
      timestamp: DateTime.now().subtract(const Duration(days: 9, hours: 12)),
    ),
  ],
};
