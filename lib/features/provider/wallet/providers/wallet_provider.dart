import 'package:flutter_riverpod/flutter_riverpod.dart';

// ==========================================
// 1. MODELOS DE DATOS
// ==========================================

enum TransactionType { income, withdrawal, fee }

class TransactionModel {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final TransactionType type;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.date,
  });
}

class WalletState {
  final double availableBalance;
  final double retainedBalance;
  final bool isBalanceHidden; // Para el modo privacidad (el ojito)
  final List<TransactionModel> transactions;

  WalletState({
    this.availableBalance = 0.0,
    this.retainedBalance = 0.0,
    this.isBalanceHidden = false,
    this.transactions = const [],
  });

  WalletState copyWith({
    double? availableBalance,
    double? retainedBalance,
    bool? isBalanceHidden,
    List<TransactionModel>? transactions,
  }) {
    return WalletState(
      availableBalance: availableBalance ?? this.availableBalance,
      retainedBalance: retainedBalance ?? this.retainedBalance,
      isBalanceHidden: isBalanceHidden ?? this.isBalanceHidden,
      transactions: transactions ?? this.transactions,
    );
  }
}

// ==========================================
// 2. EL PROVIDER Y SU LÓGICA
// ==========================================

class WalletNotifier extends Notifier<WalletState> {
  @override
  WalletState build() {
    // Inicializamos con los datos exactos de tu Mockup para que puedas armar la UI
    return WalletState(
      availableBalance: 4500.00,
      retainedBalance: 3200.00,
      isBalanceHidden: false,
      transactions: _getMockTransactions(),
    );
  }

  // Alternar el modo privacidad
  void togglePrivacy() {
    state = state.copyWith(isBalanceHidden: !state.isBalanceHidden);
  }

  // Simulación de un retiro
  void requestWithdrawal(double amount) {
    if (amount > state.availableBalance || amount <= 0) return;

    final newWithdrawal = TransactionModel(
      id: 'W-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Retiro a Cuenta ***4589',
      subtitle: 'En proceso',
      amount: amount,
      type: TransactionType.withdrawal,
      date: DateTime.now(),
    );

    state = state.copyWith(
      availableBalance: state.availableBalance - amount,
      transactions: [newWithdrawal, ...state.transactions],
    );
  }

  // Cuando el consenso del chat finaliza un servicio, se llama esta función
  void releaseRetainedFunds(double amount, String serviceName) {
    final newIncome = TransactionModel(
      id: 'I-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Pago Liberado',
      subtitle: serviceName,
      amount: amount,
      type: TransactionType.income,
      date: DateTime.now(),
    );

    state = state.copyWith(
      retainedBalance: state.retainedBalance - amount,
      availableBalance: state.availableBalance + amount,
      transactions: [newIncome, ...state.transactions],
    );
  }

  // Datos de prueba basados en tu diseño
  List<TransactionModel> _getMockTransactions() {
    return [
      TransactionModel(
        id: 'T1',
        title: 'Pago Liberado',
        subtitle: 'Reparación Tubería',
        amount: 800.00,
        type: TransactionType.income,
        date: DateTime.now().subtract(const Duration(days: 1)), // Ayer
      ),
      TransactionModel(
        id: 'T2',
        title: 'Retiro a Cuenta ***4589',
        subtitle: '12 de Febrero',
        amount: 2000.00,
        type: TransactionType.withdrawal,
        date: DateTime(2026, 2, 12),
      ),
      // Añadí una extra para que tengas scroll
      TransactionModel(
        id: 'T3',
        title: 'Pago Liberado',
        subtitle: 'Mantenimiento Mini Split',
        amount: 1500.00,
        type: TransactionType.income,
        date: DateTime(2026, 2, 10),
      ),
    ];
  }
}

final walletProvider = NotifierProvider<WalletNotifier, WalletState>(() {
  return WalletNotifier();
});
