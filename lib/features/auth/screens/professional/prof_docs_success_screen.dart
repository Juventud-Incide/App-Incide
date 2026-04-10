import 'package:app_incide/core/theme/app_colors.dart';
import 'package:app_incide/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de éxito al cargar documentos legales (Paso Final del Onboarding).
///
/// **Rol en la Arquitectura:**
/// Funciona como una pantalla de confirmación visual (Confirmation View).
/// Se muestra al usuario inmediatamente después de que el servidor confirma la
/// recepción exitosa de sus documentos (ej. INE, Comprobante de domicilio).
///
/// **Navegación:**
/// El único camino hacia adelante es la "Sala de Espera" (`/prof_review_status`).
/// Nota de Seguridad: Al enrutar hacia aquí, se recomienda usar `context.go()`
/// en lugar de `push()` para limpiar la pila de navegación y evitar que el usuario
/// presione "Atrás" para reenviar los mismos documentos.
class ProfDocsSuccessScreen extends StatelessWidget {
  const ProfDocsSuccessScreen({super.key});

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

              // --- 1. ICONO DE SEGURIDAD / ÉXITO ---
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified_user_rounded,
                      color: Colors.white,
                      size: 45,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- 2. TÍTULOS ---
              const Text(
                AppStrings.docsSentTitle,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                AppStrings.docsSentSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textGray,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),

              // --- 3. TARJETA DE INFORMACIÓN (Contexto de Próximos Pasos) ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F5F7),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.hourglass_top_rounded,
                      color: Colors.amber,
                      size: 28,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            AppStrings.nextStepsTitle,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            AppStrings.nextStepsSubtitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textGray,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // --- 4. BOTÓN DE ACCIÓN ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: () {
                    // Lo mandamos a la Sala de Espera
                    context.goNamed('prof_review_status');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(
                      color: AppColors.primaryBlue,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    AppStrings.seeStatusBtn,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
