import 'package:flutter/material.dart';
import 'package:app_incide/features/provider/quotes/models/quote_status_ext.dart';
import 'package:app_incide/features/provider/quotes/models/quote_model.dart';

class QuoteStatusBadge extends StatelessWidget {
  final QuoteStatus status;
  final double fontSize;

  const QuoteStatusBadge({super.key, required this.status, this.fontSize = 10});

  @override
  Widget build(BuildContext context) {
    // MAGIA: El widget no calcula nada, solo le pide los datos al status
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
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
