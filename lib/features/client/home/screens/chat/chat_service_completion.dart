import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../models/chat_message_model.dart';
import '../../providers/home_providers.dart';

// ── Lógica de Completado de Servicio ───────────────────────────────────────
class ChatServiceCompletion {
  /// Marca el servicio como completado (confirmado por el cliente) e inyecta
  /// los mensajes de sistema correspondientes para cerrar el chat.
  static Future<void> markAsCompleted({
    required WidgetRef ref,
    required String cotId,
    required VoidCallback onScrollToBottom,
    required bool Function() isMounted,
  }) async {
    final messages = ref.read(chatMessagesProvider)[cotId] ?? [];
    if (hasClientConfirmed(messages)) return;

    // Inyectar burbuja de sistema: "Confirmaste la finalización..."
    ref
        .read(chatMessagesProvider.notifier)
        .sendMessage(
          cotId,
          'Confirmaste la finalización. El servicio ha sido completado.',
          SenderType.system,
          systemEvent: SystemEventType.clientConfirmedCompletion,
        );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (isMounted()) onScrollToBottom();
    });

    // Esperar 1.5 segundos antes de inyectar el mensaje de bloqueo
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!isMounted()) return;

    // Actualizar el estado de la cotización a "Terminada"
    ref.read(allCotizacionesProvider.notifier).markAsCompleted(cotId);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (isMounted()) onScrollToBottom();
    });
  }

  /// Verifica si el proveedor ya envió la solicitud de completado.
  static bool hasProviderRequested(List<ChatMessage> messages) {
    return messages.any(
      (m) => m.systemEvent == SystemEventType.providerRequestedCompletion,
    );
  }

  /// Verifica si el cliente ya confirmó el completado.
  static bool hasClientConfirmed(List<ChatMessage> messages) {
    return messages.any(
      (m) => m.systemEvent == SystemEventType.clientConfirmedCompletion,
    );
  }
}

// ── Burbuja de mensaje de sistema ──────────────────────────────────────────
class SystemBubble extends StatelessWidget {
  final ChatMessage message;
  const SystemBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.85,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6), // Gris claro neutral
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, size: 16, color: AppColors.textGray),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  message.text ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMedium,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Barra de solo lectura (chat bloqueado) ─────────────────────────────────
class ReadOnlyBar extends StatelessWidget {
  const ReadOnlyBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFFF3F4F6),
        border: Border(top: BorderSide(color: AppColors.borderLight, width: 1)),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_rounded,
              size: 16,
              color: AppColors.textGray.withOpacity(0.7),
            ),
            const SizedBox(width: 8),
            Text(
              'Este chat es de solo lectura',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textGray.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
