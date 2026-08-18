import 'package:incide_core/core/constants/app_strings.dart';
import 'package:incide_core/core/theme/app_colors.dart';
import 'package:incide_core/features/shared/widgets/custom_logout_button.dart';
import 'package:flutter/material.dart';

/// Pantalla de "Callejón sin salida" para usuarios bloqueados/rechazados.
///
/// **Rol en la Arquitectura:**
/// Esta vista es el destino final para cuentas que el Administrador ha marcado
/// como `rechazado` en la base de datos (por fraude, documentos falsos, etc.).
///
/// **Manejo de Seguridad:**
/// - Carece de AppBar con botón de retroceso (`Scaffold` sin `appBar`).
/// - La única acción permitida es cerrar sesión, la cual utiliza `context.goNamed('splash')`
///   para limpiar la pila de navegación y regresar al usuario al punto de partida
///   (o invocar la limpieza del token en el AuthProvider).
class ProfRejectedScreen extends StatelessWidget {
  const ProfRejectedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 1),

              // --- 1. ICONO DE RECHAZO (Rojo/Gris) ---
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.block_rounded, // Icono de detener/bloquear
                  size: 55,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 30),

              // --- 2. TÍTULOS Y MENSAJE ---
              const Text(
                AppStrings.rejectedTitle,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                AppStrings.rejectedSubtitle1,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textGray,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                AppStrings.rejectedSubtitle2,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textDark,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(flex: 2),

              // --- 3. BOTÓN CERRAR SESIÓN ---
              CustomLogoutButton(
                text: AppStrings.logoutBtn,
                variant: LogoutButtonVariant.destructiveOutlined,
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
