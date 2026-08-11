import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_incide/features/provider/dashboard/models/opportunity_model.dart';

/// Notifier que gestiona el estado global de las oportunidades disponibles
class OpportunitiesNotifier extends Notifier<List<OpportunityModel>> {
  @override
  List<OpportunityModel> build() {
    // Aquí inicializamos nuestros datos de prueba.
    // TODO: (BACKEND) En el futuro, aquí harás una petición HTTP a tu API.
    return [
      OpportunityModel(
        id: 'OPP-001',
        title: 'Construcción de Habitación',
        description:
            'Construcción de una habitación de 30m2 en Hermosillo Centro, se tienen los planos.',
        distance: 2.5,
        isExclusive: true,
        category: 'Albañilería',
        urgency: 'Próxima semana',
        estimatedPriceMin: 15000,
        estimatedPriceMax: 20000,
        clientAnswers: {
          '¿Tienes material comprado?': 'Solo el cemento, falta la varilla.',
          '¿El terreno está nivelado?': 'Sí, listo para cimentar.',
        },
        // ¡URLs arregladas para que funcionen con CachedGalleryImage!
        photoUrls: const [
          'https://picsum.photos/200?random=10',
          'https://picsum.photos/200?random=11',
          'https://picsum.photos/200?random=12',
        ],
      ),
      OpportunityModel(
        id: 'OPP-002',
        title: 'Instalación de 4 Minisplits (2 Ton)',
        description:
            'Busco instalador certificado para colocar 4 equipos nuevos en oficinas. Solo mano de obra.',
        distance: 5.8,
        isExclusive: false,
        category: 'Refrigeración',
        urgency: 'Lo antes posible',
        estimatedPriceMin: 3200,
        estimatedPriceMax: 4000,
        clientAnswers: {
          '¿Los equipos son nuevos o usados?': 'Nuevos en caja cerrada.',
          '¿Hay preparación eléctrica previa?':
              'Sí, ya cuenta con pastillas a 220v.',
        },
        // ¡URLs arregladas!
        photoUrls: const [
          'https://picsum.photos/200?random=13',
          'https://picsum.photos/200?random=14',
          'https://picsum.photos/200?random=15',
        ],
      ),
    ];
  }

  /// Elimina una oportunidad por su ID
  void removeOpportunity(String id) {
    state = state.where((opp) => opp.id != id).toList();
  }

  /// Inserta una oportunidad en un índice específico (Útil para la función "Deshacer")
  void insertOpportunity(int index, OpportunityModel opp) {
    final newState = [...state];
    // Evitamos errores si el índice es mayor al tamaño actual de la lista
    final safeIndex = index > newState.length ? newState.length : index;
    newState.insert(safeIndex, opp);
    state = newState; // Actualizamos el estado para que la UI reaccione
  }
}

/// Proveedor global para acceder a la lista de oportunidades
final opportunitiesProvider =
    NotifierProvider<OpportunitiesNotifier, List<OpportunityModel>>(() {
      return OpportunitiesNotifier();
    });
