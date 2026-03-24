import 'package:app_incide/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomUploadCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isUploaded;
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
              ? const Color(0xFF10B981).withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isUploaded ? const Color(0xFF10B981) : Colors.grey[300]!,
            width: isUploaded ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
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
                    isUploaded ? 'Documento adjuntado' : subtitle,
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
