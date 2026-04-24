import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../models/cotizacion_model.dart';
import '../providers/home_providers.dart';

// ─────────────────────────────────────────────────────────
// Task #116 — Pestaña "Mis Cotizaciones"
// ─────────────────────────────────────────────────────────

class QuotesTab extends ConsumerWidget {
  const QuotesTab({super.key});

  static const _filtros = [
    _FiltroDef(label: 'EN ESPERA', estado: EstadoCotizacion.enEspera),
    _FiltroDef(label: 'ACEPTADAS', estado: EstadoCotizacion.aceptada),
    _FiltroDef(label: 'TERMINADAS', estado: EstadoCotizacion.terminada),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lee el filtro activo y la lista YA filtrada de los providers.
    // Igual que selectedCategoryProvider + searchSuggestionsProvider en HomeTab.
    final filtroActivo = ref.watch(selectedCotizacionFilterProvider);
    final cotizaciones = ref.watch(filteredCotizacionesProvider);

    return Column(
      children: [
        // ── Chips de filtro ────────────────────────────────────────────────
        _buildFiltros(ref, filtroActivo),

        // ── Lista filtrada ─────────────────────────────────────────────────
        Expanded(
          child: cotizaciones.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  itemCount: cotizaciones.length,
                  itemBuilder: (context, index) =>
                      _QuoteCard(cotizacion: cotizaciones[index]),
                ),
        ),
      ],
    );
  }

  // ── Chips estilo igual al filtro de categorías del HomeTab ────────────

  Widget _buildFiltros(WidgetRef ref, EstadoCotizacion filtroActivo) {
    final int selectedIndex = _filtros.indexWhere(
      (f) => f.estado == filtroActivo,
    );

    return Container(
      color: AppColors.backgroundWhite,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Container(
        height: 48, // Altura fija para la barra
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppColors.borderLight),
        ),
        padding: const EdgeInsets.all(4),
        child: Stack(
          children: [
            // Indicador azul que se desliza
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              alignment: selectedIndex == 0
                  ? Alignment.centerLeft
                  : selectedIndex == 1
                  ? Alignment.center
                  : Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: 1.0 / _filtros.length, // Ocupa exactamente 1/3
                heightFactor: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Opciones de texto interactivas
            Row(
              children: List.generate(_filtros.length, (index) {
                final filtro = _filtros[index];
                final isSelected = selectedIndex == index;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => ref
                        .read(selectedCotizacionFilterProvider.notifier)
                        .update(filtro.estado),
                    child: Center(
                      child: Text(
                        filtro.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                          color: isSelected ? Colors.white : AppColors.textGray,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ── Estado vacío ────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.07),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              size: 38,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Sin cotizaciones aquí',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cuando solicites un servicio,\nverás tus cotizaciones aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textGray,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Tarjeta de Cotización
// ─────────────────────────────────────────────────────────

class _QuoteCard extends StatelessWidget {
  final CotizacionModel cotizacion;

  const _QuoteCard({required this.cotizacion});

  @override
  Widget build(BuildContext context) {
    // Determinar colores y texto del badge por fuera para evitar errores nulos
    Color badgeColor;
    String badgeLabel;

    switch (cotizacion.estado) {
      case EstadoCotizacion.enEspera:
        badgeColor = const Color(0xFFF59E0B);
        badgeLabel = 'En Espera';
        break;
      case EstadoCotizacion.aceptada:
        badgeColor = AppColors.successGreen;
        badgeLabel = 'Aceptada';
        break;
      case EstadoCotizacion.terminada:
        badgeColor = AppColors.textGray;
        badgeLabel = 'Terminada';
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: () {
          context.push(
            '/cliente/cotizacion/${cotizacion.id}',
            extra: cotizacion,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: cotizacion.hasNewProposal
                ? AppColors.primaryBlue.withOpacity(0.02)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: cotizacion.hasNewProposal
                  ? AppColors.primaryBlue.withOpacity(0.6)
                  : AppColors.borderLight,
              width: cotizacion.hasNewProposal ? 1.5 : 1.0,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Fila superior: ícono + título + badge ──────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ícono
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.handyman_rounded,
                      color: AppColors.primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Título y descripción
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          cotizacion.titulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cotizacion.descripcion,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textGray,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Badges
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (cotizacion.hasNewProposal)
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.redAccent.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.notifications_active_rounded,
                                color: Colors.white,
                                size: 10,
                              ),
                              /*
                              Text(
                                'NUEVA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              */
                            ],
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: badgeColor.withOpacity(0.3),
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          badgeLabel,
                          style: TextStyle(
                            color: badgeColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Reemplazo del Divider para evitar bugs de SDK web
              Container(height: 1, color: AppColors.borderLight),
              const SizedBox(height: 12),
              // ── Fila inferior: precio + botón chat ─────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Precio estimado
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Precio estimado',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textGray,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '\$${cotizacion.precioEstimado.toStringAsFixed(2)} MXN',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  // Botón
                  GestureDetector(
                    onTap: () {
                      // TODO(Backend): Conectar navegación real al chat en el futuro
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Abrir Chat',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} // <Fin del QuoteCard>

class _FiltroDef {
  final String label;
  final EstadoCotizacion estado;
  const _FiltroDef({required this.label, required this.estado});
}
