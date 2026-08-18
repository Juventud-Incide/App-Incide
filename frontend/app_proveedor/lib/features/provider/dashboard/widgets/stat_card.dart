import 'package:incide_core/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Tarjeta de métricas rápidas (Estadísticas).
///
/// Componente reutilizable que muestra un número destacado con un ícono.
/// Se utiliza en el panel superior del Dashboard para mostrar, por ejemplo,
/// el número de cotizaciones "En Espera" o trabajos "Ganados".
class StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;

  /// El número principal a destacar (ej. "3").
  final String count;

  /// El texto secundario descriptivo (ej. "Cotizaciones en espera").
  final String label;

  /// Función disparada al tocar la tarjeta entera (ej. Filtrar una lista).
  final VoidCallback onTap;

  const StatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.count,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 12),
            Text(
              count,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textGray,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
