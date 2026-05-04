import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_incide/core/constants/app_strings.dart';
import 'package:app_incide/features/provider/quotes/providers/quotes_provider.dart';
import 'package:app_incide/features/provider/chat/providers/chat_provider.dart';

/// Clase utilitaria (Utility Class) para centralizar y gestionar diálogos modales.
///
/// **Propósito Arquitectónico:**
/// Extraer la lógica de las alertas (Alerts/Dialogs) fuera de los Widgets principales
/// ([ProfQuotesScreen] o [QuoteDetailScreen]) para mantener los métodos `build` limpios
/// y fomentar la reutilización. Al ser estáticos, se pueden invocar globalmente sin instanciar la clase.
class QuoteDialogs {
  /// Muestra el diálogo modal de confirmación antes de mutar el estado a 'Cancelada'.
  ///
  /// **Gestión de Contextos:**
  /// Es vital distinguir entre el [context] (la pantalla subyacente) y el
  /// `dialogContext` (el propio cuadro de diálogo). Esto evita errores de navegación
  /// donde Flutter cierra la pantalla equivocada.
  ///
  /// Parámetros:
  /// * [context]: El contexto del árbol de widgets desde donde se invoca.
  /// * [ref]: Referencia a Riverpod necesaria para leer y ejecutar el provider.
  /// * [quoteId]: El identificador único de la cotización a cancelar.
  /// * [popScreenAfter]: Bandera de enrutamiento. Si es `true`, tras cancelar la
  ///   cotización, el router hará un "pop" adicional para sacar al usuario de la
  ///   pantalla de detalles y devolverlo a la lista.
  static void showRetractConfirmation({
    required BuildContext context,
    required WidgetRef ref,
    required String quoteId,
    bool popScreenAfter = false,
  }) {
    showDialog(
      // Usamos el contexto de la pantalla padre para montar el modal
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.quoteAlertTitle),
        content: const Text(AppStrings.quoteAlertContent),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          // Acción Secundaria (Abortar)
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              AppStrings.quoteCancelLbl,
              style: TextStyle(color: Colors.grey),
            ),
          ),

          // Acción Primaria (Confirmar Destrucción)
          TextButton(
            onPressed: () {
              // 1. Mutación de Estado
              ref.read(quotesProvider.notifier).retractProposal(quoteId);

              // 2. Cerramos el modal usando estrictamente su propio contexto
              Navigator.pop(dialogContext);

              // 3. Lógica de Enrutamiento Condicional
              // La verificación `context.mounted` previene crashes si el usuario
              // cerró la app o navegó a otro lado mientras esto se procesaba.
              if (popScreenAfter && context.mounted) {
                context.pop();
              }

              // 4. Retroalimentación Visual (Feedback)
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(AppStrings.quoteRetiredLbl)),
                );
              }
            },
            child: const Text(
              AppStrings.quoteRetireLbl,
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> showCompletionDialog({
    required BuildContext context,
    required WidgetRef ref,
    required String chatId,
    required bool isCurrentlyCompleted,
  }) async {
    final title = !isCurrentlyCompleted
        ? '¿Marcar como completado?'
        : '¿Cancelar finalización?';
    final content = !isCurrentlyCompleted
        ? 'Se enviará una notificación al cliente para que confirme que el trabajo ha finalizado.'
        : 'El servicio volverá a estar en curso y el cliente ya no podrá confirmarlo.';
    final confirmText = !isCurrentlyCompleted
        ? 'Sí, completar'
        : 'Sí, cancelar';
    final confirmColor = !isCurrentlyCompleted
        ? Colors.green
        : Colors.redAccent;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        // 1. Centramos el título
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        // 2. Centramos el contenido para que haga simetría con el título
        content: Text(
          content,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade700, height: 1.4),
        ),
        // Ajustamos el padding para que los botones tengan buen espacio
        actionsPadding: const EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 16,
          top: 8,
        ),
        actions: [
          // 3. Fila con Expanded para lograr el 50% / 50%
          Row(
            children: [
              // Botón Volver (50%)
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text(
                      'Volver',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12), // Separación entre botones
              // Botón de Acción (50%)
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: Text(
                      confirmText,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref
          .read(chatProvider.notifier)
          .toggleServiceCompletion(chatId, !isCurrentlyCompleted);
    }
  }

  static void showSetPriceDialog({
    required BuildContext context,
    required WidgetRef ref,
    required String chatId,
    required double currentPrice,
  }) {
    final TextEditingController priceController = TextEditingController(
      text: currentPrice > 0 ? currentPrice.toStringAsFixed(2) : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.chatSetNewPrice),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(AppStrings.chatSetNewPriceHint),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: AppStrings.chatPriceLabel,
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text(
                      AppStrings.chatCancelPriceChange,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      final newPrice =
                          double.tryParse(priceController.text) ?? 0.0;

                      if (newPrice > 0) {
                        if (newPrice == currentPrice) {
                          Navigator.of(ctx).pop();
                          return;
                        }
                        // 1. Actualizar el precio en la "Base de Datos" (Provider)
                        ref
                            .read(quotesProvider.notifier)
                            .updateQuotePrice(chatId, newPrice);

                        // 2. Inyectar el mensaje de sistema en el chat
                        ref
                            .read(chatProvider.notifier)
                            .addSystemMessage(
                              chatId,
                              AppStrings.chatPriceChangedAlertTitle
                                  .replaceFirst(
                                    '{newPrice}',
                                    newPrice.toStringAsFixed(2),
                                  ),
                            );

                        Navigator.pop(ctx);
                      } else {
                        // Pequeña validación visual si el precio es inválido
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text(AppStrings.chatSetNewPriceInvalid),
                          ),
                        );
                      }
                    },
                    child: const Text(AppStrings.chatUpdatePriceBtn),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
