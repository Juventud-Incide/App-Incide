import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../domain/models/chat_message.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/message_bubble.dart';
import '../widgets/system_bubble.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String chatId;
  final bool isAccepted;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    this.isAccepted = false,
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Usamos addPostFrameCallback por seguridad en Flutter.
    // Esto le dice al framework: "Espera a que la pantalla termine de dibujarse
    // por primera vez, y justo después, ejecuta esta función".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatProvider.notifier).markMessagesAsRead(widget.chatId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages =
        ref.watch(chatProvider)[widget.chatId] ??
        [
          ChatMessage(
            id: 'sys',
            content: 'INICIO DEL CHAT - COTIZACIÓN #${widget.chatId}',
            isMine: false,
            type: MessageType.system,
            timestamp: DateTime.now(),
          ),
        ];
    final displayMessages = messages.reversed.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: ChatAppBar(
        isAccepted: widget.isAccepted,
        realName: 'Angie Serna', // A futuro esto vendrá de un provider
        serviceTitle: 'Instalación de 4 Minisplits (2 Ton)',
        onMarkAsCompleted: () {
          ref
              .read(chatProvider.notifier)
              .addSystemMessage(
                widget.chatId,
                'Has marcado este servicio como completado.',
              );
        },
      ),
      body: Column(
        children: [
          // Área de mensajes
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 20, top: 10),
              reverse: true,
              itemCount: displayMessages.length,
              itemBuilder: (context, index) {
                final message = displayMessages[index];

                if (message.type == MessageType.system) {
                  return SystemBubble(text: message.content);
                }

                return MessageBubble(message: message);
              },
            ),
          ),

          // Barra de entrada de texto
          ChatInputBar(chatId: widget.chatId),
        ],
      ),
    );
  }
}
