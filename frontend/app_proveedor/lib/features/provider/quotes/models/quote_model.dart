/// Define los posibles estados de una cotización a lo largo del ciclo de vida del servicio.
///
/// Este enum es la columna vertebral de la máquina de estados del módulo de cotizaciones.
/// Las extensiones de la UI (como colores y textos) se basan estrictamente en estos valores.
enum QuoteStatus {
  /// El proveedor envió su propuesta monetaria y está esperando la respuesta del cliente.
  pending,

  /// El cliente aceptó la cotización. El trabajo está oficialmente en ejecución.
  accepted,

  /// El cliente rechazó la propuesta (ej. por precio o tiempo). La cotización muere aquí.
  rejected,

  /// El servicio finalizó exitosamente. Requiere que ambas partes confirmen para llegar aquí.
  completed,

  /// El proveedor retiró su propuesta antes de ser aceptada, o el cliente canceló la solicitud general.
  cancelled,
}

/// Modelo inmutable que representa una solicitud de cotización o un trabajo en curso.
///
/// Este modelo actúa como un "contrato congelado". Una vez que un proveedor envía
/// una cotización, los datos clave de la oportunidad original se clonan aquí.
/// Esto garantiza que si el cliente modifica la oportunidad original más tarde,
/// el historial de esta cotización permanezca intacto.
class QuoteModel {
  /// Identificador único de la cotización generada en la base de datos.
  final String id;

  /// Identificador de la oportunidad original (el "post" del cliente) de la cual nació esta cotización.
  final String opportunityId;

  // ==========================================
  // 1. DATOS DEL CLIENTE (Revelados al cotizar)
  // ==========================================
  /// Identificador único del cliente en la base de datos.
  final String clientId;

  /// Nombre del cliente. Se revela al proveedor una vez que se envía la cotización o se abre el chat.
  final String clientName;

  /// Fotografía del cliente (Opcional).
  final String? clientAvatarUrl;

  /// Teléfono de contacto. Vital para trabajos en progreso ([QuoteStatus.accepted]).
  final String clientPhoneNumber;

  /// Dirección física donde se realizará el trabajo.
  final String? clientAddress;

  // ==========================================
  // 2. DATOS HEREDADOS (Clonados de la Oportunidad)
  // ==========================================
  /// Título del trabajo solicitado originalmente.
  final String title;

  /// Rubro del servicio (ej. "Albañilería", "Refrigeración").
  final String category;

  /// Descripción detallada del problema proporcionada por el cliente.
  final String description;

  /// Distancia calculada entre el proveedor y la ubicación del trabajo al momento de cotizar.
  final String distance;

  /// Nivel de urgencia seleccionado por el cliente (ej. "Lo antes posible").
  final String urgency;

  /// Si es `true`, esta cotización pertenece a una oportunidad enviada de forma directa y exclusiva a este proveedor.
  final bool isExclusive;

  /// Cuestionario dinámico respondido por el cliente sobre el problema específico.
  final Map<String, String> clientAnswers;

  /// Lista de URLs con evidencia fotográfica subida por el cliente.
  final List<String> photoUrls;

  // ==========================================
  // 3. DATOS DE LA COTIZACIÓN (El Negocio)
  // ==========================================
  /// Fecha y hora exactas en las que el cliente publicó la oportunidad original.
  final DateTime requestDate;

  /// Fecha y hora exactas en las que el proveedor envió esta propuesta monetaria.
  final DateTime dateQuoteSent;

  /// Precio propuesto por el proveedor.
  /// Es nullable (`double?`) en caso de que el modelo de negocio permita
  /// cotizaciones "A convenir tras revisión física".
  final double? finalPrice;

  /// Estado actual del trabajo en la máquina de estados.
  final QuoteStatus status;

  /// Contador de notificaciones locales.
  /// Representa la cantidad de mensajes del chat que el proveedor aún no ha leído.
  final int unreadMessagesCount;

  // --- MECANISMO DE CONSENSO (Anti-Abuso) ---

  /// Bandera que indica si el proveedor declaró que ya terminó el trabajo.
  final bool providerMarkedCompleted;

  /// Bandera que indica si el cliente validó que el trabajo se realizó satisfactoriamente.
  /// NOTA: El estado global [status] solo debe pasar a [QuoteStatus.completed]
  /// cuando ambas banderas sean `true`.
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

  /// Crea una nueva instancia de [QuoteModel] copiando los datos actuales
  /// y sobrescribiendo únicamente los valores que se pasen por parámetro.
  ///
  /// **Indispensable para Riverpod**: Al ser una clase inmutable, cualquier cambio
  /// (como un nuevo mensaje que altere `unreadMessagesCount` o un cambio a `status = accepted`)
  /// debe generar un nuevo objeto mediante este método para que la UI se actualice reactivamente.
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
