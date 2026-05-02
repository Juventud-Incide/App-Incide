import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../domain/models/chat_message.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/message_bubble.dart';
import '../widgets/system_bubble.dart';

class ChatDetailScreen extends ConsumerWidget {
  final String chatId;
  final bool isAccepted;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    this.isAccepted = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el provider de mensajes
    final messages =
        ref.watch(chatProvider)[chatId] ??
        [
          ChatMessage(
            id: 'sys',
            content: 'INICIO DEL CHAT - COTIZACIÓN #$chatId',
            isMine: false,
            type: MessageType.system,
            timestamp: DateTime.now(),
          ),
        ];

    // 2. LA MAGIA: Invertimos el orden del arreglo en memoria.
    // Ahora el mensaje más reciente está en el index 0.
    final displayMessages = messages.reversed.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: ChatAppBar(
        isAccepted: isAccepted,
        realName: 'Angie Serna',
        serviceTitle: 'Instalación de 4 Minisplits (2 Ton)',
        onMarkAsCompleted: () {
          // Llamamos al Notifier y le decimos qué chat actualizar
          ref
              .read(chatProvider.notifier)
              .addSystemMessage(
                chatId,
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
          ChatInputBar(chatId: chatId),
        ],
      ),
    );
  }
}
