import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:incide_core/core/constants/app_strings.dart';
import 'package:incide_core/core/theme/app_colors.dart';
import '../../chat/providers/chat_provider.dart';

/// Un botón reutilizable que envuelve la lógica del contador de mensajes no leídos.
///
/// **Propósito:**
/// Evitar duplicar el código del `Badge` y la lectura de Riverpod en las tarjetas
/// individuales de cotización (Activas/Pendientes) y en la pantalla de detalles.
class ChatButtonBadge extends ConsumerWidget {
  /// El ID de la cotización/chat para consultar sus mensajes.
  final String chatId;

  /// Callback de navegación, delegado al padre para mayor flexibilidad.
  final VoidCallback onPressed;

  /// Si es 'true', el botón tendrá fondo azul sólido y texto blanco.
  /// Si es 'false', tendrá fondo translúcido y texto azul.
  final bool isPrimaryStyle;

  const ChatButtonBadge({
    super.key,
    required this.chatId,
    required this.onPressed,
    this.isPrimaryStyle = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Leemos el proveedor derivado que creamos en chat_provider.dart
    final unreadCount = ref.watch(unreadCountProvider(chatId));

    return SizedBox(
      height: 48,
      child: Badge(
        // Solo mostramos el globo rojo si hay más de 0 mensajes
        isLabelVisible: unreadCount > 0,
        label: Text(
          unreadCount.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.redAccent,
        offset: const Offset(4, -4),

        // Estilos condicionales según el lugar donde se use
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(
            Icons.chat_bubble_outline_rounded,
            size: 18,
            color: isPrimaryStyle ? Colors.white : AppColors.primaryBlue,
          ),
          label: Text(
            AppStrings.quoteOpenChatBtn,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isPrimaryStyle ? Colors.white : AppColors.primaryBlue,
            ),
          ),
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: isPrimaryStyle
                ? AppColors.primaryBlue
                : AppColors.primaryBlue.withValues(alpha: 0.1),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            // Aseguramos que el botón ocupe todo el ancho disponible
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      ),
    );
  }
}
