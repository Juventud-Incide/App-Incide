import 'package:app_incide/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_incide/core/constants/app_strings.dart';

class ProfDashboardShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ProfDashboardShell({super.key, required this.navigationShell});

  void _onTap(BuildContext context, int index) {
    // goBranch cambia de pestaña sin perder el estado (scroll) de las otras
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          type: BottomNavigationBarType.fixed,
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
