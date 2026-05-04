import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_incide/features/provider/wallet/providers/wallet_provider.dart';

class TransactionListItem extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionListItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final currencyFormatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );

    // Determinamos el símbolo (+ o -) según el tipo de transacción
    final amountText =
        '${isIncome ? '+' : '-'}${currencyFormatter.format(transaction.amount)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Ícono circular (Verde si es ingreso, Gris si es retiro)
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: isIncome ? Colors.green.shade50 : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? const Color(0xFF22C55E) : Colors.grey.shade600,
              size: 20,
            ),
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
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
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
              color: isIncome ? const Color(0xFF16A34A) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
