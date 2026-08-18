import 'package:incide_core/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Componente visual (Píldora) para filtros horizontales.
///
/// Cambia dinámicamente su diseño (colores invertidos) dependiendo de
/// si está seleccionado o no. Diseñado para usarse dentro de un Row o Wrap.
class CustomFilterChip extends StatelessWidget {
  /// El texto que mostrará el chip.
  final String label;

  /// Determina si el chip aplica el estilo activo (Azul) o inactivo (Blanco/Gris).
  final bool isSelected;

  /// Función a ejecutar cuando el usuario toca el chip.
  final VoidCallback onTap;

  const CustomFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryBlue
                : Colors.grey.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textGray,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
