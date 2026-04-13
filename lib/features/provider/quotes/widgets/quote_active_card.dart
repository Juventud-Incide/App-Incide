import 'package:app_incide/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../models/quote_model.dart';
import 'package:app_incide/features/provider/quotes/models/quote_status_ext.dart';
import '../../../shared/widgets/quote_status_badge.dart';

class QuoteActiveCard extends StatelessWidget {
  final QuoteModel quote;
  final VoidCallback onOpenChat;
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
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        // 3. INKWELL: El botón gigante invisible
        child: InkWell(
          onTap:
              onTap, // La función de navegación que pasaste desde la pantalla
          child: Stack(
            children: [
              Padding(
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
                          style: TextStyle(
                            color: quote.status.textColor,
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
                      quote.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- FOOTER: Botón de Chat ---
                    SizedBox(
                      width: double.infinity,
                      child: Badge(
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
