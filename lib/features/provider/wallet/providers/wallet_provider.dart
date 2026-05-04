import 'package:flutter_riverpod/flutter_riverpod.dart';

// ==========================================
// 1. MODELOS DE DATOS
// ==========================================

enum TransactionType { income, withdrawal, fee }

enum TransactionStatus { pendingRelease, released, processing, completed }

class TransactionModel {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final String clientName;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.status,
    required this.clientName,
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
      status: TransactionStatus.processing,
      clientName: 'Ángel Apáez (Tú)',
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
      status: TransactionStatus.released,
      clientName: 'Juan Pérez',
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
      // 1. Un ingreso ya liberado
      TransactionModel(
        id: 'TXN-982734',
        title: 'Pago Liberado',
        subtitle: 'Reparación Tubería',
        amount: 800.00,
        type: TransactionType.income,
        status: TransactionStatus.released,
        clientName: 'Juan Pérez',
        date: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      // 2. Un ingreso pendiente (En Garantía)
      TransactionModel(
        id: 'TXN-982735',
        title: 'Pago en Garantía',
        subtitle: 'Mantenimiento Mini Split',
        amount: 3200.00,
        type: TransactionType.income,
        status: TransactionStatus.pendingRelease,
        clientName: 'María García',
        date: DateTime.now(),
      ),
      // 3. Un retiro
      TransactionModel(
        id: 'WTH-10293',
        title: 'Retiro a Cuenta ***4589',
        subtitle: 'Retiro de fondos',
        amount: 2000.00,
        type: TransactionType.withdrawal,
        status: TransactionStatus.completed,
        clientName: 'Ángel Apáez (Tú)',
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }
}

final walletProvider = NotifierProvider<WalletNotifier, WalletState>(() {
  return WalletNotifier();
});
