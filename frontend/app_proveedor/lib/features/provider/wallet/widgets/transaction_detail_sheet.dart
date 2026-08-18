import 'package:incide_core/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_proveedor/features/provider/wallet/providers/wallet_provider.dart';

class TransactionDetailSheet extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailSheet({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final isPending = transaction.status == TransactionStatus.pendingRelease;

    final currencyFormatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );
    // Formato de fecha: 04/05/2026 • 14:30
    final dateFormatter = DateFormat('dd/MM/yyyy • HH:mm');

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (isPending) {
      statusColor = const Color(0xFFCA8A04);
      statusText = AppStrings.walletPendingReleaseTitle;
      statusIcon = Icons.watch_later_outlined;
    } else if (transaction.type == TransactionType.withdrawal) {
      statusColor = Colors.black87;
      statusText = AppStrings.walletWithdrawalReleaseTitle;
      statusIcon = Icons.check_circle_outline;
    } else {
      statusColor = const Color(0xFF16A34A);
      statusText = AppStrings.walletReleased;
      statusIcon = Icons.check_circle_outline;
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),

          // Título y Monto
          Text(
            transaction.title,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            '${isIncome ? '+' : '-'}${currencyFormatter.format(transaction.amount)} MXN',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: isIncome ? const Color(0xFF16A34A) : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Pastilla de Estado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 16, color: statusColor),
                const SizedBox(width: 6),
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Lista de Detalles
          _buildDetailRow(
            AppStrings.walletDestinationTitle,
            transaction.clientName,
          ),
          const Divider(height: 24),
          _buildDetailRow(AppStrings.walletSubtitleTitle, transaction.subtitle),
          const Divider(height: 24),
          _buildDetailRow(
            AppStrings.walletDateTitle,
            dateFormatter.format(transaction.date),
          ),
          const Divider(height: 24),
          _buildDetailRow(AppStrings.walletTransactionIdTitle, transaction.id),

          const SizedBox(height: 32),

          // Botón para cerrar
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade100,
                foregroundColor: Colors.black87,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                AppStrings.walletCloseDetailBtn,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget de ayuda para construir las filas de detalles
  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}
