import 'package:flutter/material.dart';
import 'package:app_incide/core/theme/app_colors.dart';

class ClientHomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;
  final String userName;
  final bool isLoading;
  final int unreadNotifications;
  final VoidCallback onNotificationPressed;

  const ClientHomeAppBar({
    super.key,
    required this.currentIndex,
    required this.userName,
    this.isLoading = false,
    this.unreadNotifications = 0,
    required this.onNotificationPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(85);

  Widget _buildAppBarTitle() {
    if (currentIndex == 0) {
      return Row(
        children: [
          // Logo del sistema con diseño estilizado
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Image.asset('assets/images/Isotipo_Incide.png', height: 28),
          ),
          const SizedBox(width: 16),
          // Saludo y nombre de usuario con mejor jerarquía
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hola, Bienvenido',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withOpacity(0.7),
                  letterSpacing: 0.5,
                ),
              ),
              isLoading
                  ? const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: SizedBox(
                        height: 14,
                        width: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Text(
                      userName.isNotEmpty ? userName : 'Usuario',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
            ],
          ),
        ],
      );
    }

    String titleText = '';
    if (currentIndex == 1) titleText = 'Mis Cotizaciones';
    if (currentIndex == 2) titleText = 'Mis Pagos';
    if (currentIndex == 3) titleText = 'Mi Perfil';

    return Text(
      titleText,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      shape: currentIndex == 3
          ? null // Sin curva en la pestaña de Perfil
          : const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
      backgroundColor: AppColors.primaryBlue,
      elevation: 0,
      toolbarHeight: 85,
      titleSpacing: 24,
      title: _buildAppBarTitle(),
      actions: [
        // Botón Notificaciones con diseño Premium mejorado
        Padding(
          padding: const EdgeInsets.only(right: 12.0),
          child: Center(
            child: SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: onNotificationPressed,
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  if (unreadNotifications > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryBlue,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '$unreadNotifications',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
