import 'package:app_incide/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../models/quote_model.dart';
import 'package:app_incide/features/provider/quotes/models/quote_status_ext.dart';
import '../../../shared/widgets/quote_status_badge.dart';

/// Componente visual que representa una Cotización en un estado "Activo" o "Final".
///
/// **Propósito Arquitectónico:**
/// A diferencia de [QuotePendingCard], esta tarjeta está diseñada para cotizaciones
/// que ya pasaron la fase de negociación (ej. `accepted`, `completed`, `rejected`).
/// Por lo tanto, omite botones de cancelación y maximiza el espacio para la
/// descripción del problema y el botón de comunicación directa (Chat).
///
/// **Optimización de Rendimiento (UI):**
/// Utiliza un patrón de renderizado basado en `Stack` y `Positioned` para dibujar
/// la franja lateral de color dinámico. Esto asegura una complejidad de renderizado O(1)
/// y garantiza 60/120 FPS al hacer scroll, evitando el costoso widget `IntrinsicHeight`.
class QuoteActiveCard extends StatelessWidget {
  /// El modelo de datos inmutable que alimenta la tarjeta.
  final QuoteModel quote;

  /// Callback ejecutado cuando el proveedor presiona el botón "Abrir Chat".
  final VoidCallback onOpenChat;

  /// Callback ejecutado cuando el proveedor toca cualquier parte de la tarjeta
  /// para ver los detalles completos.
  final VoidCallback onTap;

  const QuoteActiveCard({
    super.key,
    required this.quote,
    required this.onOpenChat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      // Corta estrictamente cualquier contenido (como el Ripple Effect o el
      // ColoredBox) que intente salirse de las esquinas redondeadas.
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // Borde uniforme obligatorio en Flutter para poder usar borderRadius
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        // El InkWell envuelve todo el contenido para hacer la tarjeta clickeable
        child: InkWell(
          onTap:
              onTap, // La función de navegación que pasaste desde la pantalla
          child: Stack(
            children: [
              // 1. CONTENIDO PRINCIPAL
              Padding(
                padding: const EdgeInsets.only(
                  // El padding izquierdo (21) compensa el ancho de la franja (5) + el margen normal (16)
                  left: 21,
                  right: 16,
                  top: 16,
                  bottom: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER: Etiqueta Semántica y Precio ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Inyección automática del color y texto del estado actual
                        QuoteStatusBadge(status: quote.status),
                        Text(
                          quote.finalPrice != null
                              ? '\$${quote.finalPrice!.toStringAsFixed(0)} MXN'
                              : AppStrings.quotePriceNotDefined,
                          style: TextStyle(
                            // El precio hereda el color de alto contraste del estado
                            color: quote.status.textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // --- CUERPO: Título y Descripción Truncada ---
                    Text(
                      quote.title,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      quote.description,
                      maxLines:
                          2, // Previene que textos muy largos rompan el layout
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- FOOTER: Botón de Chat (100% Width) ---
                    SizedBox(
                      width: double.infinity,
                      child: Badge(
                        // La burbuja de notificación solo aparece si hay mensajes pendientes
                        isLabelVisible: quote.unreadMessagesCount > 0,
                        label: Text(quote.unreadMessagesCount.toString()),
                        backgroundColor: Colors.red,
                        offset: const Offset(4, -4),
                        child: ElevatedButton.icon(
                          onPressed: onOpenChat,
                          icon: const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 18,
                          ),
                          label: const Text(
                            'Abrir Chat',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColors.primaryBlue.withValues(
                              alpha: 0.1,
                            ),
                            foregroundColor: AppColors.primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 2. FRANJA LATERAL DINÁMICA
              Positioned(
                left: 0,
                top: 0,
                bottom:
                    0, // Al anclar top y bottom a 0, toma la altura automática del contenido
                width: 5,
                child: ColoredBox(color: quote.status.indicatorColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
