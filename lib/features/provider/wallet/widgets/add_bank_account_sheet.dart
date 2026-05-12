import 'package:app_incide/core/constants/app_strings.dart';
import 'package:app_incide/core/utils/bank_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_incide/core/utils/app_formatters.dart';
import 'package:app_incide/features/provider/wallet/providers/bank_accounts_provider.dart';

class AddBankAccountSheet extends ConsumerStatefulWidget {
  const AddBankAccountSheet({super.key});

  @override
  ConsumerState<AddBankAccountSheet> createState() =>
      _AddBankAccountSheetState();
}

class _AddBankAccountSheetState extends ConsumerState<AddBankAccountSheet> {
  final _holderController = TextEditingController();
  final _clabeController = TextEditingController();

  String? _identifiedBank;
  String? _clabeError;

  @override
  void dispose() {
    _holderController.dispose();
    _clabeController.dispose();
    super.dispose();
  }

  void _saveAccount() {
    final holder = _holderController.text.trim();
    final clabe = _clabeController.text.trim();
    final bank =
        _identifiedBank != null &&
            _identifiedBank != AppStrings.walletNonIdentifiableBank
        ? _identifiedBank!
        : AppStrings.walletAnotherBank;

    // Validación sencilla pero estricta
    if (holder.isEmpty || clabe.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.walletPleaseFillBankInfo)),
      );
      return;
    }

    if (clabe.length != 18) {
      setState(() => _clabeError = AppStrings.walletClabeLengthError);
      return;
    }

    // Guardamos en el Provider
    ref
        .read(bankAccountsProvider.notifier)
        .addAccount(bankName: bank, holderName: holder, clabe: clabe);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.walletAddedBankSuccess),
        backgroundColor: Color(0xFF22C55E),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppStrings.walletAddBankTitle,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _holderController,
            inputFormatters: AppFormatters.nameFormatter, // Solo letras
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: AppStrings.walletAccountHolderLbl,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _clabeController,
            keyboardType: TextInputType.number,
            inputFormatters: AppFormatters.clabeFormatter,
            decoration: InputDecoration(
              labelText: AppStrings.walletClabeLbl,
              errorText: _clabeError,
              border: const OutlineInputBorder(),
            ),

            onChanged: (value) {
              if (_clabeError != null) setState(() => _clabeError = null);

              if (value.length >= 3) {
                final code = value.substring(0, 3);
                setState(() {
                  _identifiedBank =
                      clabeBankCodes[code] ??
                      AppStrings.walletNonIdentifiableBank;
                });
              } else {
                // Ocultamos la tarjeta si borra los números
                setState(() => _identifiedBank = null);
              }
            },
          ),
          const SizedBox(height: 16),

          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _identifiedBank == null
                ? const SizedBox.shrink() // Oculto si no hay banco
                : Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            _identifiedBank ==
                                AppStrings.walletNonIdentifiableBank
                            ? Colors.orange.shade50
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              _identifiedBank ==
                                  AppStrings.walletNonIdentifiableBank
                              ? Colors.orange.shade200
                              : Colors.green.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _identifiedBank ==
                                    AppStrings.walletNonIdentifiableBank
                                ? Icons.help_outline
                                : Icons.account_balance,
                            color:
                                _identifiedBank ==
                                    AppStrings.walletNonIdentifiableBank
                                ? Colors.orange.shade700
                                : Colors.green.shade700,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _identifiedBank!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    _identifiedBank ==
                                        AppStrings.walletNonIdentifiableBank
                                    ? Colors.orange.shade800
                                    : Colors.green.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _saveAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFF1E3A8A,
                ), // Azul principal de la app
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                AppStrings.walletSaveBankBtn,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
