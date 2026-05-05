import 'package:app_incide/features/provider/dashboard/models/opportunity_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quote_model.dart';

// ==========================================
// EL CONTROLADOR DE ESTADO (CEREBRO)
// ==========================================

/// Proveedor global que expone la lista de cotizaciones del proveedor y sus métodos de acción.
///
/// Utiliza un [NotifierProvider] para mantener una lista reactiva de [QuoteModel].
/// Cualquier cambio en esta lista notificará automáticamente a las pestañas de
/// la pantalla 'Mis Cotizaciones'.
final quotesProvider = NotifierProvider<QuotesNotifier, List<QuoteModel>>(() {
  return QuotesNotifier();
});

/// Notificador que gestiona la lógica de las cotizaciones y su ciclo de vida.
///
/// Encargado de:
/// 1. Mantener el estado de las propuestas enviadas.
/// 2. Transformar Oportunidades en Cotizaciones.
/// 3. Gestionar cancelaciones y actualizaciones de estado.
class QuotesNotifier extends Notifier<List<QuoteModel>> {
  /// Inicializa el estado con datos mockeados para simular diferentes escenarios de UI.
  ///
  /// **Nota de Arquitectura:** En una fase de producción, este método dispararía
  /// una carga asíncrona desde un repositorio para obtener las cotizaciones del usuario autenticado.
  @override
  List<QuoteModel> build() {
    // Definición de assets temporales para pruebas visuales
    const String mockPhoto1 = 'https://picsum.photos/200?random=1';
    const String mockPhoto2 = 'https://picsum.photos/200?random=2';
    const String mockPhoto3 = 'https://picsum.photos/200?random=3';
    const String mockPhoto4 = 'https://picsum.photos/200?random=4';
    const String mockPhoto5 = 'https://picsum.photos/200?random=5';
    const String mockPhoto6 = 'https://picsum.photos/200?random=6';

    const String mockAvatar1 = 'https://picsum.photos/id/64/200/200';
    const String mockAvatar2 = 'https://picsum.photos/id/338/200/200';

    return [
      // Escenario 1: Cotización recién enviada (En Espera)
      QuoteModel(
        id: 'Q-001',
        opportunityId: 'Opp-001',
        clientId: 'C-001',
        clientName: 'Cliente Anónimo',
        clientAvatarUrl: null,
        clientPhoneNumber: '6620000000',
        clientAddress:
            null, // Privacidad: Dirección oculta hasta que sea aceptada.
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
        requestDate: DateTime.now().subtract(const Duration(days: 1)),
        dateQuoteSent: DateTime.now().subtract(const Duration(hours: 2)),
        finalPrice: 8000.0,
        status: QuoteStatus.pending,
        unreadMessagesCount: 0,
        providerMarkedCompleted: false,
        clientMarkedCompleted: false,
      ),

      // Escenario 2: Cotización aceptada por el cliente (Trabajo Activo)
      QuoteModel(
        id: 'Q-002',
        opportunityId: 'Opp-002',
        clientId: 'C-002',
        clientName: 'Angie Serna',
        clientAvatarUrl: mockAvatar1,
        clientPhoneNumber: '3245499695',
        clientAddress: 'Colonia Modelo, Hermosillo',
        title: 'Instalación de 4 Minisplits (2 Ton)',
        category: 'Climatización',
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
        requestDate: DateTime.now().subtract(const Duration(days: 3)),
        dateQuoteSent: DateTime.now().subtract(const Duration(days: 2)),
        finalPrice: 3200.0,
        status: QuoteStatus.accepted,
        unreadMessagesCount: 1, // Simulación de interacción activa.
        providerMarkedCompleted: false,
        clientMarkedCompleted: false,
      ),

      // Escenario 3: Trabajo finalizado (Histórico)
      QuoteModel(
        id: 'Q-003',
        opportunityId: 'Opp-003',
        clientId: 'C-003',
        clientName: 'Carlos López',
        clientAvatarUrl: mockAvatar2,
        clientPhoneNumber: '6629998888',
        clientAddress: 'Fracc. Puerta Real, Hermosillo',
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
        photoUrls: const [],
        requestDate: DateTime.now().subtract(const Duration(days: 10)),
        dateQuoteSent: DateTime.now().subtract(const Duration(days: 9)),
        finalPrice: 670.0,
        status: QuoteStatus.completed,
        unreadMessagesCount: 0,
        providerMarkedCompleted: true, // Consenso de finalización.
        clientMarkedCompleted: true,
      ),

      // Escenario 4: Cotización rechazada por el cliente.
      QuoteModel(
        id: 'Q-004',
        opportunityId: 'Opp-105',
        clientId: 'C-005',
        clientName: 'Carlos Moreno',
        clientAvatarUrl: null,
        clientPhoneNumber: '6622109876',
        clientAddress: 'Colonia Pitic, Hermosillo',
        title: 'Mantenimiento Preventivo de Mini Split',
        category: 'Climatización',
        description:
            'Se requiere limpieza profunda de evaporadora y condensadora. El equipo está funcionando pero ya le toca servicio antes de que empiece el calor fuerte.',
        distance: '1.2 km',
        urgency: 'Flexible',
        isExclusive: true,
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
        requestDate: DateTime.now().subtract(const Duration(hours: 12)),
        dateQuoteSent: DateTime.now().subtract(const Duration(hours: 10)),
        finalPrice: 850.0,
        status: QuoteStatus.rejected,
        unreadMessagesCount: 0,
      ),
    ];
  }

  /// Actualiza el estado de una cotización a [QuoteStatus.cancelled].
  ///
  /// Se utiliza cuando el proveedor decide retirar su propuesta económica.
  /// Aplica una actualización inmutable recorriendo la lista y reemplazando
  /// únicamente el objeto afectado.
  void retractProposal(String quoteId) {
    state = [
      for (final quote in state)
        if (quote.id == quoteId)
          quote.copyWith(status: QuoteStatus.cancelled)
        else
          quote,
    ];
  }

  /// Transforma una [OpportunityModel] del mercado en una [QuoteModel] activa.
  ///
  /// **Flujo de Negocio:**
  /// Este método es el que se dispara cuando el proveedor completa el modal de
  /// cotización. "Clona" la información estática de la oportunidad (título, descripción)
  /// y le añade los datos vivos de la negociación (precio propuesto).
  void addQuoteFromOpportunity(OpportunityModel opp, double price) {
    final newQuote = QuoteModel(
      id: 'Q-${DateTime.now().millisecondsSinceEpoch}', // Generación de ID temporal basado en timestamp.
      opportunityId: opp.id,

      // Datos iniciales de cliente (serán sustituidos por datos reales tras el handshake del backend).
      clientId: 'C-${opp.id}',
      clientName: 'Cliente Interesado',
      clientPhoneNumber: '6620000000',

      // Herencia de datos de la oportunidad original.
      title: opp.title,
      category: opp.category,
      description: opp.description,
      distance: opp.formattedDistance,
      urgency: opp.urgencyLabel,
      isExclusive: opp.isExclusive,
      clientAnswers: opp.clientAnswers,
      photoUrls: opp.photoUrls,

      requestDate: DateTime.now(),
      dateQuoteSent: DateTime.now(),
      finalPrice: price,
      status: QuoteStatus.pending,
    );

    // Actualización de estado agregando el nuevo elemento al inicio (LIFO).
    state = [newQuote, ...state];
  }

  // TODO: Implementar lógica de persistencia para `markAsCompleted()` y `sendMessage()`.
}
