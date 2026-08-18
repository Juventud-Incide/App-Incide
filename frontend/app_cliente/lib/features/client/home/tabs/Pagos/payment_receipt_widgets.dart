import 'package:flutter/material.dart';
import 'package:incide_core/core/theme/app_colors.dart';
import '../../models/saved_card_model.dart';

// ─────────────────────────────────────────────────────────
// Mini vista previa de tarjeta en el diálogo CVV
// ─────────────────────────────────────────────────────────
class MiniCardPreview extends StatelessWidget {
  final SavedCardModel card;
  final LinearGradient gradient;

  const MiniCardPreview({super.key, required this.card, required this.gradient});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    height: 100,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.contactless_rounded, color: Colors.white54, size: 18),
            Text(
              card.brandLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        Text(
          card.maskedNumber,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────
// Ícono de estado (éxito / error)
// ─────────────────────────────────────────────────────────
class StatusIcon extends StatelessWidget {
  final Color color;
  final IconData icon;

  const StatusIcon({super.key, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
    width: 72,
    height: 72,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      shape: BoxShape.circle,
    ),
    child: Icon(icon, color: color, size: 42),
  );
}

// ─────────────────────────────────────────────────────────
// Comprobante de pago (folio, fecha, método, monto)
// ─────────────────────────────────────────────────────────
class PaymentReceiptCard extends StatelessWidget {
  final String folio;
  final String fecha;
  final String metodoPago;
  final double monto;

  const PaymentReceiptCard({
    super.key,
    required this.folio,
    required this.fecha,
    required this.metodoPago,
    required this.monto,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFF0FDF4),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.successGreen.withValues(alpha: 0.3)),
    ),
    child: Column(
      children: [
        const Text(
          'COMPROBANTE',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: AppColors.successGreen,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        _fila('Folio', folio),
        const SizedBox(height: 6),
        _fila('Método', metodoPago),
        const SizedBox(height: 6),
        _fila('Total', '\$${monto.toStringAsFixed(2)} MXN'),
        const SizedBox(height: 6),
        _fila('Fecha', fecha),
      ],
    ),
  );

  Widget _fila(String label, String valor) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textGray)),
      Text(
        valor,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
    ],
  );
}
