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
    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
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
}
