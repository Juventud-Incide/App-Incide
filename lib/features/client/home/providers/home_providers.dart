import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_model.dart';
import '../models/cotizacion_model.dart';

// ─────────────────────────────────────────────────────────
//            PROVEEDORES DE BÚSQUEDA
// ─────────────────────────────────────────────────────────

// Proveedor para el texto de búsqueda actual
final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(() {
  return SearchQueryNotifier();
});

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void update(String value) => state = value;
}

final showFiltersProvider = NotifierProvider<ShowFiltersNotifier, bool>(() {
  return ShowFiltersNotifier();
});

class ShowFiltersNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
}

// Proveedor para la categoría seleccionada
final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String?>(() {
      return SelectedCategoryNotifier();
    });

class SelectedCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void update(String? value) => state = value;
}

// Mock de categorías
final categoriesProvider = Provider<List<ServiceCategory>>((ref) {
  return [
    ServiceCategory(
      id: '1',
      name: 'Construcción',
      icon: Icons.construction_rounded,
    ),
    ServiceCategory(id: '2', name: 'Plomería', icon: Icons.plumbing_rounded),
    ServiceCategory(
      id: '3',
      name: 'Documentos',
      icon: Icons.description_rounded,
    ),
    ServiceCategory(
      id: '4',
      name: 'Electricidad',
      icon: Icons.electrical_services_rounded,
    ),
    ServiceCategory(
      id: '5',
      name: 'Limpieza',
      icon: Icons.cleaning_services_rounded,
    ),
  ];
});

// ── Fuente única de datos mock (Task #93) ─────────────────────────────────
// Todos los servicios mock del sistema. Tanto la búsqueda como la sección
// Recientes/Populares consumen esta misma lista — sin duplicar datos.
// TODO (Backend): Eliminar este provider cuando exista un endpoint real.
final allServicesProvider = Provider<List<SearchSuggestion>>((ref) {
  final categories = ref.watch(categoriesProvider);
  final categoryNameById = {for (final c in categories) c.id: c.name};
  return [
    SearchSuggestion(
      id: 's1',
      title: 'Fuga de agua en cocina',
      subtitle: 'Servicio de ${categoryNameById['2'] ?? 'Categoría'}',
      type: ServiceType.service,
      categoryId: '2',
    ),
    SearchSuggestion(
      id: 's2',
      title: 'Instalación de AC',
      subtitle: 'Servicio de ${categoryNameById['4'] ?? 'Categoría'}',
      type: ServiceType.service,
      categoryId: '4',
    ),
    SearchSuggestion(
      id: 's3',
      title: 'Limpieza de Alfombras',
      subtitle: 'Servicio de ${categoryNameById['5'] ?? 'Categoría'}',
      type: ServiceType.service,
      categoryId: '5',
    ),
    SearchSuggestion(
      id: 's4',
      title: 'Cortocircuito en sala',
      subtitle: 'Servicio de ${categoryNameById['4'] ?? 'Categoría'}',
      type: ServiceType.service,
      categoryId: '4',
    ),
    SearchSuggestion(
      id: 's5',
      title: 'Instalacion de regadera',
      subtitle: 'Servicio de ${categoryNameById['2'] ?? 'Categoría'}',
      type: ServiceType.service,
      categoryId: '2',
    ),
  ];
});

// Mock de sugerencias basadas en el texto de búsqueda
// Ahora delega los datos a allServicesProvider — sin duplicación.
final searchSuggestionsProvider = Provider<List<SearchSuggestion>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final selectedCategoryId = ref.watch(selectedCategoryProvider);
  final allMocks = ref.watch(allServicesProvider);

  // Aplicar filtros
  return allMocks.where((item) {
    // Si hay una categoría seleccionada, el item debe pertenecer a ella
    final matchesCategory =
        selectedCategoryId == null || item.categoryId == selectedCategoryId;

    // Si hay texto en el buscador, el item debe coincidir con el texto
    final matchesQuery =
        query.isEmpty ||
        item.title.toLowerCase().contains(query) ||
        item.subtitle.toLowerCase().contains(query);

    return matchesCategory && matchesQuery;
  }).toList();
});

// ── Task #93: Servicios RECIENTES ─────────────────────────────────────────
// TODO (Backend): Reemplazar con GET /api/client/services/recent
// Retorna [] para activar el fallback a popularServicesProvider.
final recentServicesProvider = Provider<List<SearchSuggestion>>((ref) {
  return ref
      .watch(allServicesProvider)
      .take(0)
      .toList(); // take(0) → activa el fallback de popularServicesProvider
});

// ── Task #93: Servicios POPULARES (fallback) ──────────────────────────────
// TODO (Backend): Reemplazar con GET /api/client/services/popular
// Se usa cuando recentServicesProvider retorna una lista vacía.
final popularServicesProvider = Provider<List<SearchSuggestion>>((ref) {
  return ref.watch(allServicesProvider).take(3).toList();
});

// ─────────────────────────────────────────────────────────
//  PROVEEDORES DE COTIZACIONES — Task #116
// ─────────────────────────────────────────────────────────

// ── Fuente única de datos mock ────────────────────────────────────────────
// TODO (Backend): Reemplazar con un AsyncNotifierProvider que llame a
//   GET /api/client/quotes  y mapee la respuesta con CotizacionModel.fromJson
final allCotizacionesProvider =
    NotifierProvider<AllCotizacionesNotifier, List<CotizacionModel>>(() {
      return AllCotizacionesNotifier();
    });

class AllCotizacionesNotifier extends Notifier<List<CotizacionModel>> {
  @override
  List<CotizacionModel> build() {
    return const [
      CotizacionModel(
        id: 'q1',
        titulo: 'Fuga de agua en cocina',
        descripcion: 'Reparación urgente de tubería bajo el fregadero.',
        precioEstimado: 850.0,
        estado: EstadoCotizacion.enEspera,
        hasNewProposal:
            false, // Estado por defecto del mock; activar solo vía simulateNewProposal
      ),
      CotizacionModel(
        id: 'q2',
        titulo: 'Instalación de AC',
        descripcion: 'Instalación de aire acondicionado tipo mini-split.',
        precioEstimado: 3200.0,
        estado: EstadoCotizacion.aceptada,
      ),
      CotizacionModel(
        id: 'q3',
        titulo: 'Limpieza de Alfombras',
        descripcion: 'Limpieza profunda de 3 alfombras en sala y recámaras.',
        precioEstimado: 600.0,
        estado: EstadoCotizacion.terminada,
      ),
      CotizacionModel(
        id: 'q4',
        titulo: 'Cortocircuito en sala',
        descripcion: 'Diagnóstico y reparación del tablero eléctrico.',
        precioEstimado: 1100.0,
        estado: EstadoCotizacion.enEspera,
      ),
      CotizacionModel(
        id: 'q5',
        titulo: 'Instalación de regadera',
        descripcion:
            'Cambio completo de la regadera eléctrica en baño principal.',
        precioEstimado: 750.0,
        estado: EstadoCotizacion.aceptada,
      ),
      CotizacionModel(
        id: 'q6',
        titulo: 'Construcción de barda',
        descripcion: 'Levantamiento de 10 metros lineales de barda perimetral.',
        precioEstimado: 12000.0,
        estado: EstadoCotizacion.terminada,
      ),
    ];
  }

  // TODO(Backend): Eliminar este método cuando exista un backend real.
  @visibleForTesting
  void simulateNewProposal(String id) {
    state = state.map((c) {
      if (c.id == id) {
        return c.copyWith(hasNewProposal: true);
      }
      return c;
    }).toList();
  }
}

// ── Notificación de Nuevas Propuestas ─────────────────────────────────────
final hasUnreadProposalsProvider = Provider<bool>((ref) {
  final cotizaciones = ref.watch(allCotizacionesProvider);
  return cotizaciones.any((c) => c.hasNewProposal);
});

// ── Filtro activo de la pestaña seleccionada ──────────────────────────────
final selectedCotizacionFilterProvider =
    NotifierProvider<SelectedCotizacionFilterNotifier, EstadoCotizacion>(() {
      return SelectedCotizacionFilterNotifier();
    });

class SelectedCotizacionFilterNotifier extends Notifier<EstadoCotizacion> {
  @override
  EstadoCotizacion build() => EstadoCotizacion.enEspera;
  void update(EstadoCotizacion value) => state = value;
}

// ── Lista derivada ya filtrada por estado ─────────────────────────────────
// Equivalente a searchSuggestionsProvider pero para cotizaciones.
// La UI solo consume este provider con ref.watch — nunca accede a allCotizacionesProvider.
final filteredCotizacionesProvider = Provider<List<CotizacionModel>>((ref) {
  final filtroActivo = ref.watch(selectedCotizacionFilterProvider);
  final todas = ref.watch(allCotizacionesProvider);
  return todas.where((c) => c.estado == filtroActivo).toList();
});
