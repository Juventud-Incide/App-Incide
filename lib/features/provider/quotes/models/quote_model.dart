/// Define los posibles estados de una cotización en el ciclo de vida del servicio.
enum QuoteStatus {
  pending, // En Espera: El proveedor envió propuesta
  accepted, // Aceptada/En Progreso: Trabajo activo
  rejected, // Rechazada: El cliente no aceptó
  completed, // Terminada: AMBAS partes confirmaron la finalización
  cancelled, // Cancelada o Propuesta Retirada
}

/// Modelo de datos que representa una solicitud de cotización o un trabajo activo.
class QuoteModel {
  final String id;
  final String opportunityId;

  // ==========================================
  // 1. DATOS DEL CLIENTE (Revelados al cotizar)
  // ==========================================
  final String clientId;
  final String clientName;
  final String? clientAvatarUrl;
  final String clientPhoneNumber;
  final String? clientAddress;

  // ==========================================
  // 2. DATOS HEREDADOS (Clonados de la Oportunidad)
  // ==========================================
  final String title;
  final String category;
  final String description;
  final String distance;
  final String urgency;
  final bool isExclusive;
  final Map<String, String> clientAnswers;
  final List<String> photoUrls;

  // ==========================================
  // 3. DATOS DE LA COTIZACIÓN (El Negocio)
  // ==========================================
  final DateTime requestDate;
  final DateTime dateQuoteSent;
  final double? finalPrice;
  final QuoteStatus status;

  /// Indicador para la "burbujita" de notificaciones en el botón del chat
  final int unreadMessagesCount;

  /// Seguridad Anti-Abuso: Ambas banderas deben ser true para pasar a status.completed
  final bool providerMarkedCompleted;
  final bool clientMarkedCompleted;

  QuoteModel({
    required this.id,
    required this.opportunityId,
    required this.clientId,
    required this.clientName,
    this.clientAvatarUrl,
    required this.clientPhoneNumber,
    this.clientAddress,
    required this.title,
    required this.category,
    required this.description,
    required this.distance,
    required this.urgency,
    this.isExclusive = false,
    this.clientAnswers = const {},
    this.photoUrls = const [],
    required this.requestDate,
    required this.dateQuoteSent,
    this.finalPrice,
    this.status = QuoteStatus.pending,
    this.unreadMessagesCount = 0, // Por defecto no hay mensajes sin leer
    this.providerMarkedCompleted = false,
    this.clientMarkedCompleted = false,
  });

  /// Crea una copia exacta de este objeto, permitiendo modificar campos específicos.
  /// Crucial para el manejo de estado inmutable con Riverpod.
  QuoteModel copyWith({
    String? id,
    String? opportunityId,
    String? clientId,
    String? clientName,
    String? clientAvatarUrl,
    String? clientPhoneNumber,
    String? clientAddress,
    String? title,
    String? category,
    String? description,
    String? distance,
    String? urgency,
    bool? isExclusive,
    Map<String, String>? clientAnswers,
    List<String>? photoUrls,
    DateTime? requestDate,
    DateTime? dateQuoteSent,
    double? finalPrice,
    QuoteStatus? status,
    int? unreadMessagesCount,
    bool? providerMarkedCompleted,
    bool? clientMarkedCompleted,
  }) {
    return QuoteModel(
      id: id ?? this.id,
      opportunityId: opportunityId ?? this.opportunityId,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientAvatarUrl: clientAvatarUrl ?? this.clientAvatarUrl,
      clientPhoneNumber: clientPhoneNumber ?? this.clientPhoneNumber,
      clientAddress: clientAddress ?? this.clientAddress,
      title: title ?? this.title,
      category: category ?? this.category,
      description: description ?? this.description,
      distance: distance ?? this.distance,
      urgency: urgency ?? this.urgency,
      isExclusive: isExclusive ?? this.isExclusive,
      clientAnswers: clientAnswers ?? this.clientAnswers,
      photoUrls: photoUrls ?? this.photoUrls,
      requestDate: requestDate ?? this.requestDate,
      dateQuoteSent: dateQuoteSent ?? this.dateQuoteSent,
      finalPrice: finalPrice ?? this.finalPrice,
      status: status ?? this.status,
      unreadMessagesCount: unreadMessagesCount ?? this.unreadMessagesCount,
      providerMarkedCompleted:
          providerMarkedCompleted ?? this.providerMarkedCompleted,
      clientMarkedCompleted:
          clientMarkedCompleted ?? this.clientMarkedCompleted,
    );
  }
}
