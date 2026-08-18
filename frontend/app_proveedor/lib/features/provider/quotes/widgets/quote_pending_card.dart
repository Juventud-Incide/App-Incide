import 'package:incide_core/core/constants/app_strings.dart';
import 'package:app_proveedor/features/provider/quotes/widgets/chat_button_badge.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../shared/widgets/quote_status_badge.dart';
import '../models/quote_model.dart';
import '../models/quote_status_ext.dart';

/// Componente visual que representa una Cotización en estado de negociación ([QuoteStatus.pending]).
///
/// **Propósito Arquitectónico:**
/// Esta tarjeta es exclusiva para las cotizaciones que el proveedor ya envió,
/// pero que el cliente aún no ha aceptado. Por ello, incluye acciones destructivas
/// permitidas en esta fase, específicamente el botón de "Retirar Propuesta".
///
/// **Optimización de Rendimiento (UI):**
/// Al igual que su contraparte [QuoteActiveCard], utiliza un `Stack` con un `Positioned`
/// para la franja de color lateral, garantizando un renderizado ultra rápido sin
/// depender de cálculos de altura en tiempo real (`IntrinsicHeight`).
class QuotePendingCard extends StatelessWidget {
  /// El modelo de datos inmutable que alimenta la tarjeta.
  final QuoteModel quote;

  /// Callback ejecutado cuando el proveedor decide cancelar su oferta.
  /// Generalmente dispara un modal de confirmación antes de mutar el estado.
  final VoidCallback onRetractProposal;

  /// Callback ejecutado para abrir el hilo de comunicación con el cliente.
  final VoidCallback onOpenChat;

  /// Callback ejecutado al tocar el cuerpo de la tarjeta para navegar al detalle.
  final VoidCallback onTap;

  const QuotePendingCard({
    super.key,
    required this.quote,
    required this.onRetractProposal,
    required this.onOpenChat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      // Esencial para que el contenedor respete los bordes redondeados y recorte
      // la franja lateral y el efecto Ripple del InkWell.
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        // Borde uniforme obligatorio para compatibilidad con el motor Skia/Impeller
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              // 1. CONTENIDO PRINCIPAL
              Padding(
                // Padding asimétrico: 21px a la izquierda para evitar que el texto
                // choque con la franja de color de 5px.
                padding: const EdgeInsets.only(
                  left: 21,
                  right: 16,
                  top: 16,
                  bottom: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER: Etiqueta y Precio ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        QuoteStatusBadge(status: quote.status),
                        Text(
                          quote.finalPrice != null
                              ? '\$${quote.finalPrice!.toStringAsFixed(0)} MXN'
                              : AppStrings.quotePriceNotDefined,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // --- CUERPO: Título y Descripción ---
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
                      // TODO: Calcular las horas reales usando quote.dateQuoteSent
                      AppStrings.quoteSentTitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- FOOTER: Botones de Acción ---
                    Row(
                      children: [
                        // Botón: Retirar Propuesta
                        Expanded(
                          child: SizedBox(
                            // FIX DE DISEÑO: Forzamos altura de 48px (Estándar táctil)
                            // para igualar la altura geométrica con el ElevatedButton.icon
                            height: 48,
                            child: OutlinedButton(
                              onPressed: onRetractProposal,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                                side: BorderSide(color: Colors.grey.shade300),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                AppStrings.quoteRemoveBtn,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Botón: Abrir Chat (Con Badge de Notificación)
                        Expanded(
                          child: ChatButtonBadge(
                            chatId: quote.id.toString(),
                            onPressed: onOpenChat,
                            isPrimaryStyle: false,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. FRANJA LATERAL DINÁMICA
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
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
