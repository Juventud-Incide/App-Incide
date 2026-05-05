/// Define el tipo de oportunidad para codificar visualmente los pines en el mapa
/// y el nivel de prioridad en el feed.
enum OpportunityType {
  normal, // Pin Azul: Solicitud pública estándar
  urgent, // Pin Rojo: El cliente requiere atención inmediata
  special, // Pin Amarillo/Dorado: Cotización directa al perfil del proveedor
}

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

  // ==========================================
  // DATOS GEOGRÁFICOS (Para Google Maps)
  // ==========================================

  /// Latitud exacta del domicilio o ubicación del problema.
  final double latitude;

  /// Longitud exacta del domicilio o ubicación del problema.
  final double longitude;

  /// Distancia calculada en kilómetros desde la ubicación actual del proveedor.
  /// NOTA: Este valor puede calcularse localmente usando la fórmula de Haversine
  /// o venir pre-calculado desde el backend.
  final double distance;

  // ==========================================
  // CLASIFICACIÓN Y NEGOCIO
  // ==========================================

  /// Define el nivel de urgencia y exclusividad para la lógica del Mapa.
  final OpportunityType type;

  /// Categoría general del servicio para filtrado (ej. "Plomería", "Electricidad").
  final String category;

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

  /// Fecha exacta en la que el cliente publicó la solicitud.
  final DateTime createdAt;

  OpportunityModel({
    required this.id,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.type,
    required this.category,
    required this.estimatedPriceMin,
    required this.estimatedPriceMax,
    required this.clientAnswers,
    required this.createdAt,
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

  /// Getter de compatibilidad por si la UI antigua dependía de este booleano.
  bool get isExclusive => type == OpportunityType.special;

  /// Devuelve un texto amigable dependiendo del tipo de oportunidad.
  String get urgencyLabel {
    switch (type) {
      case OpportunityType.urgent:
        return 'Urgente';
      case OpportunityType.special:
        return 'Cotización Directa';
      case OpportunityType.normal:
        return 'Flexible';
    }
  }

  // ==========================================
  // TODOs Y DEUDA TÉCNICA (Integración Backend)
  // ==========================================
  // TODO: (BACKEND) - Implementar el factory constructor `OpportunityModel.fromJson(Map<String, dynamic> json)`
  // para mapear automáticamente las respuestas JSON de la API.
  //
  // TODO: (BACKEND) - Agregar campos de temporalidad como `createdAt` (DateTime) para
  // ordenar el feed, y `expiresAt` (DateTime) para ocultar oportunidades caducadas.
}
