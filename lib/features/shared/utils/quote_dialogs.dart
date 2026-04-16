import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_incide/core/constants/app_strings.dart';
import 'package:app_incide/features/provider/quotes/providers/quotes_provider.dart';

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
}
