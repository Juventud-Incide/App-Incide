import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_incide/features/auth/providers/auth_provider.dart';
import 'package:app_incide/core/theme/app_colors.dart';

/// Botón global para cerrar sesión.
class CustomLogoutButton extends ConsumerWidget {
  /// El texto a mostrar (ej. "Cerrar Sesión" o "Hacerlo más tarde")
  final String text;

  const CustomLogoutButton({super.key, required this.text});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton(
      onPressed: () async {
        // 1. Limpiamos la sesión en RAM y SharedPreferences
        await ref.read(authControllerProvider.notifier).logout();

        // 2. Redirigimos explícitamente al inicio de roles
        if (context.mounted) {
          context.goNamed('splash');
        }
      },
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
