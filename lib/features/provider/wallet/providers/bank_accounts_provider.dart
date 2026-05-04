import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. El Modelo de la Cuenta Bancaria
class BankAccountModel {
  final String id;
  final String bankName;
  final String holderName;
  final String clabe;
  final bool isDefault;

  BankAccountModel({
    required this.id,
    required this.bankName,
    required this.holderName,
    required this.clabe,
    this.isDefault = false,
  });

  // Método útil para mostrar solo los últimos 4 dígitos en la UI
  String get lastFourDigits =>
      clabe.length >= 4 ? clabe.substring(clabe.length - 4) : '****';
}

// 2. El Notifier (Lógica de negocio)
class BankAccountsNotifier extends Notifier<List<BankAccountModel>> {
  @override
  List<BankAccountModel> build() {
    return [
      /*BankAccountModel(
        id: 'ACC-123',
        bankName: 'BBVA',
        holderName: 'Ángel Apáez',
        clabe: '012345678901234589',
        isDefault: true,
      ),*/
    ];
  }

  void addAccount({
    required String bankName,
    required String holderName,
    required String clabe,
  }) {
    // Si es la primera cuenta que agrega, la hacemos predeterminada automáticamente
    final isFirstAccount = state.isEmpty;

    final newAccount = BankAccountModel(
      id: 'ACC-${DateTime.now().millisecondsSinceEpoch}',
      bankName: bankName,
      holderName: holderName,
      clabe: clabe,
      isDefault: isFirstAccount,
    );

    // Si ya había cuentas, por ahora simplemente la agregamos al final
    state = [...state, newAccount];
  }
}

// 3. El Provider exportado
final bankAccountsProvider =
    NotifierProvider<BankAccountsNotifier, List<BankAccountModel>>(() {
      return BankAccountsNotifier();
    });
