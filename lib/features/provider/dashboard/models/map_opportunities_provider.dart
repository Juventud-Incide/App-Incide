import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'opportunity_model.dart';

final mapOpportunitiesProvider =
    NotifierProvider<MapOpportunitiesNotifier, List<OpportunityModel>>(() {
      return MapOpportunitiesNotifier();
    });

class MapOpportunitiesNotifier extends Notifier<List<OpportunityModel>> {
  @override
  List<OpportunityModel> build() {
    return _getMockOpportunities();
  }

  /// Genera los datos de prueba iniciales
  List<OpportunityModel> _getMockOpportunities() {
    return [
      OpportunityModel(
        id: 'OPP-001',
        title: 'Construcción de Habitación',
        description:
            'Construcción de una habitación de 30m2 en Hermosillo Centro, se tienen los planos.',
        distance: 2.5,

        latitude: 29.0815,
        longitude: -110.9624,
        type: OpportunityType.special,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),

        category: 'Albañilería',
        estimatedPriceMin: 15000,
        estimatedPriceMax: 20000,
        clientAnswers: {
          '¿Tienes material comprado?': 'Solo el cemento, falta la varilla.',
          '¿El terreno está nivelado?': 'Sí, listo para cimentar.',
          '¿Cuándo requieres el servicio?': 'Próxima semana',
        },
        photoUrls: const ['mock1', 'mock2', 'mock3'],
      ),

      OpportunityModel(
        id: 'OPP-002',
        title: 'Instalación de 4 Minisplits (2 Ton)',
        description:
            'Busco instalador certificado para colocar 4 equipos nuevos en oficinas. Solo mano de obra.',
        distance: 5.8,

        latitude: 29.1150,
        longitude: -110.9560,
        type: OpportunityType.urgent,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),

        category: 'Refrigeración',
        estimatedPriceMin: 3200,
        estimatedPriceMax: 4000,
        clientAnswers: {
          '¿Los equipos son nuevos o usados?': 'Nuevos en caja cerrada.',
          '¿Hay preparación eléctrica previa?':
              'Sí, ya cuenta con pastillas a 220v.',
          '¿Cuándo requieres el servicio?': 'Lo antes posible',
        },
        photoUrls: const ['mock1', 'mock2', 'mock3'],
      ),

      OpportunityModel(
        id: 'OPP-003',
        title: 'Fuga en tubería de baño',
        description: 'Tengo una fuga constante debajo del lavabo, gotea mucho.',
        distance: 1.2,

        latitude: 29.0729,
        longitude: -110.9559,
        type: OpportunityType.normal,
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),

        category: 'Plomería',
        estimatedPriceMin: 400,
        estimatedPriceMax: 800,
        clientAnswers: {
          '¿De qué material es la tubería?': 'Parece PVC',
          '¿Cuándo requieres el servicio?': 'Hoy mismo si se puede',
        },
        photoUrls: const ['mock1'],
      ),
    ];
  }

  // --- FUTURAS FUNCIONALIDADES ---

  /// Ejemplo de cómo modificar el estado con la sintaxis moderna
  void filterByCategory(String category) {
    // Para actualizar el estado, simplemente reasignamos `state`
    // state = state.where((opp) => opp.category == category).toList();
  }

  Future<void> refreshOpportunities() async {
    // TODO: Implementar lógica futura de conexión a la API
    // final newOpps = await api.getOpps();
    // state = newOpps;
  }
}
