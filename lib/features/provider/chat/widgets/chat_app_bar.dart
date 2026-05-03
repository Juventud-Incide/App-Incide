import 'package:app_incide/core/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isAccepted;
  final bool isCompleted;
  final bool isReadOnly;
  final String realName;
  final String serviceTitle;
  final String? clientAvatarUrl;
  final VoidCallback onMarkAsCompleted;

  const ChatAppBar({
    super.key,
    required this.isAccepted,
    required this.isCompleted,
    required this.isReadOnly,
    required this.realName,
    required this.serviceTitle,
    this.clientAvatarUrl,
    required this.onMarkAsCompleted,
  });

  @override
  Widget build(BuildContext context) {
    // Lógica de privacidad
    final displayName = isAccepted ? realName : 'Cliente (Pendiente)';
    final displayInitials = isAccepted
        ? realName.substring(0, 2).toUpperCase()
        : 'CL';
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
              imageBuilder: (context, imageProvider) =>
                  CircleAvatar(radius: 18, backgroundImage: imageProvider),
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
            onPressed: () {
              // TODO: Integrar url_launcher para llamadas
            },
          ),
        // Menú de opciones (para marcar como completado en el futuro)
        if (!isReadOnly)
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
                        ? 'Cancelar Completado'
                        : 'Marcar como Completado',
                  ),
                ),
                const PopupMenuItem(
                  value: 'report',
                  child: Text('Reportar problema'),
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
