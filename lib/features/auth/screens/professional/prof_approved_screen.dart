import 'package:app_incide/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfApprovedScreen extends StatelessWidget {
  const ProfApprovedScreen({super.key});

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

              // --- 1. ILUSTRACIÓN / ICONO ---
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons
                      .handshake_rounded, // Un apretón de manos celebrando la entrevista
                  size: 55,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 30),

              // --- 2. TÍTULOS ---
              const Text(
                '¡Entrevista Aprobada!',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Nos encantó conocerte. Ya casi eres parte oficial de la red de profesionistas INCIDE.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textGray,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),

              // --- 3. CAJA DE CONTEXTO (Por qué pedimos documentos) ---
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
                      Icons.verified_user_rounded,
                      color: Color(0xFF10B981),
                      size: 30,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Último paso: Verificación Legal',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Para garantizar la seguridad de nuestros clientes, necesitamos que subas fotografías legibles de tus documentos oficiales. Tenlos a la mano.',
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

              // --- 4. BOTÓN DE ACCIÓN ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Aquí navegaremos a la pantalla de Subida de Documentos (Aún no creada)
                    // context.goNamed('prof_upload_docs');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Subir Documentos Ahora',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // --- 5. BOTÓN SECUNDARIO (Hacerlo después) ---
              TextButton(
                onPressed: () => context.go('/'), // Cerrar sesión
                child: const Text(
                  'Lo haré en otro momento',
                  style: TextStyle(
                    color: AppColors.textGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
