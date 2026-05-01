import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/service_model.dart';
import '../providers/home_providers.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab();

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  late final TextEditingController _searchController;

  // --- Task #93: Estado para Servicios Recientes / Populares ---
  List<SearchSuggestion> _homeServices = [];
  bool _isHomeServicesLoading = true;
  String _homeServicesLabel = 'Servicios Recientes';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(searchQueryProvider),
    );
    _fetchHomeServices();
  }

  /// Task #93 — Obtiene servicios recientes; si están vacíos usa los populares.
  ///
  /// TODO (Backend): Sustituir ref.read(...) por llamadas HTTP reales:
  ///   GET /api/client/services/recent   →  recentServicesProvider
  ///   GET /api/client/services/popular  →  popularServicesProvider
  Future<void> _fetchHomeServices() async {
    if (!mounted) return;
    setState(() => _isHomeServicesLoading = true);
    try {
      // Simula latencia de red
      await Future.delayed(const Duration(milliseconds: 600));

      // 1. Intentar servicios recientes
      List<SearchSuggestion> recent = ref.read(recentServicesProvider);

      // 2. Fallback a populares si no hay recientes
      if (recent.isEmpty) {
        recent = ref.read(popularServicesProvider);
        if (mounted) setState(() => _homeServicesLabel = 'Servicios Populares');
      } else {
        if (mounted) setState(() => _homeServicesLabel = 'Servicios Recientes');
      }

      if (mounted) setState(() => _homeServices = recent);
    } catch (_) {
      // Lista queda vacía → se muestra estado de error en la UI
    } finally {
      if (mounted) setState(() => _isHomeServicesLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final selectedCategoryId = ref.watch(selectedCategoryProvider);
    final suggestions = ref.watch(searchSuggestionsProvider);
    final categories = ref.watch(categoriesProvider);
    final showFilters = ref.watch(showFiltersProvider);

    if (_searchController.text != query) {
      _searchController.value = TextEditingValue(
        text: query,
        selection: TextSelection.collapsed(offset: query.length),
      );
    }

    // Mostrar filtros también mientras se escribe en el buscador.
    final isFiltersVisible = showFilters;
    final showServiceResults = query.isNotEmpty || selectedCategoryId != null;
    final filteredCategories = categories.where((category) {
      final matchesSelectedCategory =
          selectedCategoryId == null || selectedCategoryId == category.id;
      final matchesQuery =
          query.isEmpty ||
          category.name.toLowerCase().contains(query.toLowerCase());
      return matchesSelectedCategory && matchesQuery;
    }).toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Task #91 (Search): barra + filtros en el top dentro de SliverToBoxAdapter.
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.05),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) =>
                          ref.read(searchQueryProvider.notifier).update(value),
                      decoration: InputDecoration(
                        hintText: 'Buscar servicios...',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.primaryBlue,
                        ),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (query.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 20),
                                // Fix UX: solo limpia el texto; el filtro de
                                // categoría activo se preserva intencionalmente.
                                onPressed: () {
                                  _searchController.clear();
                                  ref
                                      .read(searchQueryProvider.notifier)
                                      .update('');
                                },
                              ),
                            IconButton(
                              icon: const Icon(Icons.tune_rounded, size: 20),
                              color: AppColors.primaryBlue,
                              onPressed: () {
                                final isFilterVisible = ref.read(
                                  showFiltersProvider,
                                );
                                ref.read(showFiltersProvider.notifier).toggle();

                                // Si se está desactivando el panel de filtros, limpiamos la categoría seleccionada.
                                if (isFilterVisible) {
                                  ref
                                      .read(selectedCategoryProvider.notifier)
                                      .update(null);
                                }
                              },
                            ),
                          ],
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: isFiltersVisible
                      ? Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: SizedBox(
                            height: 45,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 10),
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                final isSelected =
                                    selectedCategoryId == category.id;

                                return GestureDetector(
                                  onTap: () {
                                    ref
                                        .read(selectedCategoryProvider.notifier)
                                        .update(
                                          isSelected ? null : category.id,
                                        );
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primaryBlue
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        if (isSelected)
                                          BoxShadow(
                                            color: AppColors.primaryBlue
                                                .withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          )
                                        else
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.03,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                      ],
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primaryBlue
                                            : Colors.grey.withOpacity(0.1),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          category.icon,
                                          size: 18,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.primaryBlue,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          category.name,
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.white
                                                : AppColors.textDark,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      : const SizedBox(width: double.infinity, height: 0),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        if (showServiceResults)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildSearchSuggestionsList(
                context: context,
                suggestions: suggestions,
              ),
            ),
          ),

        // Banner promocional en el middle.
        if (!showServiceResults)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildWelcomeBanner(),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        // Confirmación: se eliminó por completo la sección vieja "Sugerencias para ti".
        if (!showServiceResults)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final category = filteredCategories[index];
                return _buildCategoryCard(context, category);
              }, childCount: filteredCategories.length),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),

        // ── Task #93: Sección Servicios Recientes / Populares ──────────────
        if (!showServiceResults)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _homeServicesLabel,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navegar a la pantalla completa de servicios
                    },
                    child: const Text(
                      'Ver todos',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        if (!showServiceResults)
          SliverToBoxAdapter(
            child: _isHomeServicesLoading
                ? const SizedBox(
                    height: 160,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBlue,
                        strokeWidth: 2.5,
                      ),
                    ),
                  )
                : _homeServices.isEmpty
                ? const SizedBox(
                    height: 100,
                    child: Center(
                      child: Text(
                        'No hay servicios disponibles',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    height: 195,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth - 48,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (
                                  int i = 0;
                                  i < _homeServices.length;
                                  i++
                                ) ...[
                                  if (i > 0) const SizedBox(width: 14),
                                  _buildHomeServiceCard(
                                    context,
                                    _homeServices[i],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _buildWelcomeBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 160),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryBlue,
              const Color(0xFF1E3A8A),
              const Color(0xFF1D4ED8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Círculos decorativos abstractos
            Positioned(
              right: -50,
              top: -20,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              right: 40,
              bottom: -20,
              child: Icon(
                Icons.bolt_rounded,
                size: 100,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
            // Contenido del banner
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'OFERTA ESPECIAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '¡Encuentra ayuda profesional!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(
                    width: 220,
                    child: Text(
                      'Busca entre cientos de expertos listos para ayudarte hoy mismo.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSuggestionsList({
    required BuildContext context,
    required List<SearchSuggestion> suggestions,
  }) {
    if (suggestions.isEmpty) {
      return const Center(
        child: Column(
          children: [
            SizedBox(height: 16),
            Icon(Icons.search_off_rounded, size: 60, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No encontramos resultados',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resultados para tu búsqueda',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: suggestions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = suggestions[index];
            final iconColor = _getIconColor(item.type);

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    final categoryId = item.categoryId;
                    if (categoryId == null) return;
                    _navigateToQuotingFlow(context, categoryId);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Icono con fondo dinámico
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            _getIcon(item.type),
                            color: iconColor,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Información del servicio
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: AppColors.textDark,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    item.subtitle,
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Flecha decorativa
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.grey[300],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(BuildContext context, ServiceCategory category) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _navigateToQuotingFlow(context, category.id),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: Colors.grey.withOpacity(0.05), width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  // Ícono dominante pero adaptable: FittedBox lo escala sin desbordar en cards de 3 columnas.
                  child: SizedBox(
                    width: 42,
                    height: 42,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Icon(category.icon, color: AppColors.primaryBlue),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                category.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${12 + (int.tryParse(category.id) ?? 0) * 3} profesionales disponibles',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Task #93 — Tarjeta para la fila horizontal de servicios.
  Widget _buildHomeServiceCard(BuildContext context, SearchSuggestion service) {
    final iconColor = _getIconColor(service.type);
    return GestureDetector(
      onTap: () {
        final catId = service.categoryId;
        if (catId != null) _navigateToQuotingFlow(context, catId);
      },
      child: Container(
        width: 170,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.07), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 66,
              height: 66,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(_getIcon(service.type), color: iconColor, size: 34),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                service.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                  color: AppColors.textDark,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                service.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToQuotingFlow(BuildContext context, String categoryId) {
    // TODO(routing): conectar aquí la ruta real del flujo de cotización del cliente.
    // Este método único ya es invocado desde sugerencias de búsqueda y cards del grid.
    try {
      context.push('/cliente/cotizar/$categoryId');
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Flujo de cotización pendiente de ruta final'),
        ),
      );
    }
  }

  IconData _getIcon(ServiceType type) {
    switch (type) {
      case ServiceType.category:
        return Icons.category_rounded;
      case ServiceType.service:
        return Icons.handyman_rounded;
    }
  }

  Color _getIconColor(ServiceType type) {
    switch (type) {
      case ServiceType.category:
        return Colors.orange;
      case ServiceType.service:
        return Colors.green;
    }
  }
}
