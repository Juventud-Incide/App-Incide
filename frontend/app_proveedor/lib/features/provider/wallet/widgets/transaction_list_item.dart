import 'package:app_incide/features/provider/wallet/widgets/transaction_detail_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_incide/features/provider/wallet/providers/wallet_provider.dart';

class TransactionListItem extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionListItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final isPending = transaction.status == TransactionStatus.pendingRelease;

    final currencyFormatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );

    // Determinamos el símbolo (+ o -) según el tipo de transacción
    final amountText =
        '${isIncome ? '+' : '-'}${currencyFormatter.format(transaction.amount)}';

    // Definimos colores e íconos dinámicamente
    Color iconColor;
    Color bgColor;
    IconData iconData;

    if (isPending) {
      iconColor = const Color(0xFFCA8A04);
      bgColor = const Color(0xFFFEF08A).withValues(alpha: 0.3);
      iconData = Icons.watch_later_outlined;
    } else if (isIncome) {
      iconColor = const Color(0xFF22C55E);
      bgColor = Colors.green.shade50;
      iconData = Icons.arrow_downward;
    } else {
      iconColor = Colors.grey.shade600;
      bgColor = Colors.grey.shade100;
      iconData = Icons.arrow_upward;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.0),
        onTap: () {
          // Abrimos el modal de detalles
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useRootNavigator: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            builder: (context) =>
                TransactionDetailSheet(transaction: transaction),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              // Ícono circular con fondo dinámico
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),

              // Título y Subtítulo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      transaction.subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Monto a la derecha
              Text(
                amountText,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isPending
                      ? const Color(0xFFCA8A04)
                      : (isIncome ? const Color(0xFF16A34A) : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
