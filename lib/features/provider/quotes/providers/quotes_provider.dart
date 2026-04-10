import 'package:app_incide/features/provider/dashboard/models/opportunity_model.dart';
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
        opportunityId: 'Opp-001',
        clientId: 'C-001',
        clientName: 'Cliente Anónimo',
        clientPhoneNumber: '6620000000',
        title: 'Construcción de Habitación',
        category: 'Albañilería',
        description: 'Necesito ampliar mi casa con un cuarto extra de 4x4m.',
        distance: '2.5 km',
        urgency: 'Proxima Semana',
        requestDate: DateTime.now().subtract(const Duration(days: 1)),
        dateQuoteSent: DateTime.now().subtract(const Duration(hours: 2)),
        finalPrice: 8000,
        status: QuoteStatus.pending,
        isExclusive: true,
      ),
      QuoteModel(
        id: 'Q-002',
        opportunityId: 'Opp-002',
        clientId: 'C-002',
        clientName: 'Angie Serna',
        clientAvatarUrl: null,
        clientPhoneNumber: '6621234567',

        // DATOS HEREDADOS (Ahora empatan perfecto)
        title: 'Instalación de 4 Minisplits (2 Ton)',
        category: 'Climatización',
        description:
            'El centro de carga hizo un chispazo y la mitad de la casa se quedó sin energía.',
        distance: 'Aprox. 4.2 km',
        urgency: 'Urgente',
        isExclusive: false,
        clientAnswers: const {
          '¿En qué piso será la instalación?': 'Segundo piso',
          '¿Los equipos son nuevos?': 'Sí, en caja sellada.',
        },
        photoUrls: const ['foto1.jpg', 'foto2.jpg'],

        // DATOS DE COTIZACIÓN
        requestDate: DateTime.now().subtract(const Duration(days: 3)),
        dateQuoteSent: DateTime.now().subtract(const Duration(days: 2)),
        finalPrice: 3200,
        status: QuoteStatus.accepted,
        unreadMessagesCount: 1,
      ),
      QuoteModel(
        id: 'Q-003',
        opportunityId: 'Opp-003',
        clientId: 'C-003',
        clientName: 'Carlos López',
        clientPhoneNumber: '6629998888',
        title: 'Reparación de Tubería',
        category: 'Plomería',
        description: 'Fuga de agua en el baño principal. Inundación leve.',
        distance: '3.1 km',
        urgency: 'Normal',
        requestDate: DateTime.now().subtract(const Duration(days: 10)),
        dateQuoteSent: DateTime.now().subtract(const Duration(days: 9)),
        finalPrice: 850,
        status: QuoteStatus.completed,
      ),
      QuoteModel(
        id: 'Q-004',
        opportunityId: 'Opp-105',
        clientId: 'C-005',
        clientName: 'Carlos Moreno',
        clientAvatarUrl:
            null, // Sin foto para probar el CircleAvatar con inicial
        clientPhoneNumber: '6622109876',
        clientAddress: 'Colonia Pitic, Hermosillo',

        // Datos heredados de la oportunidad
        title: 'Mantenimiento Preventivo de Mini Split',
        category: 'Climatización',
        description:
            'Se requiere limpieza profunda de evaporadora y condensadora. El equipo está funcionando pero ya le toca servicio antes de que empiece el calor fuerte.',
        distance: '1.2 km',
        urgency: 'Flexible',
        isExclusive: true, // Para probar el badge dorado en la lista

        clientAnswers: const {
          '¿Qué marca es el equipo?': 'Mirage Inverter',
          '¿A qué altura está la condensadora?':
              'En el techo de un primer piso.',
          '¿Cuenta con manguera de agua cerca?':
              'Sí, hay una toma en el patio.',
        },
        photoUrls: const ['https://ejemplo.com/split1.jpg'],

        // Datos de la cotización
        requestDate: DateTime.now().subtract(const Duration(hours: 12)),
        dateQuoteSent: DateTime.now().subtract(const Duration(hours: 10)),
        finalPrice: 850.0, // Tu precio propuesto
        status: QuoteStatus.pending, // Aparecerá en la pestaña de "En Espera"
        unreadMessagesCount: 0,
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

  /// Convierte una Oportunidad en una Cotización y la agrega a la lista
  void addQuoteFromOpportunity(OpportunityModel opp, double price) {
    final newQuote = QuoteModel(
      id: 'Q-${DateTime.now().millisecondsSinceEpoch}', // ID temporal
      opportunityId: opp.id,

      // Datos del Cliente (Mockeados hasta tener Backend real)
      clientId: 'C-${opp.id}',
      clientName: 'Cliente Interesado',
      clientPhoneNumber: '6620000000',

      // Sincronización Total (Heredado de la Oportunidad)
      title: opp.title,
      category: opp.category,
      description: opp.description,
      distance: opp.formattedDistance,
      urgency: opp.urgency,
      isExclusive: opp.isExclusive,
      clientAnswers: opp.clientAnswers,
      photoUrls: opp.photoUrls,

      // Datos de Negocio
      requestDate: DateTime.now(),
      dateQuoteSent: DateTime.now(),
      finalPrice: price,
      status: QuoteStatus.pending,
    );

    // Actualizamos el estado agregando la nueva cotización al inicio de la lista
    state = [newQuote, ...state];
  }

  // TODO: Agregar markAsCompleted() y sendMessage().
}
