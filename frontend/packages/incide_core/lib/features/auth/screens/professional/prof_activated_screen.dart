import 'package:incide_core/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:incide_core/core/theme/app_colors.dart';
import 'package:incide_core/features/auth/providers/auth_provider.dart';

/// Pantalla de culminación del registro del Proveedor.
///
/// **Rol en la Arquitectura:**
/// Esta es la última pantalla de la fase "Pendiente". El usuario solo puede
/// verla si su `ApplicationStatus` es `activated`.
///
/// Al presionar el botón principal, se dispara un evento en Riverpod que cambia
/// el estatus global a `aceptado`, liberando al usuario hacia el Dashboard o
/// la solicitud de permisos GPS mediante el GoRouter.
class ProfActivatedScreen extends ConsumerWidget {
  const ProfActivatedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 30.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(flex: 1),

                    // --- 1. ILUSTRACIÓN / ICONO DE ÉXITO ---
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFF10B981,
                        ).withValues(alpha: 0.15), // Verde éxito suave
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        size: 65,
                        color: Color(0xFF10B981), // Verde éxito sólido
                      ),
                    ),
                    const SizedBox(height: 35),

                    // --- 2. TÍTULOS ---
                    const Text(
                      AppStrings.activationTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      AppStrings.activationSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textGray,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 35),

                    // --- 3. CAJA DE CONTEXTO (Siguiente paso: GPS) ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F5F7),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: AppColors.primaryBlue,
                            size: 32,
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            AppStrings.activationNextStepsTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppStrings.activationNextStepsSubtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 2),

                    // --- 4. BOTÓN DE ACCIÓN (Transición de Estado) ---
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ref
                              .read(authControllerProvider.notifier)
                              .completeActivation();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          AppStrings.activationNextStepsBtn,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
