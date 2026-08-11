/// Enumeración que representa la Máquina de Estados del proceso de admisión.
///
/// Define las etapas por las que debe pasar un proveedor antes de que
/// se le permita el acceso al Dashboard principal de la aplicación.
enum ApplicationStatus {
  /// 1. Recién registrado. Sus datos iniciales están siendo revisados.
  /// (Redirige a: /prof-review-status)
  pendingReview,

  /// 2. Se le asignó una entrevista presencial/virtual.
  /// (Redirige a: /prof-review-status)
  interviewScheduled,

  /// 3. Pasó la entrevista. Se le invita a subir documentos.
  /// Está en proceso de subir los documentos oficiales.
  /// (Redirige a: /prof-approved)
  uploadingDocs,

  /// 5. Subió los documentos. Esperando validación final en backoffice.
  /// (Redirige a: /prof-review-status)
  validatingDocs,

  /// 5.1. Si el backoffice encuentra algún error en los documentos, se le pide que los corrija y vuelva a subirlos.
  /// (Redirige a: /prof-docs-revision)
  correctingDocs,

  /// 6. Proceso completado. La cuenta está lista para entrar.
  /// (Redirige a: /prof-activated)
  activated,

  /// Estado por defecto si el backend manda algo desconocido.
  unknown,
}

/// Helper para convertir el String del backend/disco al Enum de Flutter.
ApplicationStatus parseAppStatus(String? status) {
  switch (status) {
    case 'pendingReview':
      return ApplicationStatus.pendingReview;
    case 'interviewScheduled':
      return ApplicationStatus.interviewScheduled;
    case 'uploadingDocs':
      return ApplicationStatus.uploadingDocs;
    case 'validatingDocs':
      return ApplicationStatus.validatingDocs;
    case 'activated':
      return ApplicationStatus.activated;
    default:
      return ApplicationStatus.unknown;
  }
}
