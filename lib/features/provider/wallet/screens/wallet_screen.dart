import 'package:app_incide/features/provider/wallet/widgets/empty_transactions_state.dart';
import 'package:app_incide/features/shared/widgets/custom_provider_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_incide/features/provider/wallet/widgets/wallet_balance_card.dart';
import 'package:app_incide/features/provider/wallet/widgets/retained_balance_card.dart';
import 'package:app_incide/features/provider/wallet/widgets/transaction_list_item.dart';
import 'package:app_incide/features/provider/wallet/providers/wallet_provider.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomProviderAppBar(title: 'Mi Billetera'),
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
            const Text(
              'Movimientos Recientes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
