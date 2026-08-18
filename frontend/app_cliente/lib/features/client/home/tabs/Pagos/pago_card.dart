import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:incide_core/core/theme/app_colors.dart';
import '../../models/pago_model.dart';
import '../../providers/pagos_providers.dart';
import 'payment_method_sheet.dart';

// ─────────────────────────────────────────────────────────
// Tarjeta de Pago
// ─────────────────────────────────────────────────────────
class PagoCard extends ConsumerWidget {
  final PagoModel pago;

  const PagoCard({super.key, required this.pago});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (
      Color badgeColor,
      String badgeLabel,
      IconData badgeIcon,
    ) = switch (pago.estado) {
      EstadoPago.pagado => (
        AppColors.successGreen,
        'Pagado',
        Icons.check_circle_rounded,
      ),
      EstadoPago.pendiente => (
        const Color(0xFFF59E0B),
        'Pendiente',
        Icons.hourglass_empty_rounded,
      ),
    };

    final fechaFmt = DateFormat('dd/MM/yyyy').format(pago.fecha);
    final isPendiente = pago.estado == EstadoPago.pendiente;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isPendiente
                ? const Color(0xFFF59E0B).withValues(alpha: 0.4)
                : AppColors.borderLight,
            width: isPendiente ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Fila superior: ícono + título + badge ───────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ícono del servicio
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    color: badgeColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Título y método de pago
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        pago.titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      if (!isPendiente) ...[
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(
                              Icons.credit_card_rounded,
                              size: 12,
                              color: AppColors.textGray,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              pago.metodoPago,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textGray,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Badge de estado
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: badgeColor.withValues(alpha: 0.3),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(badgeIcon, size: 10, color: badgeColor),
                      const SizedBox(width: 4),
                      Text(
                        badgeLabel,
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: AppColors.borderLight),
            const SizedBox(height: 12),

            // ── Fila inferior: monto + fecha + referencia ───────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Monto principal
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Monto',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textGray,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '\$${NumberFormat('#,##0.00').format(pago.monto)} MXN',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                // Fecha + referencia
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 11,
                          color: AppColors.textGray,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          fechaFmt,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textGray,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    if (pago.referencia != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        pago.referencia!,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textHint,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            // ── Botón Pagar (solo en pendientes) ────────────────────────────
            if (isPendiente) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => PaymentMethodSheet.show(
                    context,
                    monto: pago.monto,
                    titulo: pago.titulo,
                    onPaymentSuccess: (String metodo) {
                      ref.read(allPagosProvider.notifier).marcarComoPagado(pago.id, metodo);
                    },
                  ),
                  icon: const Icon(Icons.payment_rounded, size: 16),
                  label: const Text(
                    'Pagar ahora',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
