import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

/// Campo de entrada de texto universal (Input Field) estandarizado.
///
/// **Sistema de Diseño (Design System):**
/// Centraliza el diseño de los bordes, colores, márgenes y tipografías
/// de los `TextFormField`. Esto garantiza consistencia visual en toda la app
/// y facilita cambios globales de UI desde un solo archivo.
///
/// **Capacidades Especiales:**
/// - **Contraseñas:** Si [isPassword] es `true`, oculta el texto y añade automáticamente
///   un botón interactivo de "Ojo" (suffixIcon) para revelar la contraseña.
/// - **Validación Inyectada:** Acepta una función [validator] para integrarse
///   perfectamente con las llaves globales `FormState` de las pantallas padre.
class CustomInputField extends StatelessWidget {
  /// Texto que aparece arriba de la caja.
  final String label;

  /// Texto fantasma de ayuda dentro de la caja.
  final String hintText;

  /// Define si el campo debe ofuscar el texto (modo contraseña).
  final bool isPassword;

  /// Estado actual de visibilidad de la contraseña.
  final bool isPasswordVisible;

  /// Disparador del estado visual del "Ojo". Requerido si [isPassword] es true.
  final VoidCallback? onToggleVisibility;

  /// Controlador para extraer o inyectar texto al campo.
  final TextEditingController controller;

  /// Regla de negocio inyectada para mostrar errores en rojo.
  final String? Function(String?)? validator;

  /// Tipo de teclado nativo a mostrar (ej. numérico, email, teléfono).
  final TextInputType keyboardType;

  /// Reglas de mayúsculas automáticas (ej. para Nombres o CURP).
  final TextCapitalization textCapitalization;

  /// Número de líneas para campos de texto largos (ej. Descripciones).
  final int maxLines;

  /// Lista de formateadores de entrada para restringir o formatear el texto.
  final List<TextInputFormatter>? inputFormatters;

  /// Constructor de la clase.
  const CustomInputField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    this.isPasswordVisible = false,
    this.onToggleVisibility,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.inputFormatters,
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
          textCapitalization: textCapitalization,
          maxLines: isPassword ? 1 : maxLines,
          obscureText: isPassword && !isPasswordVisible,
          validator: validator,
          // Cambia el teclado si es correo para que muestre el '@' más fácil
          keyboardType: isPassword ? TextInputType.text : keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)), // Gris claro
            errorMaxLines: 3,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
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
