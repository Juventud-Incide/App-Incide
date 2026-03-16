import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final String hintText;
  final bool isPassword;
  final bool isPasswordVisible;
  final VoidCallback? onToggleVisibility;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const CustomInputField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onToggleVisibility,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- LA ETIQUETA SUPERIOR ---
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF4B5563), // Gris oscuro
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        // --- EL CAMPO DE TEXTO ---
        TextFormField(
          controller: controller,
          obscureText: isPassword && !isPasswordVisible,
          validator: validator,
          // Cambia el teclado si es correo para que muestre el '@' más fácil
          keyboardType: isPassword
              ? TextInputType.text
              : TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)), // Gris claro
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),

            // Bordes personalizados para que coincidan con Figma
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(
                color: AppColors.primaryBlue,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),

            // El "Ojito" para contraseñas
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.primaryBlue,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
