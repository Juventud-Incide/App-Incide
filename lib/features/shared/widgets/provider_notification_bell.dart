import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_incide/features/provider/profile/providers/provider_profile_provider.dart';

class ProviderNotificationBell extends ConsumerWidget {
  const ProviderNotificationBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(providerProfileProvider);

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: Colors.white,
            size: 28,
          ),
          onPressed: () {
            // TODO: Navegar a pantalla de notificaciones
          },
        ),
        if (profile.hasUnreadNotifications)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.amber,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
