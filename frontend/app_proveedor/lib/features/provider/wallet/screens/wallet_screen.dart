import 'package:incide_core/core/constants/app_strings.dart';
import 'package:app_proveedor/features/provider/wallet/widgets/empty_transactions_state.dart';
import 'package:app_proveedor/features/shared/widgets/custom_provider_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_proveedor/features/provider/wallet/widgets/wallet_balance_card.dart';
import 'package:app_proveedor/features/provider/wallet/widgets/retained_balance_card.dart';
import 'package:app_proveedor/features/provider/wallet/widgets/transaction_list_item.dart';
import 'package:app_proveedor/features/provider/wallet/providers/wallet_provider.dart';
import 'package:intl/intl.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletProvider);

    final currencyFormatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );

    final now = DateTime.now();
    final currentMonthStr = DateFormat('MMMM', 'es').format(now);
    final formattedMonth =
        currentMonthStr[0].toUpperCase() +
        currentMonthStr.substring(1); // Capitalizar

    final monthlyIncome = walletState.transactions
        .where(
          (tx) =>
              tx.type == TransactionType.income &&
              tx.date.month == now.month &&
              tx.date.year == now.year,
        )
        .fold(0.0, (sum, tx) => sum + tx.amount);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomProviderAppBar(title: AppStrings.walletMyWalletTitle),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WalletBalanceCard(),
            const SizedBox(height: 16),

            const RetainedBalanceCard(),
            const SizedBox(height: 32),

            // 3. Título para la lista de movimientos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  AppStrings.walletRecentTransactionsTitle,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Textito con el acumulado del mes
                Text(
                  AppStrings.walletAccumulatedThisMonth
                      .replaceFirst('{month}', formattedMonth)
                      .replaceFirst(
                        '{amount}',
                        currencyFormatter.format(monthlyIncome),
                      ),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            walletState.transactions.isEmpty
                ? const EmptyTransactionsState() // Mostramos la tarjeta bonita si no hay datos
                : ListView.builder(
                    // Mostramos la lista si hay datos
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: walletState.transactions.length,
                    itemBuilder: (context, index) {
                      final tx = walletState.transactions[index];
                      return TransactionListItem(transaction: tx);
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
