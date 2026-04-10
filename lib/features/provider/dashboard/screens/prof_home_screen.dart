import 'package:app_incide/core/constants/app_strings.dart';
import 'package:app_incide/core/theme/app_colors.dart';
import 'package:app_incide/features/provider/dashboard/widgets/stat_card.dart';
import 'package:app_incide/features/provider/dashboard/widgets/custom_filter_chip.dart';
import 'package:app_incide/features/provider/dashboard/widgets/opportunity_card.dart';
import 'package:app_incide/features/provider/dashboard/widgets/proposal_bottom_sheet.dart';
import 'package:app_incide/features/provider/dashboard/models/opportunity_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

/// Pantalla principal del Dashboard para el rol de Proveedor.
///
/// Esta vista actúa como el controlador principal (View-Controller) del flujo
/// de trabajo del profesional. Es responsable de mostrar las oportunidades locales,
/// gestionar los filtros de búsqueda, y orquestar la navegación hacia la vista
/// de detalles o el envío de cotizaciones.
class ProfHomeScreen extends StatefulWidget {
  const ProfHomeScreen({super.key});

  @override
  State<ProfHomeScreen> createState() => _ProfHomeScreenState();
}

class _ProfHomeScreenState extends State<ProfHomeScreen> {
  /// Controla el estado visual del Radar.
  /// TODO: (BACKEND) Sincronizar este booleano con la base de datos para pausar/reanudar notificaciones push.
  bool _isRadarActive = true;

  /// Almacena el filtro actual seleccionado por el usuario.
  String _selectedFilter = AppStrings.filterAll;

  /// Temporizador controlado para la gestión de SnackBars.
  /// Previene condiciones de carrera cuando el usuario descarta múltiples tarjetas rápidamente.
  Timer? _snackBarTimer;

  // TODO: (BACKEND) - Reemplazar esta lista dura con un [FutureBuilder] o Riverpod [AsyncValue] que consuma el repositorio real (ej. `fetchOpportunities()`).
  // Future<void> fetchOpportunities() async { ... }
  final List<OpportunityModel> _opportunities = [
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
      photoUrls: const ['mock1', 'mock2', 'mock3'],
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
      photoUrls: const ['mock1', 'mock2', 'mock3'],
    ),
  ];

  // TODO: (BACKEND) - Extraer esta información del AuthProvider o de un UserProfileModel
  final String _userName = 'Ángel Apáez';
  final String _userInitials = 'AA';
  final bool _hasUnreadNotifications = true;
  final bool _isCertified = true;

  @override
  Widget build(BuildContext context) {
    // AnnotatedRegion se asegura de que los íconos del sistema operativo (batería, hora)
    // sean legibles sobre nuestro fondo azul primario.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(
                context,
              ), // Le pasamos el context para calcular la altura de la cámara
              const SizedBox(height: 24),
              _buildStatsCards(),
              const SizedBox(height: 32),
              _buildOpportunitiesHeader(),
              const SizedBox(height: 16),
              _buildFilterChips(),
              const SizedBox(height: 24),
              _buildOpportunitiesList(),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET: CABECERA AZUL ---
  /// Construye la cabecera principal con el perfil de usuario y el control del Radar.
  Widget _buildHeader(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top + 20;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: topPadding,
        bottom: 30,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // 1. Fila Superior: Avatar, Nombre y Campana
          Row(
            children: [
              // Avatar con Check de Certificación
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                    child: Text(
                      _userInitials,
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  if (_isCertified)
                    Positioned(
                      bottom: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.primaryBlue,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 12,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),

              // Textos de Bienvenida
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppStrings.welcomeText,
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Campana de Notificaciones
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      // TODO: Navegar a pantalla de notificaciones
                    },
                  ),
                  if (_hasUnreadNotifications)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),

          // 2. Tarjeta Interna: Radar de Solicitudes
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isRadarActive
                            ? AppStrings.radarTitleOn
                            : AppStrings.radarTitleOff,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isRadarActive
                            ? AppStrings.radarSubtitleOn
                            : AppStrings.radarSubtitleOff,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Switch interactivo
                Switch.adaptive(
                  value: _isRadarActive,
                  activeThumbColor: Colors.white,
                  activeTrackColor: Colors.green,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                  inactiveThumbColor: Colors.white,
                  onChanged: (value) {
                    setState(() {
                      _isRadarActive = value;
                    });
                    // TODO: Notificar al backend el cambio de estado de disponibilidad
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: TARJETAS DE ESTADÍSTICAS ---
  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              icon: Icons.hourglass_bottom_rounded,
              iconColor: AppColors.primaryBlue,
              count: '3', // TODO: Conectar a la base de datos de contadores
              label: AppStrings.waitingQuotesTitle,
              onTap: () {
                // TODO: Navegar o filtrar hacia la vista de cotizaciones en espera
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: StatCard(
              icon: Icons.handshake_rounded,
              iconColor: Colors.green,
              count: '1', // TODO: Conectar a la base de datos de contadores
              label: AppStrings.acceptedQuotesTitle,
              onTap: () {
                // TODO: Navegar o filtrar hacia la vista de trabajos ganados
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: TÍTULO Y BOTÓN DE MAPA ---
  Widget _buildOpportunitiesHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            AppStrings.opportunitiesTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          GestureDetector(
            onTap: () {
              // TODO: (MAPAS) Integrar vista de Google Maps / Mapbox
            },
            child: const Text(
              AppStrings.viewMapBtn,
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: FILTROS HORIZONTALES ---
  /// Construye el selector horizontal de filtros (Todos, Exclusivos, Abiertos).
  Widget _buildFilterChips() {
    final filters = [
      AppStrings.filterAll,
      AppStrings.filterExclusive,
      AppStrings.filterOpen,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CustomFilterChip(
              label: filter,
              isSelected: _selectedFilter == filter,
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
                // TODO: Filtrar la lista de tarjetas de abajo según la selección
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- WIDGET: LISTA DE OPORTUNIDADES ---
  /// Construye y filtra la lista vertical de oportunidades mostradas al usuario.
  ///
  /// Actúa como el receptor de acciones de las tarjetas, procesando cuando
  /// el usuario presiona "Descartar" o cuando regresa de enviar una cotización
  /// desde el modal o la vista de detalles.
  Widget _buildOpportunitiesList() {
    // 1. Filtramos la lista según el chip seleccionado
    final filteredList = _opportunities.where((opp) {
      if (_selectedFilter == AppStrings.filterAll) return true;
      if (_selectedFilter == AppStrings.filterExclusive) return opp.isExclusive;
      if (_selectedFilter == AppStrings.filterOpen) return !opp.isExclusive;
      return true;
    }).toList();

    // 2. Si no hay resultados, mostramos un mensaje vacío
    if (filteredList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Center(
          child: Text(
            AppStrings.noOpportunities,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: filteredList.map((opp) {
          return OpportunityCard(
            isExclusive: opp.isExclusive,
            title: opp.title,
            description: opp.description,
            distance: opp.formattedDistance,
            onTap: () async {
              // Navegamos al detalle esperando un String de resultado
              final result = await context.pushNamed<String>(
                'opportunity_detail',
                extra:
                    opp, // Pasamos el objeto completo a la pantalla de detalle
              );
              if (!context.mounted) return;

              // Evaluamos qué decidió hacer el usuario en la otra pantalla
              if (result == 'discarded') {
                _handleDiscard(opp.id);
              } else if (result == 'accepted') {
                _handleAccept(opp.id);
              }
            },
            onDiscard: () => _handleDiscard(opp.id),
            onInterested: () async {
              // TODO: (BACKEND) - Enviar datos de `opp` al controlador de cotizaciones
              final result = await showModalBottomSheet<bool>(
                context: context,
                isScrollControlled: true,
                useRootNavigator: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const ProposalBottomSheet(),
              );

              // Si recibimos el éxito, ejecutamos la acción de aceptar
              if (result == true) {
                _handleAccept(opp.id);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  // Manejador para cuando se acepta una oportunidad
  /// Remueve visualmente una oportunidad tras haber enviado una cotización exitosa.
  void _handleAccept(String opportunityId) {
    setState(() {
      _opportunities.removeWhere((opp) => opp.id == opportunityId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('¡Propuesta enviada con éxito!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  // Lógica del SnackBar de Descartar
  /// Implementa un patrón de "Eliminación Suave" con opción a deshacer.
  ///
  /// Remueve la tarjeta del feed local y muestra un SnackBar. Si el usuario
  /// presiona "Deshacer", restaura el objeto en su posición original.
  void _handleDiscard(String opportunityId) {
    // 1. Encontrar y guardar la tarjeta antes de borrarla
    final index = _opportunities.indexWhere((opp) => opp.id == opportunityId);
    if (index == -1) return;

    // Respaldamos el objeto en caso de que el usuario quiera deshacer la acción
    final deletedOpportunity = _opportunities[index];

    // 2. Borrarla de la vista principal
    setState(() {
      _opportunities.removeAt(index);
    });

    _snackBarTimer?.cancel(); // Cancelamos cualquier SnackBar pendiente
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Oportunidad descartada'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Deshacer',
          textColor: Colors.amber,
          onPressed: () {
            _snackBarTimer?.cancel();
            messenger.hideCurrentSnackBar();

            setState(() {
              _opportunities.insert(index, deletedOpportunity);
            });
          },
        ),
      ),
    );

    // El Timer asegura que si el usuario realiza múltiples descartes rápidos,
    // solo el último temporizador tenga el control del cierre visual.
    _snackBarTimer = Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        messenger.hideCurrentSnackBar();
      }
    });
  }

  @override
  void dispose() {
    // LIMPIEZA: Es mandatorio destruir el Timer para evitar fugas de memoria (Memory Leaks)
    _snackBarTimer?.cancel();
    super.dispose();
  }
}
