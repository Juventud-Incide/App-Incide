import 'package:flutter/material.dart';
import 'package:app_incide/core/constants/app_strings.dart';
import 'package:app_incide/features/provider/quotes/models/quote_model.dart';

/// Extensión de Presentación (UI) para el enum [QuoteStatus].
///
/// **Propósito Arquitectónico:** /// Separa estrictamente la lógica de datos de la lógica visual (Separation of Concerns).
/// En lugar de que los Widgets calculen qué color o texto mostrar usando múltiples
/// operadores ternarios o sentencias `switch`, delegan esa responsabilidad a esta extensión.
/// Esto hace que agregar un nuevo estado en el futuro requiera modificar un solo archivo.
extension QuoteStatusUI on QuoteStatus {
  /// Obtiene la etiqueta de texto (String) correspondiente al estado actual.
  ///
  /// Se conecta directamente al archivo de constantes de idioma ([AppStrings])
  /// para garantizar que la aplicación esté lista para internacionalización (i18n)
  /// o simplemente para mantener consistencia tipográfica en todas las pantallas.
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

  /// Obtiene el color principal y de alto contraste del estado.
  ///
  /// Se utiliza principalmente para el texto interno de los badges (etiquetas)
  /// y para íconos pequeños. Los colores están basados en psicología del usuario
  /// para denotar éxito (verde), espera (ámbar), finalidad (azul) o neutralidad (gris).
  Color get textColor {
    switch (this) {
      case QuoteStatus.pending:
        return const Color(
          0xFFD97706,
        ); // Naranja/Ámbar: Requiere paciencia/acción pendiente.
      case QuoteStatus.accepted:
        return const Color(
          0xFF059669,
        ); // Verde Esmeralda: Vía libre, trato cerrado.
      case QuoteStatus.completed:
        return const Color(
          0xFF3B82F6,
        ); // Azul: Proceso finalizado exitosamente.
      case QuoteStatus.rejected:
        // PSICOLOGÍA DEL COLOR: Un gris pizarra (Slate 500).
        // Evitamos el rojo puro (#FF0000) porque genera estrés o sensación de "error grave".
        return const Color(0xFF64748B);
      case QuoteStatus.cancelled:
        return const Color(
          0xFF9CA3AF,
        ); // Gris claro: Inactivo, sin relevancia actual.
    }
  }

  /// Obtiene el color de fondo suave (pastel/transparente) del estado.
  ///
  /// Diseñado específicamente para emparejarse con [textColor].
  /// Se usa como color de fondo en componentes como el [QuoteStatusBadge]
  /// para asegurar accesibilidad y alto contraste de lectura.
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

  /// Obtiene el color semántico primario para acentos estructurales.
  ///
  /// Se usa para elementos grandes de UI, como la franja lateral (`BorderSide`)
  /// de las tarjetas de cotización ([QuoteActiveCard], [QuotePendingCard]).
  /// Aunque por ahora retorna el mismo valor que [textColor], separarlo semánticamente
  /// permite que en el futuro el diseñador pueda cambiar el borde de color sin afectar
  /// el color de las letras.
  Color get indicatorColor {
    return textColor;
  }
}
