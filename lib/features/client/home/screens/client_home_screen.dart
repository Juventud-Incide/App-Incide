import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/providers/auth_provider.dart';
import '../models/service_model.dart';

class ClientHomeScreen extends ConsumerStatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  ConsumerState<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends ConsumerState<ClientHomeScreen> {
  int _currentIndex = 0;

  // --- VARIABLES DE ESTADO (Listas para el Backend) ---
  bool _isLoading = true;
  String _userName = '';
  String _userEmail = '';
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// TODO (Backend): Conectar con tu API real para cargar datos del usuario.
  /// Endpoint sugerido: GET /api/client/profile
  /// Response esperada: { "name": "Juan Pérez", "email": "cliente@correo.com", "notifications": 3 }
  Future<void> _fetchUserData() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Aquí iría tu llamada HTTP real. Ejemplo:
      // final prefs = await SharedPreferences.getInstance();
      // final token = prefs.getString('jwt_token');
      // final response = await http.get(Uri.parse('URL'), headers: {'Authorization': 'Bearer $token'});

      // Simulamos la latencia de red (mock)
      await Future.delayed(const Duration(milliseconds: 800));

      // Asignamos los datos obtenidos a las variables de estado
      if (mounted) {
        setState(() {
          _userName = 'Juan Pérez';
          _userEmail = 'cliente@correo.com';
          _unreadNotifications =
              3; //Aqui pones un numero mayor a 0 y se activa la burbuja roja del numero de notificaciones
        });
      }
    } catch (e) {
      // TODO: Manejo de errores de conexión/sesión (ej. token expirado -> redirigir al login)
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Lista de las secciones asignadas al BottomNavigationBar.
  // Ahora las inicializamos como métodos (getter) para pasarles las variables de estado.
  List<Widget> get _screens => [
    const _HomeTab(),
    const _QuotesTab(),
    const _PaymentsTab(),
    _ProfileTab(userName: _userName, userEmail: _userEmail),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      // --- HEADER ---
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        toolbarHeight: 85,
        titleSpacing: 24,
        title: Row(
          children: [
            // Logo del sistema con diseño estilizado
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/Isotipo_Incide.png',
                height: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Saludo y nombre de usuario con mejor jerarquía
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hola, Bienvenido',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.7),
                    letterSpacing: 0.5,
                  ),
                ),
                _isLoading
                    ? const Padding(
                        padding: EdgeInsets.only(top: 4.0),
                        child: SizedBox(
                          height: 14,
                          width: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        _userName.isNotEmpty ? _userName : 'Usuario',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
              ],
            ),
          ],
        ),
        actions: [
          // Botón Notificaciones con diseño Premium mejorado
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Center(
              child: SizedBox(
                width: 48,
                height: 48,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      onPressed: () {
                        // TODO: Abrir panel de notificaciones
                      },
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    if (_unreadNotifications > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryBlue,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            '$_unreadNotifications',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // Contenido principal que cambia según la pestaña
      body: _screens[_currentIndex],

      // --- BARRA DE NAVEGACIÓN INFERIOR ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: Colors.grey[400],
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.home_rounded),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.request_quote_rounded),
              ),
              label: 'Cotizaciones',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.account_balance_wallet_rounded),
              ),
              label: 'Pagos',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4.0),
                child: Icon(Icons.person_rounded),
              ),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
//            SUB-PANTALLAS (TABS) TEMPORALES
// ─────────────────────────────────────────────────────────

class _HomeTab extends ConsumerWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final selectedCategoryId = ref.watch(selectedCategoryProvider);
    final suggestions = ref.watch(searchSuggestionsProvider);
    final categories = ref.watch(categoriesProvider);
    final showFilters = ref.watch(showFiltersProvider);

    //  Ocultar filtros automáticamente si hay texto en la búsqueda
    final isFiltersVisible = showFilters && query.isEmpty;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          // --- BARRA DE BÚSQUEDA ---
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
                onChanged: (value) =>
                    ref.read(searchQueryProvider.notifier).update(value),
                decoration: InputDecoration(
                  hintText: 'Buscar servicios...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.primaryBlue,
                  ),
                  suffixIcon: query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20),
                          onPressed: () {
                            ref.read(searchQueryProvider.notifier).update('');
                            ref
                                .read(selectedCategoryProvider.notifier)
                                .update(null);
                          },
                        )
                      : IconButton(
                          icon: const Icon(Icons.tune_rounded, size: 20),
                          color: AppColors.primaryBlue,
                          onPressed: () =>
                              ref.read(showFiltersProvider.notifier).toggle(),
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

          // --- FILTROS POR CATEGORÍA CON ANIMACIÓN ---
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isFiltersVisible
                ? Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: SizedBox(
                      height: 45,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          final isSelected = selectedCategoryId == category.id;

                          return GestureDetector(
                            onTap: () {
                              ref
                                  .read(selectedCategoryProvider.notifier)
                                  .update(isSelected ? null : category.id);
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
                                      color: AppColors.primaryBlue.withOpacity(
                                        0.3,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  else
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
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

          const SizedBox(height: 10),

          // --- CONTENIDO DINÁMICO ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner de bienvenida (se oculta al buscar o filtrar)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: query.isEmpty
                      ? _buildWelcomeBanner()
                      : const SizedBox.shrink(),
                ),
                if (query.isEmpty) const SizedBox(height: 32),

                // Lista de resultados (Recomendados o Búsqueda)
                _buildSuggestionsList(
                  suggestions,
                  title: query.isEmpty
                      ? 'Sugerencias para ti'
                      : 'Resultados para tu búsqueda',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        height: 160,
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

  Widget _buildSuggestionsList(
    List<SearchSuggestion> suggestions, {
    required String title,
  }) {
    if (suggestions.isEmpty) {
      return const Center(
        child: Column(
          children: [
            SizedBox(height: 40),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
                letterSpacing: -0.5,
              ),
            ),
            if (suggestions.length > 3)
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Ver todo',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
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
                    // TODO: Navegar
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
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item.type == ServiceType.category
                                          ? 'Categoría'
                                          : 'Servicio',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
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

// ─────────────────────────────────────────────────────────
//            PROVEEDORES DE BÚSQUEDA (Movidos aquí)
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

// Mock de sugerencias basadas en el texto de búsqueda
final searchSuggestionsProvider = Provider<List<SearchSuggestion>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final selectedCategoryId = ref.watch(selectedCategoryProvider);

  // Mocks con IDs de categoría vinculados
  final allMocks = [
    SearchSuggestion(
      id: 's1',
      title: 'Fuga de agua en cocina',
      subtitle: 'Servicio de Plomería',
      type: ServiceType.service,
      categoryId: '2',
    ),
    SearchSuggestion(
      id: 's2',
      title: 'Instalación de AC',
      subtitle: 'Servicio Eléctrico',
      type: ServiceType.service,
      categoryId: '4',
    ),
    SearchSuggestion(
      id: 's3',
      title: 'Limpieza de Alfombras',
      subtitle: 'Servicio de Limpieza',
      type: ServiceType.service,
      categoryId: '5',
    ),
    SearchSuggestion(
      id: 's4',
      title: 'Cortocircuito en sala',
      subtitle: 'Servicio Eléctrico',
      type: ServiceType.service,
      categoryId: '4',
    ),
    SearchSuggestion(
      id: 'c1',
      title: 'Construcción de Interiores',
      subtitle: 'Categoría',
      type: ServiceType.category,
      categoryId: '1',
    ),
    SearchSuggestion(
      id: 'c2',
      title: 'Planos y Documentos',
      subtitle: 'Categoría',
      type: ServiceType.category,
      categoryId: '3',
    ),
  ];

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

class _QuotesTab extends StatelessWidget {
  const _QuotesTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Mis Cotizaciones en construcción',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}

class _PaymentsTab extends StatelessWidget {
  const _PaymentsTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Mis Pagos en construcción',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}

class _ProfileTab extends ConsumerWidget {
  final String userName;
  final String userEmail;

  const _ProfileTab({required this.userName, required this.userEmail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header del perfil con fondo decorativo
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person_rounded,
                      size: 60,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Información del usuario
          Text(
            userName.isNotEmpty ? userName : 'Usuario',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          Text(
            userEmail.isNotEmpty ? userEmail : 'cliente@correo.com',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 48),

          // Opciones de cuenta (Visuales)
          _buildProfileOption(Icons.settings_display_rounded, 'Preferencias'),
          _buildProfileOption(Icons.security_rounded, 'Seguridad'),
          _buildProfileOption(Icons.help_outline_rounded, 'Ayuda y Soporte'),

          const SizedBox(height: 48),

          // Botón de cierre de sesión estilizado
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).logout();
                },
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFF1F2),
                  foregroundColor: Colors.red[600],
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 22),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
