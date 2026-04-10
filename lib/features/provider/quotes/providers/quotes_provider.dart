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
    const String mockPhoto1 = 'https://picsum.photos/200?random=1';
    const String mockPhoto2 = 'https://picsum.photos/200?random=2';
    const String mockPhoto3 = 'https://picsum.photos/200?random=3';
    const String mockPhoto4 = 'https://picsum.photos/200?random=4';
    const String mockPhoto5 = 'https://picsum.photos/200?random=5';
    const String mockPhoto6 = 'https://picsum.photos/200?random=6';

    const String mockAvatar1 = 'https://picsum.photos/id/64/200/200';
    const String mockAvatar2 = 'https://picsum.photos/id/338/200/200';

    return [
      QuoteModel(
        id: 'Q-001',
        opportunityId: 'Opp-001',
        clientId: 'C-001',
        clientName: 'Cliente Anónimo',
        clientAvatarUrl: null, // Sin foto
        clientPhoneNumber: '6620000000',
        clientAddress: null, // Nulo porque sigue "En Espera" (Privacidad)
        // DATOS HEREDADOS
        title: 'Construcción de Habitación',
        category: 'Albañilería',
        description:
            'Necesito ampliar mi casa con un cuarto extra de 4x4m en el patio trasero.',
        distance: '2.5 km',
        urgency: 'Próxima Semana',
        isExclusive: true,
        clientAnswers: const {
          '¿Cuenta con los materiales?':
              'No, requiero presupuesto con material incluido.',
          '¿El terreno está nivelado?': 'Sí, ya cuenta con firme de concreto.',
        },
        photoUrls: const [mockPhoto1, mockPhoto2, mockPhoto3],

        // DATOS DE COTIZACIÓN
        requestDate: DateTime.now().subtract(const Duration(days: 1)),
        dateQuoteSent: DateTime.now().subtract(const Duration(hours: 2)),
        finalPrice: 8000.0,
        status: QuoteStatus.pending,
        unreadMessagesCount: 0,
        providerMarkedCompleted: false,
        clientMarkedCompleted: false,
      ),

      QuoteModel(
        id: 'Q-002',
        opportunityId: 'Opp-002',
        clientId: 'C-002',
        clientName: 'Angie Serna',
        clientAvatarUrl: mockAvatar1,
        clientPhoneNumber: '3245499695',
        clientAddress:
            'Colonia Modelo, Hermosillo', // Revelado porque está Aceptada
        // DATOS HEREDADOS
        title: 'Instalación de 4 Minisplits (2 Ton)',
        category: 'Climatización',
        // Corregí la descripción para que coincida con el título
        description:
            'Se requiere instalar 4 equipos Mirage Inverter de 2 toneladas. La casa ya cuenta con la preparación eléctrica y tuberías ocultas.',
        distance: 'Aprox. 4.2 km',
        urgency: 'Urgente',
        isExclusive: false,
        clientAnswers: const {
          '¿En qué piso será la instalación?': 'Segundo piso',
          '¿Los equipos son nuevos?': 'Sí, en caja sellada.',
        },
        photoUrls: const [mockPhoto4, mockPhoto5],

        // DATOS DE COTIZACIÓN
        requestDate: DateTime.now().subtract(const Duration(days: 3)),
        dateQuoteSent: DateTime.now().subtract(const Duration(days: 2)),
        finalPrice: 3200.0,
        status: QuoteStatus.accepted,
        unreadMessagesCount: 1, // Simula que Angie te mandó un mensaje
        providerMarkedCompleted: false,
        clientMarkedCompleted: false,
      ),

      QuoteModel(
        id: 'Q-003',
        opportunityId: 'Opp-003',
        clientId: 'C-003',
        clientName: 'Carlos López',
        clientAvatarUrl: mockAvatar2,
        clientPhoneNumber: '6629998888',
        clientAddress:
            'Fracc. Puerta Real, Hermosillo', // Revelado porque está Completada
        // DATOS HEREDADOS
        title: 'Reparación de Tubería',
        category: 'Plomería',
        description:
            'Fuga de agua en el baño principal. Inundación leve debajo del lavabo.',
        distance: '3.1 km',
        urgency: 'Normal',
        isExclusive: false,
        clientAnswers: const {
          '¿Es tubería de PVC o Cobre?': 'Es de Cobre',
          '¿Hay que romper pared?':
              'No, la fuga está expuesta en la llave angular.',
        },
        photoUrls: const [], // Sin fotos
        // DATOS DE COTIZACIÓN
        requestDate: DateTime.now().subtract(const Duration(days: 10)),
        dateQuoteSent: DateTime.now().subtract(const Duration(days: 9)),
        finalPrice: 850.0,
        status: QuoteStatus.completed,
        unreadMessagesCount: 0,
        // Como ya está completada, ambas banderas deben estar en true
        providerMarkedCompleted: true,
        clientMarkedCompleted: true,
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
        photoUrls: const [
          mockPhoto6,
          mockPhoto4,
          mockPhoto3,
          mockPhoto5,
          mockPhoto1,
        ],

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
