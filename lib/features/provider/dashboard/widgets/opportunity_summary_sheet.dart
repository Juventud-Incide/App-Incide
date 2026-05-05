import 'package:flutter/material.dart';
import 'package:app_incide/features/provider/dashboard/models/opportunity_model.dart';

class OpportunitySummarySheet extends StatelessWidget {
  final OpportunityModel opportunity;
  final VoidCallback onSeeDetailsPressed;

  const OpportunitySummarySheet({
    super.key,
    required this.opportunity,
    required this.onSeeDetailsPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Definimos el color de la etiqueta según la urgencia
    Color labelColor;
    switch (opportunity.type) {
      case OpportunityType.urgent:
        labelColor = Colors.red;
        break;
      case OpportunityType.special:
        labelColor = Colors.orange;
        break;
      case OpportunityType.normal:
        labelColor = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Etiqueta de urgencia y Categoría
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: labelColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: labelColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  opportunity.urgencyLabel,
                  style: TextStyle(
                    color: labelColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                opportunity.category,
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Título del trabajo
          Text(
            opportunity.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // Distancia y Presupuesto
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.grey, size: 18),
              const SizedBox(width: 4),
              Text(
                opportunity.formattedDistance,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const Spacer(),
              const Icon(Icons.monetization_on, color: Colors.green, size: 18),
              const SizedBox(width: 4),
              Text(
                opportunity.formattedPriceRange,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Botón de Ver Detalles
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onSeeDetailsPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // O el color primario de INCIDE
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Ver Detalles Completos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // Un pequeño margen inferior por si el teléfono tiene barra de navegación nativa
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
