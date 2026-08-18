import 'package:flutter/material.dart';
import 'package:incide_core/core/theme/app_colors.dart';
import '../../models/saved_card_model.dart';
import 'payment_confirmation_flow.dart';

// ─────────────────────────────────────────────────────────
// Tile de tarjeta guardada (solo diseño visual)
// La lógica de confirmación está en payment_confirmation_flow.dart
// ─────────────────────────────────────────────────────────
class SavedCardTile extends StatelessWidget {
  final SavedCardModel card;
  final double monto;
  final VoidCallback onDelete;
  final void Function(String) onPaymentSuccess;

  const SavedCardTile({
    super.key,
    required this.card,
    required this.monto,
    required this.onDelete,
    required this.onPaymentSuccess,
  });

  LinearGradient get _gradient {
    final colors = switch (card.brand) {
      CardBrand.visa => (AppColors.primaryBlue, const Color(0xFF2D55C8)),
      CardBrand.mastercard => (const Color(0xFF1C1C2E), const Color(0xFF2D2D44)),
      CardBrand.amex => (const Color(0xFF006FCF), const Color(0xFF0050A0)),
    };
    return LinearGradient(
      colors: [colors.$1, colors.$2],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(card.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: AppColors.errorRed.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete_rounded, color: AppColors.errorRed, size: 22),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Eliminar tarjeta', style: TextStyle(fontWeight: FontWeight.w800)),
          content: Text('¿Eliminar tarjeta ${card.brandLabel} •••• ${card.lastFour}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar', style: TextStyle(color: AppColors.errorRed)),
            ),
          ],
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // ← Una sola línea dispara todo el flujo de pago
          onTap: () => showPaymentConfirmationFlow(context, card: card, monto: monto, onPaymentSuccess: onPaymentSuccess),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: _gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _gradient.colors.first.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.contactless_rounded, color: Colors.white54, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.maskedNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${card.holderName}  ·  ${card.expiry}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    card.brandLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
