import 'package:app_incide/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Tarjeta de solo lectura para indicar un estado de éxito/aprobación.
///
/// **Propósito:**
/// Componente visual "tonto" (Dumb Component) utilizado en listas de requisitos
/// para mostrarle al usuario qué elementos ya han sido validados por el sistema
/// o por un administrador, brindando tranquilidad visual (check verde).
class CustomApprovedCard extends StatelessWidget {
  /// El nombre del documento o requisito aprobado (ej. "Identificación Oficial").
  final String title;

  const CustomApprovedCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_rounded,
            color: Color(0xFF10B981),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textGray,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
