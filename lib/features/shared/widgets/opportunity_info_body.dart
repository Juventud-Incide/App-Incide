import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Componente compartido que pinta la información central de un trabajo.
/// Usado tanto en Oportunidades Nuevas (Home) como en Cotizaciones Activas (Mis Cotizaciones).
class OpportunityInfoBody extends StatelessWidget {
  final String title;
  final String category;
  final String distance;
  final String urgency;
  final String? priceRange;
  final String description;
  final bool isExclusive;
  final Map<String, String> clientAnswers;
  final List<String> photoUrls;

  const OpportunityInfoBody({
    super.key,
    required this.title,
    required this.category,
    required this.distance,
    required this.urgency,
    this.priceRange,
    required this.description,
    this.isExclusive = false,
    this.clientAnswers = const {},
    this.photoUrls = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- TÍTULO Y BADGE ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
            ),
            if (isExclusive) ...[
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'EXCLUSIVA',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 24),

        // --- INFO RÁPIDA (CHIPS) ---
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: [
            _infoChip(Icons.build_rounded, category),
            _infoChip(Icons.location_on_rounded, distance),
            _infoChip(Icons.access_time_filled_rounded, urgency),
          ],
        ),
        const SizedBox(height: 24),

        if (priceRange != null) ...[
          _buildEstimatedPriceBox(priceRange!),
          const SizedBox(height: 24),
        ],

        // --- DESCRIPCIÓN ---
        const Text(
          'Descripción del Problema',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textGray,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),

        // --- PREGUNTAS DEL CLIENTE (NUEVO) ---
        if (clientAnswers.isNotEmpty) ...[
          const Text(
            'Especificaciones del Cliente',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          ...clientAnswers.entries.map(
            (entry) => _buildQuestionAnswer(entry.key, entry.value),
          ),
          const SizedBox(height: 32),
        ],

        // --- FOTOS ADJUNTAS (NUEVO) ---
        if (photoUrls.isNotEmpty) ...[
          const Text(
            'Fotos Adjuntas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          _buildPhotoGallery(),
          const SizedBox(height: 32),
        ],
      ],
    );
  }

  // --- MÉTODOS INTERNOS ---
  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryBlue),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstimatedPriceBox(String price) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Presupuesto / Propuesta',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Text(
                'Calculado por el sistema',
                style: TextStyle(fontSize: 11, color: Colors.green),
              ),
            ],
          ),
          Text(
            price,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.green[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionAnswer(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textGray,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: const TextStyle(fontSize: 14, color: AppColors.textDark),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGallery() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: photoUrls.length,
        itemBuilder: (context, index) {
          final imageUrl = photoUrls[index];

          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            // Usamos ClipRRect para redondear las esquinas de la imagen
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover, // Llena el contenedor
                // Mientras la imagen se descarga de internet...
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },

                // Si la URL está rota o no hay internet...
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
