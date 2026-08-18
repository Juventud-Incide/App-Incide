import 'package:incide_core/core/constants/app_strings.dart';
import 'package:incide_core/core/utils/app_formatters.dart';
import 'package:app_proveedor/features/provider/wallet/providers/bank_accounts_provider.dart';
import 'package:app_proveedor/features/provider/wallet/widgets/add_bank_account_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:app_proveedor/features/provider/wallet/providers/wallet_provider.dart';

class WithdrawFundsSheet extends ConsumerStatefulWidget {
  const WithdrawFundsSheet({super.key});

  @override
  ConsumerState<WithdrawFundsSheet> createState() => _WithdrawFundsSheetState();
}

class _WithdrawFundsSheetState extends ConsumerState<WithdrawFundsSheet> {
  final TextEditingController _amountController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _validateAndSubmit(
    double availableBalance,
    BankAccountModel? selectedAccount,
  ) {
    // Protección extra: si no hay cuenta, no hace nada
    if (selectedAccount == null) return;

    final inputText = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(inputText) ?? 0.0;

    if (amount <= 0) {
      setState(() => _errorMessage = AppStrings.walletInvalidAmountError);
      return;
    }
    if (amount > availableBalance) {
      setState(() => _errorMessage = AppStrings.walletInsufficientFundsError);
      return;
    }
    ref
        .read(walletProvider.notifier)
        .requestWithdrawal(amount, selectedAccount);
    Navigator.pop(context);

    // Mostramos un mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.walletWithdrawalSuccess),
        backgroundColor: Color(0xFF22C55E),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos el saldo disponible actualizado
    final availableBalance = ref.watch(walletProvider).availableBalance;
    final currencyFormatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );

    final bankAccounts = ref.watch(bankAccountsProvider);
    final defaultAccount = bankAccounts
        .where((acc) => acc.isDefault)
        .firstOrNull;

    return Padding(
      // Este padding asegura que el teclado no tape el modal
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize:
            MainAxisSize.min, // Para que el modal se ajuste al contenido
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppStrings.walletWithdrawFundsTitle,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.walletAvailableBalance.replaceFirst(
              '{amount}',
              currencyFormatter.format(availableBalance),
            ),
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Campo de texto para el monto
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              prefixText: '\$ ',
              prefixStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              suffixText: AppStrings.walletSuffix,
              suffixStyle: const TextStyle(fontSize: 16, color: Colors.grey),
              labelText: AppStrings.walletWithdrawLabel,
              errorText: _errorMessage,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF1E3A8A),
                  width: 2,
                ),
              ),
              // Botón de "Max" integrado en el input
              suffixIcon: TextButton(
                onPressed: () {
                  final parts = availableBalance.toStringAsFixed(2).split('.');
                  final intPart = parts[0].replaceAllMapped(
                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                    (Match m) => '${m[1]},',
                  );

                  setState(() {
                    _amountController.text = '$intPart.${parts[1]}';
                    _errorMessage = null;
                  });
                },
                child: const Text(
                  AppStrings.walletMaxLbl,
                  style: TextStyle(
                    color: Color(0xFF1E3A8A),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            inputFormatters: AppFormatters.currencyFormatter,
            // 2. Lógica para limitar al saldo máximo disponible en tiempo real
            onChanged: (value) {
              // Limpiamos las comas para evaluar el valor real
              final cleanText = value.replaceAll(',', '');
              final amount = double.tryParse(cleanText) ?? 0.0;

              if (amount > availableBalance) {
                // Si excede, creamos el string formateado del límite máximo
                final parts = availableBalance.toStringAsFixed(2).split('.');
                final intPart = parts[0].replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (Match m) => '${m[1]},',
                );
                final maxFormatted = '$intPart.${parts[1]}';

                // Sobrescribimos el controlador forzando el cursor al final
                _amountController.value = TextEditingValue(
                  text: maxFormatted,
                  selection: TextSelection.collapsed(
                    offset: maxFormatted.length,
                  ),
                );

                // Mostramos aviso sutil
                setState(
                  () => _errorMessage = AppStrings.walletAdjustedAmountTitle,
                );
              } else {
                if (_errorMessage != null) setState(() => _errorMessage = null);
              }
            },
          ),
          const SizedBox(height: 24),

          defaultAccount != null
              ? Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance, color: Colors.grey),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            AppStrings.walletBankAccount,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Text(
                            AppStrings.walletBankAccountHolderAndLastDigits
                                .replaceFirst(
                                  '{bankName}',
                                  defaultAccount.bankName,
                                )
                                .replaceFirst(
                                  '{lastFourDigits}',
                                  defaultAccount.lastFourDigits,
                                ),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          // TODO: (EPIC: Perfil) Refactorizar para navegar a la pantalla 'ManageBankAccountsScreen'
                          // Por ahora (MVP), atajo directo para agregar nueva cuenta.
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (ctx) => const AddBankAccountSheet(),
                          );
                        },
                        child: const Text(AppStrings.walletChangeAccountBtn),
                      ),
                    ],
                  ),
                )
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF08A).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFEF08A)),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFCA8A04),
                      ),
                      const SizedBox(height: 8),
                      const Text(AppStrings.walletNoBankAccount),
                      TextButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            useRootNavigator: true,
                            builder: (ctx) => const AddBankAccountSheet(),
                          );
                        },
                        child: const Text(AppStrings.walletAddBankAccountBtn),
                      ),
                    ],
                  ),
                ),
          const SizedBox(height: 24),

          // Botón de Confirmación
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: defaultAccount != null
                  ? () => _validateAndSubmit(availableBalance, defaultAccount)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFF22C55E,
                ), // Mismo verde de la tarjeta
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                AppStrings.walletConfirmWithdrawalTitle,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 24), // Espaciado final inferior
        ],
      ),
    );
  }
}
