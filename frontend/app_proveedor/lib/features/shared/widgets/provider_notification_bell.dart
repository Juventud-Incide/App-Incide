import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_proveedor/features/provider/profile/providers/provider_profile_provider.dart';

/// Un botón de icono inteligente y reactivo para la bandeja de notificaciones.
///
/// **Propósito Arquitectónico (Localized Rebuilds):**
/// Al extraer este botón a su propio [ConsumerWidget], logramos que escuche
/// los cambios del [providerProfileProvider] de forma independiente.
/// Cuando el estado de `hasUnreadNotifications` cambia, **solo este widget** /// se vuelve a renderizar, salvando valiosos ciclos de procesamiento y
/// evitando que pantallas enteras (como el Home) se redibujen innecesariamente.
class ProviderNotificationBell extends ConsumerWidget {
  const ProviderNotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // -------------------------------------------------------------------------
    // LÓGICA REACTIVA
    // -------------------------------------------------------------------------
    // Escucha activamente el estado global del perfil del usuario.
    final profile = ref.watch(providerProfileProvider);

    return Stack(
      alignment: Alignment.center,
      children: [
        // --- 1. ICONO BASE (Accionable) ---
        IconButton(
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () {
            // TODO: (ROUTING) Navegar a la pantalla de listado de notificaciones push/locales.
            // Opcional: ref.read(providerProfileProvider.notifier).markNotificationsAsRead();
          },
        ),

        // --- 2. INDICADOR DE ALERTAS (Badge dinámico) ---
        // Renderizado condicional: El punto ámbar solo existe en el árbol
        // de widgets si el proveedor tiene alertas no leídas.
        if (profile.hasUnreadNotifications)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.amber, // Color semántico de "Aviso/Alerta"
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
