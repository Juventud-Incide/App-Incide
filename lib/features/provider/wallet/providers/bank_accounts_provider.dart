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

  // Añadimos copyWith para facilitar la actualización de estados
  BankAccountModel copyWith({
    String? id,
    String? bankName,
    String? holderName,
    String? clabe,
    bool? isDefault,
  }) {
    return BankAccountModel(
      id: id ?? this.id,
      bankName: bankName ?? this.bankName,
      holderName: holderName ?? this.holderName,
      clabe: clabe ?? this.clabe,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

// 2. El Notifier (Lógica de negocio)
class BankAccountsNotifier extends Notifier<List<BankAccountModel>> {
  @override
  List<BankAccountModel> build() {
    return [
      BankAccountModel(
        id: 'ACC-123',
        bankName: 'BBVA',
        holderName: 'Ángel Apáez',
        clabe: '012345678901234589',
        isDefault: true,
      ),
    ];
  }

  void addAccount({
    required String bankName,
    required String holderName,
    required String clabe,
  }) {
    // 1. Le quitamos el estatus de 'predeterminada' a todas las cuentas existentes
    final updatedExistingAccounts = state.map((account) {
      return account.copyWith(isDefault: false);
    }).toList();

    final newAccount = BankAccountModel(
      id: 'ACC-${DateTime.now().millisecondsSinceEpoch}',
      bankName: bankName,
      holderName: holderName,
      clabe: clabe,
      isDefault: true,
    );

    // Si ya había cuentas, por ahora simplemente la agregamos al final
    state = [newAccount, ...updatedExistingAccounts];
  }
}

// 3. El Provider exportado
final bankAccountsProvider =
    NotifierProvider<BankAccountsNotifier, List<BankAccountModel>>(() {
      return BankAccountsNotifier();
    });
