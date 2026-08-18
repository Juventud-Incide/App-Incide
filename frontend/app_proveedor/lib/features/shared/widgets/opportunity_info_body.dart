import 'package:incide_core/core/constants/app_strings.dart';
import 'package:app_proveedor/features/shared/widgets/cached_gallery_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Componente visual compartido que renderiza la información central de un trabajo.
///
/// **Propósito Arquitectónico:**
/// Centraliza la presentación de los datos heredados de una solicitud.
/// Se utiliza tanto en la vista de detalle de Oportunidades Nuevas (Radar/Home)
/// como en la vista de Cotizaciones Activas ([QuoteDetailScreen]).
/// Esto garantiza una experiencia de usuario (UX) consistente: el proveedor
/// ve la información exactamente con el mismo formato antes y después de cotizar.
class OpportunityInfoBody extends StatelessWidget {
  /// Título principal del trabajo solicitado.
  final String title;

  /// Rubro general (ej. Albañilería, Plomería).
  final String category;

  /// Distancia formateada desde la ubicación del proveedor.
  final String distance;

  /// Nivel de urgencia requerido por el cliente.
  final String urgency;

  /// Rango de precio estimado o precio final propuesto.
  /// Es opcional (`null`) porque las Oportunidades nuevas podrían no tener
  /// un presupuesto definido aún.
  final String? priceRange;

  /// Descripción detallada del problema escrita por el cliente.
  final String description;

  /// Bandera que indica si este trabajo fue enviado de forma directa
  /// y exclusiva a este proveedor, renderizando un badge dorado.
  final bool isExclusive;

  /// Diccionario (Key-Value) con las preguntas predefinidas y las respuestas del cliente.
  final Map<String, String> clientAnswers;

  /// Lista de URLs de imágenes proporcionadas por el cliente como evidencia visual.
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
        // --- TÍTULO Y BADGE EXCLUSIVO ---
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
                  AppStrings.quoteExclusiveBadge,
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

        // --- INFO RÁPIDA (CHIPS RESPONSIVOS) ---
        // Se usa `Wrap` en lugar de `Row` para que si la pantalla es muy pequeña
        // o el texto es muy largo, los chips bajen automáticamente a la siguiente
        // línea sin causar un error de "Overflow".
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

        // --- CAJA DE PRESUPUESTO (Renderizado Condicional) ---
        if (priceRange != null) ...[
          _buildEstimatedPriceBox(priceRange!),
          const SizedBox(height: 24),
        ],

        // --- DESCRIPCIÓN DEL PROBLEMA ---
        const Text(
          AppStrings.quoteDescription,
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

        // --- CUESTIONARIO DINÁMICO (Q&A) ---
        // Solo se renderiza si el mapa de respuestas no está vacío.
        if (clientAnswers.isNotEmpty) ...[
          const Text(
            AppStrings.quoteClientSpecs,
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

        // --- GALERÍA MULTIMEDIA ---
        if (photoUrls.isNotEmpty) ...[
          const Text(
            AppStrings.attachedPhotos,
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

  // =================================--------------------------------------
  // WIDGETS AUXILIARES PRIVADOS
  // =================================--------------------------------------

  /// Construye un "Chip" informativo (Icono + Texto) con bordes redondeados.
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

  /// Construye la caja de alto contraste (verde) para mostrar importes económicos.
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

  /// Construye un bloque de Pregunta (gris) y Respuesta (oscura).
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

  /// Construye una lista horizontal scrolleable con las evidencias fotográficas.
  ///
  /// Implementa manejo de estados asíncronos (`loadingBuilder`) para mostrar
  /// un spinner mientras la imagen se descarga de la red, y `errorBuilder`
  /// en caso de que la URL esté rota o el usuario no tenga internet.
  Widget _buildPhotoGallery() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: photoUrls.length,
        itemBuilder: (context, index) {
          final imageUrl = photoUrls[index];

          // 2. EVALUACIÓN DE RED VS LOCAL
          final isNetworkImage = imageUrl.startsWith('http');

          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: isNetworkImage
                ? CachedGalleryImage(
                    imageUrl: imageUrl,
                    height: 100,
                    width: 100,
                    borderRadius: 12,
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      imageUrl,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 100,
                        width: 100,
                        color: Colors.red.shade100,
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
