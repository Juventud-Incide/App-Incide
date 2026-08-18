import 'package:incide_core/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Campo de selección desplegable (Dropdown) estandarizado.
///
/// **Arquitectura Genérica (`<T>`):**
/// Esta clase utiliza genéricos de Dart para permitir que el valor seleccionado
/// sea de cualquier tipo (String, int, o un Modelo de Datos complejo), no solo texto.
///
/// Integra automáticamente el diseño de la aplicación (bordes, colores de foco)
/// y soporta validación nativa de [FormState].
class CustomDropdownField<T> extends StatelessWidget {
  /// Título superior fuera de la caja de texto. Si está vacío, no se renderiza.
  final String label;

  /// Texto de ayuda mostrado cuando no hay ningún elemento seleccionado.
  final String hintText;

  /// El valor actualmente seleccionado. Debe coincidir con el valor de uno de los [items].
  final T? value;

  /// Lista de opciones renderizadas en el menú desplegable.
  final List<DropdownMenuItem<T>> items;

  /// Callback ejecutado cuando el usuario elige una nueva opción.
  final void Function(T?)? onChanged;

  /// Función inyectada para validar si la selección actual cumple con las reglas de negocio.
  final String? Function(T?)? validator;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.hintText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
        ],
        DropdownButtonFormField<T>(
          isExpanded: true,
          initialValue: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textGray,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black12, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primaryBlue,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
