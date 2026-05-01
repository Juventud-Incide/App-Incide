import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/pago_model.dart';
import '../providers/pagos_providers.dart';
import 'package:intl/intl.dart';
import '../widgets/pago_card.dart';

// ─────────────────────────────────────────────────────────
// Pestaña "Mis Pagos"
// ─────────────────────────────────────────────────────────

class PaymentsTab extends ConsumerWidget {
  const PaymentsTab({super.key});

  static const _filtros = [
    _FiltroDef(label: 'TODOS', estado: null),
    _FiltroDef(label: 'PAGADOS', estado: EstadoPago.pagado),
    _FiltroDef(label: 'PENDIENTES', estado: EstadoPago.pendiente),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtroActivo = ref.watch(selectedPagoFilterProvider);
    final pagos = ref.watch(filteredPagosProvider);
    final resumen = ref.watch(resumenPagosProvider);

    return Column(
      children: [
        // ── Tarjeta de resumen financiero ───────────────────────────────────
        _buildResumenHeader(resumen),

        // ── Chips de filtro ─────────────────────────────────────────────────
        _buildFiltros(ref, filtroActivo),

        // ── Lista de pagos ──────────────────────────────────────────────────
        Expanded(
          child: pagos.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  itemCount: pagos.length,
                  itemBuilder: (context, index) =>
                      PagoCard(pago: pagos[index]),
                ),
        ),
      ],
    );
  }

  // ── Tarjeta de resumen financiero ─────────────────────────────────────────
  Widget _buildResumenHeader(ResumenPagos resumen) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, Color(0xFF2D55C8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Círculos decorativos de fondo
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: 40,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          // Contenido
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Resumen de Pagos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Total pagado
                    Expanded(
                      child: _ResumenItem(
                        label: 'Pagados',
                        valor: '${resumen.pagosCompletados}',
                        icon: Icons.check_circle_rounded,
                        iconColor: const Color(0xFF6EE7B7),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 44,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    // Total pendiente
                    Expanded(
                      child: _ResumenItem(
                        label: 'Pendientes',
                        valor: '${resumen.pagosPendientes}',
                        icon: Icons.hourglass_empty_rounded,
                        iconColor: const Color(0xFFFDE68A),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 44,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    // Cantidad de pagos
                    Expanded(
                      child: _ResumenItem(
                        label: 'Transacciones',
                        valor: '${resumen.cantidadPagos}',
                        icon: Icons.receipt_long_rounded,
                        iconColor: const Color(0xFFA5B4FC),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Barra de filtros con animación deslizante ─────────────────────────────
  Widget _buildFiltros(WidgetRef ref, EstadoPago? filtroActivo) {
    final int selectedIndex = _filtros.indexWhere(
      (f) => f.estado == filtroActivo,
    );

    return Container(
      color: AppColors.backgroundWhite,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Container(
        height: 44,
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
            // Indicador azul deslizante
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              alignment: selectedIndex == 0
                  ? const Alignment(-1, 0)
                  : selectedIndex == 1
                  ? const Alignment(0, 0)
                  : const Alignment(1, 0),
              child: FractionallySizedBox(
                widthFactor: 1.0 / _filtros.length,
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
            // Opciones interactivas
            Row(
              children: List.generate(_filtros.length, (index) {
                final filtro = _filtros[index];
                final isSelected = selectedIndex == index;
                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => ref
                        .read(selectedPagoFilterProvider.notifier)
                        .update(filtro.estado),
                    child: Center(
                      child: Text(
                        filtro.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
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

  // ── Estado vacío ───────────────────────────────────────────────────────────
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
              Icons.receipt_rounded,
              size: 38,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Sin pagos aquí',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cuando realices un pago,\naparecerá en esta sección.',
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
// Widget auxiliar: ítem de resumen en la tarjeta header
// ─────────────────────────────────────────────────────────
class _ResumenItem extends StatelessWidget {
  final String label;
  final String valor;
  final IconData icon;
  final Color iconColor;

  const _ResumenItem({
    required this.label,
    required this.valor,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            valor,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────
// Definición de filtros
// ─────────────────────────────────────────────────────────
class _FiltroDef {
  final String label;
  final EstadoPago? estado;
  const _FiltroDef({required this.label, required this.estado});
}
