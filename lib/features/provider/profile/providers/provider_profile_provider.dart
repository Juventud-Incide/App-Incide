import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/provider_profile_model.dart';

// El Notifier que manejará la lógica del perfil
class ProviderProfileNotifier extends Notifier<ProviderProfileModel> {
  @override
  ProviderProfileModel build() {
    // TODO: (BACKEND) Aquí harás la petición a tu base de datos para cargar el perfil real.
    // Por ahora, iniciamos con tus datos mockeados.
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

  /// Alterna el estado del radar y actualiza la UI automáticamente
  void toggleRadar(bool isActive) {
    // TODO: (BACKEND) Aquí enviarías la petición HTTP para actualizar en BD
    state = state.copyWith(isRadarActive: isActive);
  }
}

// El Provider que expondremos a la UI
final providerProfileProvider =
    NotifierProvider<ProviderProfileNotifier, ProviderProfileModel>(() {
      return ProviderProfileNotifier();
    });
