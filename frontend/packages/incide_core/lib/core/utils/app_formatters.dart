import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

/// Centraliza todos los formateadores de entrada de la aplicación.
/// Facilita la reutilización y garantiza que las validaciones sean
/// idénticas en todas las pantallas de INCIDE.
class AppFormatters {
  AppFormatters._();

  // 1. SOLO LETRAS Y ESPACIOS (Nombres, Apellidos, Ciudades)
  static final nameFormatter = [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
  ];

  // 2. SOLO NÚMEROS ENTEROS (IDs, Cantidades fijas)
  static final digitsOnly = [FilteringTextInputFormatter.digitsOnly];

  // 3. SIN ESPACIOS (Correos, Contraseñas, Usuarios)
  static final noSpaces = [FilteringTextInputFormatter.deny(RegExp(r'\s'))];

  // 4. PRECIOS Y COTIZACIONES (Números con hasta 2 decimales)
  static final priceFormatter = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
    TextInputFormatter.withFunction((oldValue, newValue) {
      if (newValue.text.isEmpty) return newValue;

      // \d* permite que empiece con punto (ej. .50).
      // \.? permite máximo un punto.
      // \d{0,2}$ permite máximo 2 decimales.
      final regEx = RegExp(r'^\d*\.?\d{0,2}$');

      if (regEx.hasMatch(newValue.text)) {
        return newValue;
      }
      return oldValue;
    }),
  ];

  // 5. DOCUMENTOS OFICIALES (Alfanumérico, sin caracteres especiales)
  static final rfcFormatter = [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
    LengthLimitingTextInputFormatter(13),
  ];

  static final curpFormatter = [
    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
    LengthLimitingTextInputFormatter(18),
  ];

  // 6. MÁSCARA DE TELÉFONO (Formato visual automático)
  static final phoneMask = MaskTextInputFormatter(
    mask: '(###) ###-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  // 7. FORMATO DE MONEDA CON COMAS (Al vuelo)
  static final currencyFormatter = [CurrencyInputFormatter()];

  // 8. CLABE INTERBANCARIA (Exactamente 18 dígitos)
  static final clabeFormatter = [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(18),
  ];
}

/// Formateador personalizado que agrega comas a los miles
/// mientras el usuario escribe, respetando hasta 2 decimales.
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    // 1. Quitar comas para validar el número puro
    String newCleanText = newValue.text.replaceAll(',', '');

    // 2. Validar que sea un número válido con hasta 2 decimales
    final regEx = RegExp(r'^\d*\.?\d{0,2}$');
    if (!regEx.hasMatch(newCleanText)) return oldValue;

    // 3. Separar la parte entera de la decimal
    final parts = newCleanText.split('.');
    String intPart = parts[0];
    String decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    // 4. Agregar comas a la parte entera usando Expresión Regular
    if (intPart.isNotEmpty) {
      intPart = intPart.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    }

    final formattedText = intPart + decimalPart;

    // 5. Calcular posición del cursor para que no salte al inicio
    int cursorPosition =
        formattedText.length - (newValue.text.length - newValue.selection.end);
    cursorPosition = cursorPosition.clamp(0, formattedText.length);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}
