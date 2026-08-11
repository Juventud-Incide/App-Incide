import 'package:flutter/material.dart';
import 'package:app_incide/features/provider/quotes/models/quote_status_ext.dart';
import 'package:app_incide/features/provider/quotes/models/quote_model.dart';

/// Un "Badge" (Etiqueta visual) reutilizable que indica el estado actual de una cotización.
///
/// **Propósito Arquitectónico (Delegación UI):**
/// Este componente es intencionalmente "tonto" (Dumb Widget). No contiene sentencias `if`
/// ni `switch` para calcular colores o textos. Toda esa responsabilidad se delega
/// a la extensión [QuoteStatusUI]. Esto garantiza que la etiqueta se vea exactamente
/// igual en las tarjetas miniatura y en la vista de detalle extendida.
class QuoteStatusBadge extends StatelessWidget {
  /// El estado actual de la cotización que dictará el color y el texto.
  final QuoteStatus status;

  /// Tamaño tipográfico ajustable para adaptarse a diferentes contextos de la UI
  /// (ej. 10px en listas comprimidas, 12px en la vista de detalles).
  final double fontSize;

  const QuoteStatusBadge({super.key, required this.status, this.fontSize = 10});

  @override
  Widget build(BuildContext context) {
    // MAGIA: El widget no calcula nada, solo le pide los datos al status
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        // Consumo de la extensión: El widget no sabe qué color es, solo lo aplica.
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        // Consumo de la extensión: El widget no sabe qué dice, solo lo renderiza.
        status.label,
        style: TextStyle(
          color: status.textColor,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
