/// Modelo de datos que representa una solicitud de trabajo (Oportunidad).
///
/// Esta clase es la entidad central del flujo del Proveedor en el Dashboard.
/// Encapsula toda la información que un profesional necesita evaluar antes de
/// enviar una cotización. Su diseño es inmutable para asegurar que los datos
/// mostrados en las tarjetas y en la vista de Detalles sean consistentes.
class OpportunityModel {
  /// Identificador único generado por la base de datos.
  final String id;

  /// Título corto y descriptivo del problema o trabajo (ej. "Fuga de agua en lavabo").
  final String title;

  /// Explicación detallada provista por el cliente en formato de texto libre.
  final String description;

  /// Distancia calculada en kilómetros desde la ubicación actual del proveedor.
  final double distance;

  /// Indica si el cliente pagó/solicitó que la oportunidad sea Premium.
  /// Afecta visualmente la UI (dispara los bordes y etiquetas color ámbar).
  final bool isExclusive;

  /// Categoría general del servicio para filtrado (ej. "Plomería", "Electricidad").
  final String category;

  /// Nivel de urgencia seleccionado por el cliente (ej. "Urgente", "Flexible").
  final String urgency;

  /// Límite inferior del presupuesto estimado por el sistema o por el cliente.
  final double estimatedPriceMin;

  /// Límite superior del presupuesto estimado.
  final double estimatedPriceMax;

  /// Diccionario que almacena el cuestionario dinámico respondido por el cliente.
  /// - Key (String): La pregunta formulada (ej. "¿De qué material es la tubería?").
  /// - Value (String): La respuesta del cliente (ej. "PVC o Cobre").
  /// Es iterado por la UI en la vista de detalles para generar la lista de requerimientos.
  final Map<String, String> clientAnswers;

  /// Lista de URLs apuntando al Storage (AWS S3/Firebase) con las imágenes del reporte.
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

  // ==========================================
  // GETTERS DE UI (Capa de Presentación)
  // ==========================================

  /// Formatea la distancia a un solo decimal para mantener la UI limpia.
  /// Ej: 4.5234 se convierte en "4.5 km"
  String get formattedDistance => '${distance.toStringAsFixed(1)} km';

  /// Devuelve el rango de precios formateado como moneda sin decimales.
  /// Ej: "$1500 - $3000"
  String get formattedPriceRange =>
      '\$${estimatedPriceMin.toInt()} - \$${estimatedPriceMax.toInt()}';

  // ==========================================
  // TODOs Y DEUDA TÉCNICA (Integración Backend)
  // ==========================================
  // TODO: (BACKEND) - Implementar el factory constructor `OpportunityModel.fromJson(Map<String, dynamic> json)`
  // para mapear automáticamente las respuestas JSON de la API.
  //
  // TODO: (BACKEND) - Agregar campos de temporalidad como `createdAt` (DateTime) para
  // ordenar el feed, y `expiresAt` (DateTime) para ocultar oportunidades caducadas.
}
