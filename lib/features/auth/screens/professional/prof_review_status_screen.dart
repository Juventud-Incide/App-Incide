import 'package:app_incide/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfReviewStatusScreen extends StatelessWidget {
  const ProfReviewStatusScreen({super.key});

  // Helper para construir cada fila del timeline
  Widget _buildTimelineStep({required String title, required Color dotColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 15),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Colores basados en el prototipo
    const Color greenStatus = Color(0xFF10B981); // Verde para completado
    const Color blueStatus = AppColors.primaryBlue; // Azul para activo
    const Color grayStatus = Color(0xFFD1D5DB); // Gris para pendiente

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 1),

              // --- 1. ICONO CENTRAL (Reloj) ---
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.access_time_rounded,
                  size: 45,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 25),

              // --- 2. TÍTULO Y DESCRIPCIÓN ---
              const Text(
                'Cuenta en Revisión',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Hemos recibido tu solicitud de registro. Nuestro equipo administrativo validará tu perfil para agendar tu Entrevista Presencial.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textGray,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 35),

              // --- 3. TIMELINE (ESTADO DEL PROCESO) ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F5F7), // Gris muy claro
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTimelineStep(
                      title: 'Solicitud enviada',
                      dotColor: greenStatus,
                    ),
                    _buildTimelineStep(
                      title: 'Revisión de INCIDE',
                      dotColor: blueStatus,
                    ),
                    _buildTimelineStep(
                      title: 'Entrevista Presencial',
                      dotColor: grayStatus,
                    ),
                    // El último paso no lleva padding inferior
                    Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: grayStatus,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Text(
                          'Activación de cuenta',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // --- 4. BOTÓN CERRAR SESIÓN ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: () {
                    // Limpia la pila de navegación y regresa al inicio (Splash o Roles)
                    context.go('/');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
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
