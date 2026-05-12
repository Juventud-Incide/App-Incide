import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import 'saved_cards_sheet.dart';
import 'spei_transfer_sheet.dart';

// ─────────────────────────────────────────────────────────
// Bottom Sheet: Selección de Método de Pago
// ─────────────────────────────────────────────────────────
class PaymentMethodSheet extends StatelessWidget {
  final double monto;
  final String titulo;

  const PaymentMethodSheet({
    super.key,
    required this.monto,
    required this.titulo,
  });

  static Future<void> show(
    BuildContext context, {
    required double monto,
    required String titulo,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaymentMethodSheet(monto: monto, titulo: titulo),
    );
  }

  @override
  Widget build(BuildContext context) {
    final montoFmt =
        '\$${monto.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (m) => '${m[1]},')} MXN';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.borderDark,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // Encabezado
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.payment_rounded,
                  color: AppColors.primaryBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Método de pago',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Monto badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.successGreen.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  montoFmt,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.successGreen,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Título sección
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Selecciona cómo pagar',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textMedium,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Opción 1: Tarjeta crédito/débito ─────────────────────────────
          // Ahora abre SavedCardsSheet (que muestra tarjetas guardadas + agregar nueva)
          _PaymentOptionTile(
            icon: Icons.credit_card_rounded,
            title: 'Tarjeta de crédito / débito',
            subtitle: 'Visa, Mastercard, American Express',
            color: AppColors.primaryBlue,
            onTap: () {
              final parentCtx = Navigator.of(context).context;
              Navigator.pop(context);
              SavedCardsSheet.show(parentCtx, monto: monto, titulo: titulo);
            },
          ),

          const SizedBox(height: 10),

          // ── Opción 2: Transferencia SPEI ──────────────────────────────────
          _PaymentOptionTile(
            icon: Icons.account_balance_rounded,
            title: 'Transferencia SPEI',
            subtitle: 'Pago por transferencia bancaria',
            color: const Color(0xFF7C3AED),
            onTap: () {
              final parentCtx = Navigator.of(context).context;
              Navigator.pop(context);
              SpeiTransferSheet.show(parentCtx, monto: monto, titulo: titulo);
            },
          ),

          const SizedBox(height: 20),

          // Cancelar
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: AppColors.textGray,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Tile de opción de pago
// ─────────────────────────────────────────────────────────
class _PaymentOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _PaymentOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.18), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
