class OpportunityModel {
  final String id;
  final String title;
  final String description;
  final double distance;
  final bool isExclusive;
  final String category;
  final String urgency;
  final double estimatedPriceMin;
  final double estimatedPriceMax;
  final Map<String, String> clientAnswers; // Pregunta: Respuesta
  final List<String> photoUrls;

  OpportunityModel({
    required this.id,
    required this.title,
    required this.description,
    required this.distance,
    required this.isExclusive,
    required this.category,
    required this.urgency,
    required this.estimatedPriceMin,
    required this.estimatedPriceMax,
    required this.clientAnswers,
    this.photoUrls = const [],
  });

  // Getters útiles para la UI
  String get formattedDistance => '${distance.toStringAsFixed(1)} km';
  String get formattedPriceRange =>
      '\$${estimatedPriceMin.toInt()} - \$${estimatedPriceMax.toInt()}';
}
