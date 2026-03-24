import 'package:app_incide/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomCorrectionCard extends StatelessWidget {
  final String title;
  final String adminComment;
  final bool isFixed;
  final VoidCallback onTap;

  const CustomCorrectionCard({
    super.key,
    required this.title,
    required this.adminComment,
    required this.isFixed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isFixed
            ? AppColors.primaryBlue.withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isFixed ? AppColors.primaryBlue : Colors.redAccent,
          width: isFixed ? 2 : 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Parte superior interactiva
          ListTile(
            onTap: isFixed ? null : onTap,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isFixed
                    ? AppColors.primaryBlue
                    : Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isFixed
                    ? Icons.check_circle_rounded
                    : Icons.error_outline_rounded,
                color: isFixed ? Colors.white : Colors.redAccent,
              ),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isFixed ? AppColors.primaryBlue : AppColors.textDark,
              ),
            ),
            subtitle: Text(
              isFixed
                  ? 'Corregido. Listo para enviar.'
                  : 'Requiere actualización',
              style: TextStyle(
                color: isFixed ? AppColors.primaryBlue : Colors.redAccent,
                fontSize: 13,
              ),
            ),
            trailing: isFixed
                ? null
                : const Icon(
                    Icons.upload_file_rounded,
                    color: Colors.redAccent,
                  ),
          ),

          // Caja de comentarios del Administrador
          if (!isFixed)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.05),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(14),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.comment_rounded,
                    color: Colors.redAccent,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nota del revisor: $adminComment',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.redAccent,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
