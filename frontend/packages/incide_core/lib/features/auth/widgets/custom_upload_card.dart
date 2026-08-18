import 'package:incide_core/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:incide_core/core/constants/app_strings.dart';

/// Tarjeta interactiva para la selección y carga de documentos individuales.
///
/// **Comportamiento Visual Dinámico:**
/// El diseño muta drásticamente basado en el parámetro [isUploaded].
/// Cuando cambia a `true`, la tarjeta altera su paleta a verde (éxito),
/// reemplaza el icono original por un "Check" y oculta el botón de "Añadir (+)",
/// brindando retroalimentación de éxito al usuario.
///
/// **Inversión de Control (Inversion of Control):**
/// Este widget es "tonto" (Stateless). No contiene lógica nativa para abrir
/// la cámara o la galería. Delega esa responsabilidad a la vista padre a través
/// del callback [onTap], manteniéndose altamente reutilizable.
class CustomUploadCard extends StatelessWidget {
  final String title;
  final String subtitle;

  /// Icono contextual por defecto (ej. Un birrete para la cédula profesional).
  final IconData icon;

  /// Define si el documento ya fue seleccionado/subido.
  final bool isUploaded;

  /// Función inyectada para invocar el selector de archivos del Sistema Operativo.
  final VoidCallback onTap;

  const CustomUploadCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isUploaded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUploaded
              ? const Color(0xFF10B981).withValues(alpha: 0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isUploaded ? const Color(0xFF10B981) : Colors.grey[300]!,
            width: isUploaded ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Círculo del Ícono
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUploaded
                    ? const Color(0xFF10B981)
                    : const Color(0xFFF4F5F7),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isUploaded ? Icons.check_rounded : icon,
                color: isUploaded ? Colors.white : AppColors.textGray,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isUploaded
                          ? const Color(0xFF10B981)
                          : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isUploaded ? AppStrings.docUploaded : subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isUploaded
                          ? const Color(0xFF10B981)
                          : AppColors.textGray,
                    ),
                  ),
                ],
              ),
            ),
            // Indicador de acción (solo si falta el documento)
            if (!isUploaded)
              const Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.primaryBlue,
              ),
          ],
        ),
      ),
    );
  }
}
