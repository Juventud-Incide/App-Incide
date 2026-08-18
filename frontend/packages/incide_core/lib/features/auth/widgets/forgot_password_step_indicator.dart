import 'package:flutter/material.dart';
import 'package:incide_core/core/theme/app_colors.dart';

/// Barra de progreso animada para el flujo de Recuperación de Contraseña.
///
/// **Micro-Interacciones:**
/// Utiliza [AnimatedContainer] en lugar de un [Container] clásico. Esto provoca
/// que el cambio de color (de gris a azul) se renderice como una transición fluida
/// de 300ms en lugar de un corte brusco, mejorando la percepción de calidad (UX).
class ForgotPasswordStepIndicator extends StatelessWidget {
  /// Representa la posición activa actual en el flujo (1, 2 o 3).
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
