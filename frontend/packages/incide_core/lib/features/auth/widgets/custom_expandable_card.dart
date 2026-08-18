import 'package:flutter/material.dart';
import 'package:incide_core/core/theme/app_colors.dart';

/// Tarjeta interactiva para mostrar errores y solicitar correcciones al usuario.
///
/// **UX / UI Dinámica:**
/// Este componente cambia drásticamente su diseño basado en el estado `isCompleted`.
/// - **Incompleto (Error):** Bordes rojos, ícono de advertencia, muestra el mensaje de
///   retroalimentación (feedback) del revisor y permite ser tocada para re-subir el archivo.
/// - **Completado:** Cambia a colores primarios/verdes, deshabilita el onTap para prevenir
///   múltiples subidas innecesarias, y oculta la caja de comentarios de error.
class CustomExpandableCard extends StatelessWidget {
  /// Nombre del requerimiento (ej. "Identificación Oficial").
  final String title;

  /// Subtítulo indicando la acción requerida o el estado actual.
  final String subtitle;

  /// El mensaje textual que el administrador dejó explicando por qué rechazó el documento.
  final String? feedbackMessage;

  /// Define si la tarjeta debe mostrar el estado de error o el estado corregido.
  final bool isCompleted;

  /// Callback que se dispara al tocar la tarjeta (generalmente para abrir la cámara/galería).
  final ValueChanged<bool> onActionTapped;

  const CustomExpandableCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.feedbackMessage,
    required this.isCompleted,
    required this.onActionTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.primaryBlue.withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isCompleted ? AppColors.primaryBlue : Colors.redAccent,
          width: isCompleted ? 2 : 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            // Bloquea la interacción si el documento ya fue corregido
            onTap: isCompleted ? null : () => onActionTapped(true),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),

            // Fix UI: CircleAvatar se adapta automáticamente sin tamaños fijos
            leading: CircleAvatar(
              backgroundColor: isCompleted
                  ? AppColors.primaryBlue
                  : Colors.red.withValues(alpha: 0.1),
              radius: 22, // Radio relativo en lugar de width/height absolutos
              child: Icon(
                isCompleted
                    ? Icons.check_circle_rounded
                    : Icons.error_outline_rounded,
                color: isCompleted ? Colors.white : Colors.redAccent,
                size: 24,
              ),
            ),

            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isCompleted ? AppColors.primaryBlue : AppColors.textDark,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: TextStyle(
                color: isCompleted ? AppColors.primaryBlue : Colors.redAccent,
                fontSize: 13,
              ),
            ),
            trailing: isCompleted
                ? null
                : const Icon(
                    Icons.upload_file_rounded,
                    color: Colors.redAccent,
                  ),
          ),

          // Caja de comentarios de retroalimentación (Solo visible si hay error)
          if (!isCompleted && feedbackMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(14),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.comment_rounded,
                    color: Colors.redAccent,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    // Protege contra desbordamiento de texto
                    child: Text(
                      feedbackMessage!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.redAccent,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
