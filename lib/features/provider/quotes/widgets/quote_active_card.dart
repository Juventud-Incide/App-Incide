import 'package:app_incide/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../models/quote_model.dart';

class QuoteActiveCard extends StatelessWidget {
  final QuoteModel quote;
  final VoidCallback onOpenChat;

  const QuoteActiveCard({
    super.key,
    required this.quote,
    required this.onOpenChat,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = quote.status == QuoteStatus.completed;
    final statusColor = isCompleted
        ? const Color(0xFF3B82F6)
        : const Color(0xFF10B981);
    final statusText = isCompleted
        ? AppStrings.quoteCompletedTitle
        : AppStrings.quoteAcceptedTitle;
    final statusBgColor = isCompleted
        ? const Color(0xFFEFF6FF)
        : const Color(0xFFD1FAE5);

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
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- LA FRANJA LATERAL DE COLOR ---
            Container(width: 5, color: statusColor),

            // --- EL CONTENIDO ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER: Etiqueta y Precio ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Text(
                          quote.estimatedPrice != null
                              ? '\$${quote.estimatedPrice!.toStringAsFixed(0)} MXN'
                              : AppStrings.quotePriceNotDefined,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // --- CUERPO: Título y Descripción ---
                    Text(
                      quote.serviceCategory,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      quote.problemDescription,
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
            ),
          ],
        ),
      ),
    );
  }
}
