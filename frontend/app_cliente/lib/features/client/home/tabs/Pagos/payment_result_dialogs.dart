import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import 'payment_receipt_widgets.dart';

// ─────────────────────────────────────────────────────────
// Diálogo: Pago exitoso con comprobante
// ─────────────────────────────────────────────────────────
class PaymentSuccessDialog extends StatelessWidget {
  final String folio;
  final String fecha;
  final String metodoPago;
  final double monto;
  final VoidCallback onDismiss;

  const PaymentSuccessDialog({
    super.key,
    required this.folio,
    required this.fecha,
    required this.metodoPago,
    required this.monto,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const StatusIcon(
              color: AppColors.successGreen,
              icon: Icons.check_circle_rounded,
            ),
            const SizedBox(height: 16),
            const Text(
              '¡Pago exitoso!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Tu pago fue procesado correctamente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textGray,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            PaymentReceiptCard(
              folio: folio,
              fecha: fecha,
              metodoPago: metodoPago,
              monto: monto,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDismiss,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Entendido',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Diálogo: Pago no procesado (Error con reintentar)
// ─────────────────────────────────────────────────────────
class PaymentErrorDialog extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onCancel;

  const PaymentErrorDialog({
    super.key,
    required this.onRetry,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const StatusIcon(
              color: AppColors.errorRed,
              icon: Icons.error_rounded,
            ),
            const SizedBox(height: 16),
            const Text(
              'Pago no procesado',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No pudimos procesar tu pago.\nVerifica los datos de tu tarjeta o intenta de nuevo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textGray,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: AppColors.borderDark),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        color: AppColors.textGray,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text(
                      'Reintentar',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
