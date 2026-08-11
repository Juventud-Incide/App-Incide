import 'package:app_incide/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_incide/core/constants/app_strings.dart';

/// Envoltorio (Shell) principal para la navegación por pestañas del Proveedor.
///
/// Esta clase actúa como el contenedor "padre" de las 4 vistas principales
/// del Dashboard (Inicio, Cotizaciones, Billetera, Perfil).
///
/// Utiliza [StatefulNavigationShell] inyectado por GoRouter para implementar
/// navegación anidada con persistencia de estado. Esto significa que cada pestaña
/// tiene su propio historial de navegación interno y no pierde su posición de
/// scroll u otros estados locales al cambiar entre ellas.
class ProfDashboardShell extends StatelessWidget {
  /// Gestor de estado de las ramas (pestañas) proveído automáticamente por GoRouter.
  final StatefulNavigationShell navigationShell;

  const ProfDashboardShell({super.key, required this.navigationShell});

  /// Maneja la lógica de transición al tocar un elemento de la barra inferior.
  ///
  /// [index] La posición de la pestaña seleccionada (0 a 3).
  void _onTap(BuildContext context, int index) {
    // goBranch cambia de pestaña sin perder el estado (scroll) de las otras
    navigationShell.goBranch(
      index,
      // TRUCO DE UX: Si el usuario toca la pestaña en la que YA ESTÁ,
      // initialLocation se vuelve 'true', lo que provoca que el historial
      // interno de esa pestaña se limpie y lo devuelva a la pantalla raíz.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El 'body' es dinámico. GoRouter inyectará aquí el árbol de widgets
      // de la pestaña que esté activa actualmente.
      body:
          navigationShell, // Aquí se inyectarán las pantallas (Inicio, Cotizaciones, etc.)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => _onTap(context, index),
          type: BottomNavigationBarType
              .fixed, // Evita que los íconos se muevan al seleccionarlos
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: AppColors.textGray,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: AppStrings.shellHome,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_rounded),
              label: AppStrings.shellQuotes,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_rounded),
              label: AppStrings.shellWallet,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: AppStrings.shellProfile,
            ),
          ],
        ),
      ),
    );
  }
}
