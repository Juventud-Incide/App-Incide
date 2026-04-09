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
    this.unreadMessagesCount = 0, // Por defecto no hay mensajes sin leer
    this.providerMarkedCompleted = false,
    this.clientMarkedCompleted = false,
  });
}
