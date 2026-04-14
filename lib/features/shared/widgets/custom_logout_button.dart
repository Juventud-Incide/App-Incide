import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_incide/features/auth/providers/auth_provider.dart';
import 'package:app_incide/core/theme/app_colors.dart';

enum LogoutButtonVariant { text, outlined, elevated }

/// Botón global para cerrar sesión.
class CustomLogoutButton extends ConsumerWidget {
  /// El texto a mostrar (ej. "Cerrar Sesión" o "Hacerlo más tarde")
  final String text;
  final LogoutButtonVariant variant;
  final bool isInsideDialog;
  final String routeAfterLogout;

  const CustomLogoutButton({
    super.key,
    required this.text,
    this.variant = LogoutButtonVariant.text,
    this.isInsideDialog =
        false, // Por defecto, asume que está en una pantalla normal
    this.routeAfterLogout =
        '/roles', // Redirige a selección de roles por defecto
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> handleLogout() async {
      // 1. Si está dentro de un popup/diálogo, lo cerramos primero
      if (isInsideDialog && context.mounted) {
        context.pop();
      }
      // 2. Limpiamos la sesión en RAM y SharedPreferences
      await ref.read(authControllerProvider.notifier).logout();

      // 3. Redirigimos explícitamente al inicio de roles
      if (context.mounted) {
        context.go(routeAfterLogout);
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

    if (variant == LogoutButtonVariant.text) {
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

    if (variant == LogoutButtonVariant.elevated) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: handleLogout,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white, // Hace que el texto sea blanco
            minimumSize: const Size(
              double.infinity,
              55,
            ), // Mantiene la accesibilidad anti-overflow
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
