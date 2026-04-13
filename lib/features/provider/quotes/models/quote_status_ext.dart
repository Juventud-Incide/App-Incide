import 'package:flutter/material.dart';
import 'package:app_incide/core/constants/app_strings.dart';
import 'package:app_incide/features/provider/quotes/models/quote_model.dart';

extension QuoteStatusUI on QuoteStatus {
  /// Devuelve el texto a mostrar según el estado
  String get label {
    switch (this) {
      case QuoteStatus.pending:
        return AppStrings.quotePendingTitle; // "En Espera"
      case QuoteStatus.accepted:
        return AppStrings.quoteAcceptedTitle; // "Aceptado"
      case QuoteStatus.completed:
        return AppStrings.quoteCompletedTitle; // "Completado"
      case QuoteStatus.rejected:
        return AppStrings.quoteRejectedTitle; // "Rechazado"
      case QuoteStatus.cancelled:
        return AppStrings.quoteCancelledTitle; // "Cancelado"
    }
  }

  /// Devuelve el color principal del texto y bordes
  Color get textColor {
    switch (this) {
      case QuoteStatus.pending:
        return const Color(0xFFD97706); // Naranja/Ambar
      case QuoteStatus.accepted:
        return const Color(0xFF059669); // Verde Esmeralda
      case QuoteStatus.completed:
        return const Color(0xFF3B82F6); // Azul
      case QuoteStatus.rejected:
        // PSICOLOGÍA DEL COLOR: Un gris pizarra o un rojo muy desaturado (casi pastel).
        // Evitamos el rojo puro (#FF0000) porque genera estrés o sensación de "error grave".
        // Este es un gris azulado suave (Slate 500).
        return const Color(0xFF64748B);
      case QuoteStatus.cancelled:
        return const Color(0xFF9CA3AF); // Gris claro
    }
  }

  /// Devuelve el color de fondo suave (con opacidad o versión clara)
  Color get backgroundColor {
    switch (this) {
      case QuoteStatus.pending:
        return const Color(0xFFFEF3C7);
      case QuoteStatus.accepted:
        return const Color(0xFFD1FAE5);
      case QuoteStatus.completed:
        return const Color(0xFFEFF6FF);
      case QuoteStatus.rejected:
        return const Color(0xFFF1F5F9); // Fondo gris muy sutil
      case QuoteStatus.cancelled:
        return const Color(0xFFF3F4F6);
    }
  }

  /// Devuelve el color fuerte para barras laterales, bordes o íconos.
  /// Por ahora, es un reflejo exacto del color del texto para mantener consistencia.
  Color get indicatorColor {
    return textColor;
  }
}
