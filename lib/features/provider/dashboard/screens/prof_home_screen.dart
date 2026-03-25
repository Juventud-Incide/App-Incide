import 'package:app_incide/core/constants/app_strings.dart';
import 'package:app_incide/core/theme/app_colors.dart';
import 'package:app_incide/features/provider/dashboard/widgets/stat_card.dart';
import 'package:app_incide/features/provider/dashboard/widgets/custom_filter_chip.dart';
import 'package:app_incide/features/provider/dashboard/widgets/opportunity_card.dart';
import 'package:app_incide/features/provider/dashboard/widgets/proposal_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfHomeScreen extends StatefulWidget {
  const ProfHomeScreen({super.key});

  @override
  State<ProfHomeScreen> createState() => _ProfHomeScreenState();
}

class _ProfHomeScreenState extends State<ProfHomeScreen> {
  // Estado para controlar el Switch del Radar
  bool _isRadarActive = true;
  String _selectedFilter = AppStrings.filterAll;

  // TODO: Esto vendrá del backend/provider en el futuro
  final String _userName = 'Ángel Apáez';
  final String _userInitials = 'AA';
  final bool _hasUnreadNotifications = true;
  final bool _isCertified = true;

  @override
  Widget build(BuildContext context) {
    // AnnotatedRegion controla el color del reloj y batería del sistema operativo
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
              _buildOpportunitiesList(), // ¡La lista de tarjetas!
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET: CABECERA AZUL ---
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
                    // TODO: Notificar al backend el cambio de estado
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
              count: '3', // TODO: Conectar a la base de datos
              label: AppStrings.waitingQuotesTitle,
              onTap: () {
                // TODO: Filtrar la vista inferior
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: StatCard(
              icon: Icons.handshake_rounded,
              iconColor: Colors.green,
              count: '1', // TODO: Conectar a la base de datos
              label: AppStrings.acceptedQuotesTitle,
              onTap: () {
                // TODO: Filtrar la vista inferior
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
              // TODO: Navegar a la vista de mapa completo
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
  Widget _buildOpportunitiesList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          OpportunityCard(
            isExclusive: true,
            title: AppStrings.opportunityTitle1,
            description: AppStrings.opportunitySubtitle1,
            distance: AppStrings.opportunityDistance1,
            onTap: () {
              // TODO: Navegar a Vista de Detalle
            },
            onDiscard: _handleDiscard,
            onInterested: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useRootNavigator: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const ProposalBottomSheet(),
              );
            },
          ),
          OpportunityCard(
            isExclusive: false,
            title: AppStrings.opportunityTitle2,
            description: AppStrings.opportunitySubtitle2,
            distance: AppStrings.opportunityDistance2,
            onTap: () {
              // TODO: Navegar a Vista de Detalle
            },
            onDiscard: _handleDiscard,
            onInterested: () {
              // TODO: Abrir Modal "Me Interesa"
            },
          ),
        ],
      ),
    );
  }

  // Lógica del SnackBar de Descartar
  void _handleDiscard() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(AppStrings.opportunityDiscarded),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: AppStrings.undoDiscard,
          textColor: Colors.amber,
          onPressed: () {
            // TODO: Lógica para restaurar la tarjeta
          },
        ),
      ),
    );
  }
}
