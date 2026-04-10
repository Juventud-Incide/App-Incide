import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quote_model.dart';

// ==========================================
// EL CONTROLADOR DE ESTADO (CEREBRO)
// ==========================================

/// Proveedor global que expone la lista de cotizaciones y sus métodos.
final quotesProvider = NotifierProvider<QuotesNotifier, List<QuoteModel>>(() {
  return QuotesNotifier();
});

class QuotesNotifier extends Notifier<List<QuoteModel>> {
  @override
  List<QuoteModel> build() {
    // Inicializamos el estado con los datos de prueba
    return [
      QuoteModel(
        id: 'Q-001',
        clientId: 'C-001',
        clientName: 'Cliente Anónimo',
        clientPhoneNumber: '6620000000',
        serviceCategory: 'Construcción de Habitación',
        problemDescription:
            'Necesito ampliar mi casa con un cuarto extra de 4x4m.',
        requestDate: DateTime.now().subtract(const Duration(days: 1)),
        dateQuoteSent: DateTime.now().subtract(const Duration(hours: 2)),
        estimatedPrice: 8000,
        status: QuoteStatus.pending,
      ),
      QuoteModel(
        id: 'Q-002',
        clientId: 'C-002',
        clientName: 'Angie Serna',
        clientPhoneNumber: '6621234567',
        serviceCategory: 'Instalación de 4 Minisplits (2 Ton)',
        problemDescription:
            'El centro de carga hizo un chispazo y la mitad de la casa se quedó sin energía.',
        requestDate: DateTime.now().subtract(const Duration(days: 3)),
        dateQuoteSent: DateTime.now().subtract(const Duration(days: 2)),
        estimatedPrice: 3200,
        status: QuoteStatus.accepted,
        unreadMessagesCount: 1,
      ),
      QuoteModel(
        id: 'Q-003',
        clientId: 'C-003',
        clientName: 'Carlos López',
        clientPhoneNumber: '6629998888',
        serviceCategory: 'Reparación de Tubería',
        problemDescription:
            'Fuga de agua en el baño principal. Inundación leve.',
        requestDate: DateTime.now().subtract(const Duration(days: 10)),
        dateQuoteSent: DateTime.now().subtract(const Duration(days: 9)),
        estimatedPrice: 850,
        status: QuoteStatus.completed,
      ),
    ];
  }

  /// Cambia el estado de una cotización a 'Cancelada'
  void retractProposal(String quoteId) {
    // Recorremos la lista actual. Si encontramos el ID, creamos una copia de esa
    // cotización pero con el estatus Cancelled. El resto se queda igual.
    state = [
      for (final quote in state)
        if (quote.id == quoteId)
          quote.copyWith(status: QuoteStatus.cancelled)
        else
          quote,
    ];
  }

  // TODO: Agregar markAsCompleted() y sendMessage().
}
