import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/role_card.dart'; // Importamos tu nuevo componente

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 1),

              // --- HEADER (Logo y Títulos) ---
              Image.asset('assets/images/Isotipo_Incide.png', width: 60),
              const SizedBox(height: 32),
              const Text(
                'Bienvenido a INCIDE',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '¿Cómo deseas usar la plataforma hoy?',
                style: TextStyle(color: AppColors.textGray, fontSize: 16),
              ),

              const SizedBox(height: 48),

              // --- TARJETAS DE SELECCIÓN ---
              RoleCard(
                title: 'Soy Cliente',
                description:
                    'Busco profesionistas certificados para realizar un trabajo o proyecto.',
                icon: Icons.home_outlined,
                iconColor: AppColors.primaryBlue,
                iconBgColor: AppColors.primaryBlue.withValues(alpha: 0.08),
                onTap: () {
                  context.push('/login-cliente');
                },
              ),
              const SizedBox(height: 20),
              RoleCard(
                title: 'Soy Profesionista',
                description:
                    'Quiero ofrecer mis servicios, recibir cotizaciones y gestionar mis trabajos.',
                icon: Icons.settings_outlined,
                iconColor: const Color(0xFFB48A14),
                iconBgColor: AppColors.accentYellow.withValues(alpha: 0.15),
                onTap: () {
                  context.push('/login');
                },
              ),

              const Spacer(flex: 2),

              // --- FOOTER ---
              const Text(
                'Podrás cambiar de perfil más adelante desde\ntu configuración.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textGray,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
