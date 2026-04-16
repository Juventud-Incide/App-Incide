/// Modelo inmutable que representa la identidad y el estado global de un Proveedor.
///
/// Este modelo centraliza toda la información que se muestra constantemente
/// en la interfaz de usuario (como en el [CustomProviderAppBar] y [ProfHomeScreen]).
/// Al ser inmutable, garantiza que los cambios de estado sean predecibles
/// y compatibles con gestores de estado como Riverpod.
class ProviderProfileModel {
  /// Identificador único del proveedor en la base de datos (Ej. UUID o ID autoincremental).
  final String id;

  /// Nombre público o de visualización del proveedor (Ej. "Ángel Apáez").
  final String name;

  /// Iniciales calculadas a partir del nombre (Ej. "AA").
  /// Se utiliza como plan de respaldo (fallback) visual en el avatar.
  final String initials;

  /// URL remota de la fotografía del proveedor.
  /// Es nullable (`String?`) porque un usuario nuevo podría no haber subido una foto aún.
  final String? avatarUrl;

  /// Bandera lógica que determina si el proveedor ha pasado el proceso de verificación.
  /// En la UI, esto renderiza un badge especial (como una palomita dorada) en su avatar.
  final bool isCertified;

  /// Bandera lógica para la campana global.
  /// Si es `true`, renderiza un indicador visual (burbuja ámbar) sobre el icono de notificaciones.
  final bool hasUnreadNotifications;

  /// Controla el estado operativo del proveedor ("Radar").
  /// Si es `true`, el proveedor está visible en el mapa de los clientes y
  /// dispuesto a recibir nuevas solicitudes de cotización.
  final bool isRadarActive;

  /// Constructor principal.
  /// Se exigen los datos mínimos de identidad (`id`, `name`, `initials`),
  /// mientras que los estados lógicos tienen valores predeterminados seguros (`false` o `true`).
  ProviderProfileModel({
    required this.id,
    required this.name,
    required this.initials,
    this.avatarUrl,
    this.isCertified = false,
    this.hasUnreadNotifications = false,
    this.isRadarActive = true,
  });

  /// Crea una nueva instancia de [ProviderProfileModel] copiando los datos actuales
  /// y sobrescribiendo únicamente los valores que se pasen por parámetro.
  ///
  /// **¿Por qué es necesario?**
  /// Riverpod requiere que el estado sea inmutable. Para actualizar el estado
  /// (ej. apagar el Radar), no modificamos la variable actual, sino que emitimos
  /// una nueva copia exacta de este modelo, cambiando solo `isRadarActive`.
  ProviderProfileModel copyWith({
    String? id,
    String? name,
    String? initials,
    String? avatarUrl,
    bool? isCertified,
    bool? hasUnreadNotifications,
    bool? isRadarActive,
  }) {
    return ProviderProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      initials: initials ?? this.initials,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isCertified: isCertified ?? this.isCertified,
      hasUnreadNotifications:
          hasUnreadNotifications ?? this.hasUnreadNotifications,
      isRadarActive: isRadarActive ?? this.isRadarActive,
    );
  }
}
