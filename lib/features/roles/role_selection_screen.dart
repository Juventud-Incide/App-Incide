import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'package:app_incide/core/constants/app_strings.dart';
import 'widgets/role_card.dart'; // Importamos tu nuevo componente

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 32.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(flex: 1),

                    // --- HEADER (Logo y Títulos) ---
                    Image.asset('assets/images/Isotipo_Incide.png', width: 60),
                    const SizedBox(height: 32),
                    const Text(
                      AppStrings.welcomeTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      AppStrings.welcomeSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textGray, fontSize: 16),
                    ),

                    const SizedBox(height: 48),

                    // --- TARJETAS DE SELECCIÓN ---
                    RoleCard(
                      key: const Key('client_role_card'),
                      title: AppStrings.roleClient,
                      description: AppStrings.roleClientDesc,
                      icon: Icons.home_outlined,
                      iconColor: AppColors.primaryBlue,
                      iconBgColor: AppColors.primaryBlue.withValues(
                        alpha: 0.08,
                      ),
                      onTap: () {
                        context.push('/login-cliente');
                      },
                    ),
                    const SizedBox(height: 20),
                    RoleCard(
                      key: const Key('professional_role_card'),
                      title: AppStrings.roleProfessional,
                      description: AppStrings.roleProfessionalDesc,
                      icon: Icons.settings_outlined,
                      iconColor: const Color(0xFFB48A14),
                      iconBgColor: AppColors.accentYellow.withValues(
                        alpha: 0.15,
                      ),
                      onTap: () {
                        context.push('/prof-login');
                      },
                    ),

                    const Spacer(flex: 2),

                    // --- FOOTER ---
                    const Text(
                      AppStrings.roleSelectionFooter,
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
          ],
        ),
      ),
    );
  }
}
