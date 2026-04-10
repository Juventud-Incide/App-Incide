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
  final String clientId;
  final String clientName;
  final String? clientAvatarUrl;
  final String clientPhoneNumber;
  final String serviceCategory;
  final String problemDescription;
  final DateTime requestDate;
  final DateTime dateQuoteSent;
  final double? estimatedPrice;
  final QuoteStatus status;
  final String? clientAddress;

  final Map<String, String> clientAnswers;
  final List<String> photoUrls;
  final bool isExclusive;

  /// Indicador para la "burbujita" de notificaciones en el botón del chat
  final int unreadMessagesCount;

  /// Seguridad Anti-Abuso: Ambas banderas deben ser true para pasar a status.completed
  final bool providerMarkedCompleted;
  final bool clientMarkedCompleted;

  QuoteModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    this.clientAvatarUrl,
    required this.clientPhoneNumber,
    required this.serviceCategory,
    required this.problemDescription,
    required this.requestDate,
    required this.dateQuoteSent,
    this.estimatedPrice,
    this.status = QuoteStatus.pending,
    this.clientAddress,
    this.clientAnswers = const {},
    this.photoUrls = const [],
    this.unreadMessagesCount = 0, // Por defecto no hay mensajes sin leer
    this.providerMarkedCompleted = false,
    this.clientMarkedCompleted = false,
    this.isExclusive = false,
  });

  /// Crea una copia exacta de este objeto, permitiendo modificar campos específicos.
  /// Crucial para el manejo de estado inmutable con Riverpod.
  QuoteModel copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? clientAvatarUrl,
    String? clientPhoneNumber,
    String? serviceCategory,
    String? problemDescription,
    DateTime? requestDate,
    DateTime? dateQuoteSent,
    double? estimatedPrice,
    QuoteStatus? status,
    String? clientAddress,
    Map<String, String>? clientAnswers,
    List<String>? photoUrls,
    int? unreadMessagesCount,
    bool? providerMarkedCompleted,
    bool? clientMarkedCompleted,
    bool? isExclusive,
  }) {
    return QuoteModel(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientAvatarUrl: clientAvatarUrl ?? this.clientAvatarUrl,
      clientPhoneNumber: clientPhoneNumber ?? this.clientPhoneNumber,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      problemDescription: problemDescription ?? this.problemDescription,
      requestDate: requestDate ?? this.requestDate,
      dateQuoteSent: dateQuoteSent ?? this.dateQuoteSent,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      status: status ?? this.status,
      clientAddress: clientAddress ?? this.clientAddress,
      clientAnswers: clientAnswers ?? this.clientAnswers,
      photoUrls: photoUrls ?? this.photoUrls,
      unreadMessagesCount: unreadMessagesCount ?? this.unreadMessagesCount,
      providerMarkedCompleted:
          providerMarkedCompleted ?? this.providerMarkedCompleted,
      clientMarkedCompleted:
          clientMarkedCompleted ?? this.clientMarkedCompleted,
      isExclusive: isExclusive ?? this.isExclusive,
    );
  }
}
