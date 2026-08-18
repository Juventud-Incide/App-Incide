import 'package:incide_core/core/constants/app_strings.dart';
import 'package:incide_core/core/theme/app_colors.dart';
import 'package:app_proveedor/features/shared/widgets/cached_avatar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isAccepted;
  final bool isCompleted;
  final bool isReadOnly;
  final String realName;
  final String serviceTitle;
  final String? clientAvatarUrl;
  final String clientPhoneNumber;
  final VoidCallback onMarkAsCompleted;
  final bool isPending;
  final VoidCallback? onSetPrice;

  const ChatAppBar({
    super.key,
    required this.isAccepted,
    required this.isCompleted,
    required this.isReadOnly,
    required this.realName,
    required this.serviceTitle,
    this.clientAvatarUrl,
    required this.clientPhoneNumber,
    required this.onMarkAsCompleted,
    required this.isPending,
    this.onSetPrice,
  });

  @override
  Widget build(BuildContext context) {
    // Lógica de privacidad
    final displayName = isAccepted
        ? realName
        : AppStrings.chatClientNameProtected;
    final displayInitials = isAccepted
        ? realName.substring(0, 2).toUpperCase()
        : AppStrings.chatClientInitialsProtected;
    final avatarColor = isAccepted ? const Color(0xFFC4B5FD) : Colors.grey[400];

    final bool shouldShowImage =
        isAccepted && clientAvatarUrl != null && clientAvatarUrl!.isNotEmpty;

    // Widget reutilizable para las iniciales (Placeholder / Fallback)
    Widget initialsAvatar() => CircleAvatar(
      backgroundColor: avatarColor,
      radius: 18,
      child: Text(
        displayInitials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    return AppBar(
      backgroundColor: AppColors.primaryBlue,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0), // Margen solicitado
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ), // Color blanco
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Row(
        children: [
          if (shouldShowImage)
            CachedNetworkImage(
              imageUrl: clientAvatarUrl!,
              imageBuilder: (context, imageProvider) => CachedAvatar(
                imageUrl: clientAvatarUrl!,
                radius: 18,
                fallbackInitials: displayInitials,
                fallbackColor: Colors.white.withValues(alpha: 0.9),
                textColor: AppColors.primaryBlue,
              ),
              // Mientras carga, o si la URL está rota, mostramos tus iniciales
              placeholder: (context, url) => initialsAvatar(),
              errorWidget: (context, url, error) => initialsAvatar(),
            )
          else
            initialsAvatar(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  serviceTitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Si no está aceptado, no mostramos el botón de llamada
        if (isAccepted && !isReadOnly)
          IconButton(
            icon: const Icon(Icons.phone, color: Colors.white),
            onPressed: () async {
              // Armamos la orden para el sistema operativo
              final Uri callUri = Uri(scheme: 'tel', path: clientPhoneNumber);

              // Verificamos si el dispositivo puede hacer llamadas (un iPad a veces no puede)
              if (await canLaunchUrl(callUri)) {
                await launchUrl(callUri);
              } else {
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No se pudo abrir el marcador telefónico'),
                  ),
                );
              }
            },
          ),
        // Menú de opciones (para marcar como completado en el futuro)
        if (!isReadOnly)
          if (isPending)
            IconButton(
              icon: const Icon(
                Icons.request_quote_outlined,
                color: Colors.white,
              ), // Ícono de cotización/dinero
              tooltip: 'Establecer Precio',
              onPressed: onSetPrice,
            )
          else if (isAccepted || isCompleted)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'complete') onMarkAsCompleted();
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    value: 'complete',
                    child: Text(
                      isCompleted
                          ? AppStrings.chatCancelCompletionBtn
                          : AppStrings.chatConfirmCompletionBtn,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'report',
                    child: Text(AppStrings.chatReportIssueBtn),
                  ),
                ];
              },
            ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
