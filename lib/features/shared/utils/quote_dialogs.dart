import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_incide/core/constants/app_strings.dart';
import 'package:app_incide/features/provider/quotes/providers/quotes_provider.dart';

class QuoteDialogs {
  /// Muestra el diálogo de confirmación para retirar una propuesta.
  /// [popScreenAfter] debe ser true si se llama desde la pantalla de Detalles.
  static void showRetractConfirmation({
    required BuildContext context,
    required WidgetRef ref,
    required String quoteId,
    bool popScreenAfter = false,
  }) {
    showDialog(
      // Usamos el contexto principal para el showDialog
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.quoteAlertTitle),
        content: const Text(AppStrings.quoteAlertContent),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              AppStrings.quoteCancelLbl,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(quotesProvider.notifier).retractProposal(quoteId);

              // Cerramos el diálogo usando su propio contexto
              Navigator.pop(dialogContext);

              // Si estamos en Detalles, retrocedemos una pantalla más
              if (popScreenAfter && context.mounted) {
                context.pop();
              }

              // Mostramos el mensaje de éxito
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
