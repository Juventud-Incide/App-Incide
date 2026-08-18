import 'package:flutter/material.dart';
import 'package:incide_core/core/theme/app_colors.dart';
import 'provider_notification_bell.dart';

/// Encabezado (AppBar) global y reutilizable para el módulo de Proveedores.
///
/// **Propósito Arquitectónico:**
/// Centraliza el diseño visual superior de la aplicación (color corporativo,
/// bordes curvos inferiores y tipografía) para evitar duplicación de código (DRY).
/// Además, integra automáticamente la [ProviderNotificationBell], asegurando que
/// el sistema de notificaciones reactivas esté presente en todas las pantallas.
///
/// Implementa [PreferredSizeWidget] para que Flutter permita insertarlo
/// directamente en la propiedad estricta `appBar` de cualquier `Scaffold`.
class CustomProviderAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  /// Título principal que se mostrará en la cabecera (alineado a la izquierda).
  final String title;

  const CustomProviderAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryBlue,
      elevation: 0, // Eliminamos la sombra por defecto de Material Design
      centerTitle: false,
      // Geometría distintiva de la aplicación (Curva inferior)
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 22,
        ),
      ),

      // Inyección del widget inteligente (conectado a Riverpod de forma aislada)
      actions: const [
        ProviderNotificationBell(),
        SizedBox(width: 8), // Margen visual lateral para la campana
      ],

      // --- Ajuste de Diseño (Respiro visual) ---
      // Agrega un espacio vacío en la parte inferior para empujar la curva
      // hacia abajo, evitando que los títulos o la campana queden asfixiados.
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(16),
        child: SizedBox(height: 16),
      ),
    );
  }

  /// Define la altura total que el `Scaffold` debe reservar en la pantalla para este AppBar.
  ///
  /// **Cálculo:** Es la suma de la altura estándar nativa de Flutter (`kToolbarHeight` = 56px)
  /// más los 16 píxeles extra que agregamos explícitamente en la propiedad `bottom`.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 16);
}
