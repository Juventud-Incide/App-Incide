import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Indicador de pasos compartido para el flujo de recuperación de contraseña.
/// [currentStep]: pasos completados/activos (1, 2 o 3).
class ForgotPasswordStepIndicator extends StatelessWidget {
  final int currentStep;
  const ForgotPasswordStepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const Color inactiveColor = Color(0xFFE2E8F0);
    return Row(
      children: List.generate(3, (index) {
        final stepNum = index + 1;
        final isActive = stepNum <= currentStep;
        return Expanded(
          child: Row(
            children: [
              if (index > 0) const SizedBox(width: 8),
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primaryBlue : inactiveColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
