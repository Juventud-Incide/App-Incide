import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';

class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    // --- TODO (Backend) - CIERRE DE SESIÓN ---
    // 1. Si tu backend lo requiere, dispara una solicitud HTTP rápida para invalidar/destruir 
    //    el token real dentro de tu servidor.
    // 2. Borras los datos del almacenamiento nativo para que el usuario vuelva a ser bloqueado.
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_role');
    if (context.mounted) {
      context.go('/roles');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        title: const Text(
          'Panel de Cliente',
          style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => _logout(context),
            tooltip: 'Cerrar Sesión',
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 80,
              color: AppColors.primaryBlue.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            const Text(
              'HOME EN PROCESO',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'El módulo de clientes estará disponible pronto.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
