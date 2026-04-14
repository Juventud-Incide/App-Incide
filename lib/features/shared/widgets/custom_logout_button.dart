import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_incide/features/auth/providers/auth_provider.dart';
import 'package:app_incide/core/theme/app_colors.dart';

enum LogoutButtonVariant { text, outlined }

/// Botón global para cerrar sesión.
class CustomLogoutButton extends ConsumerWidget {
  /// El texto a mostrar (ej. "Cerrar Sesión" o "Hacerlo más tarde")
  final String text;
  final LogoutButtonVariant variant;

  const CustomLogoutButton({
    super.key,
    required this.text,
    this.variant = LogoutButtonVariant.text,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> handleLogout() async {
      await ref.read(authControllerProvider.notifier).logout();
      if (context.mounted) {
        context.go('/roles');
      }
    }

    // 1. Variante: Botón Delineado (Outlined)
    if (variant == LogoutButtonVariant.outlined) {
      return SizedBox(
        width: double.infinity, // Ocupa todo el ancho como en tu diseño
        child: OutlinedButton(
          onPressed: handleLogout, // Usamos la lógica compartida
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryBlue,
            minimumSize: const Size(
              double.infinity,
              55,
            ), // Altura accesible que vimos antes
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
        ),
      );
    }

    // 2. Variante por Defecto: Botón de Texto (TextButton)
    return TextButton(
      onPressed: handleLogout, // Usamos la misma lógica
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textGray,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
