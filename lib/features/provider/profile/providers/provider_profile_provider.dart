import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/provider_profile_model.dart';

/// Notificador encargado de gestionar el estado y la lógica de negocio
/// del perfil del proveedor.
///
/// Hereda de [Notifier], lo que nos permite mantener un estado persistente
/// ([ProviderProfileModel]) y exponer métodos controlados para modificarlo.
class ProviderProfileNotifier extends Notifier<ProviderProfileModel> {
  /// Inicializa el estado del perfil al momento de crearse el proveedor.
  ///
  /// Es el lugar ideal para realizar la carga inicial de datos.
  /// Actualmente utiliza datos estáticos (Mocks), pero está preparado para
  /// integrar una llamada asíncrona al repositorio del backend.
  @override
  ProviderProfileModel build() {
    // TODO: (BACKEND) Implementar lógica de recuperación de datos desde el Repositorio/API.
    return ProviderProfileModel(
      id: 'P-001',
      name: 'Ángel Apáez',
      initials: 'AA',
      avatarUrl:
          'https://picsum.photos/id/237/200', // Puedes poner tu URL de picsum aquí si quieres
      isCertified: true,
      hasUnreadNotifications: true,
      isRadarActive: true,
    );
  }

  /// Actualiza el estado de disponibilidad del "Radar" para el proveedor.
  ///
  /// Recibe un [bool] indicando el nuevo estado y emite una nueva instancia
  /// del modelo mediante `copyWith`. Esto dispara automáticamente la
  /// reconstrucción de todos los widgets que estén escuchando el estado.
  void toggleRadar(bool isActive) {
    // TODO: (BACKEND) Persistir el cambio mediante una petición HTTP (Patch/Put).
    state = state.copyWith(isRadarActive: isActive);
  }

  /// Método para limpiar o marcar notificaciones como leídas.
  void markNotificationsAsRead() {
    state = state.copyWith(hasUnreadNotifications: false);
  }
}

/// Proveedor global del perfil del profesional.
///
/// Se utiliza mediante `ref.watch(providerProfileProvider)` para obtener los
/// datos del perfil o `ref.read(providerProfileProvider.notifier)` para
/// ejecutar acciones como [ProviderProfileNotifier.toggleRadar].
final providerProfileProvider =
    NotifierProvider<ProviderProfileNotifier, ProviderProfileModel>(() {
      return ProviderProfileNotifier();
    });
