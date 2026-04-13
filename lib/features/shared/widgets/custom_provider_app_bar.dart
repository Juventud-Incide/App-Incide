import 'package:flutter/material.dart';
import 'package:app_incide/core/theme/app_colors.dart';
import 'provider_notification_bell.dart';

class CustomProviderAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;

  const CustomProviderAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryBlue,
      elevation: 0,
      centerTitle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 22,
        ),
      ),
      actions: const [ProviderNotificationBell(), SizedBox(width: 8)],
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(16),
        child: SizedBox(height: 16),
      ),
    );
  }

  // Altura estándar de un AppBar
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16);
}
