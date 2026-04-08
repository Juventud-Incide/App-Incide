import 'package:app_incide/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _navigateToRoles();
  }

  Future<void> _navigateToRoles() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // --- TODO (Backend) - AUTO-LOGIN DESDE EL INICIO ---
    // 1. Sacamos el token guardado del storage local cifrado.
    // 2. (Opcional pero Recomendado): Podrías hacer un request a tu endpoint como `/api/verify-token` 
    //    para asegurar que el token no ha expirado antes de dejarlo pasar directo.
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final role = prefs.getString('user_role');

    if (token != null && token.isNotEmpty) {
      if (role == 'client') {
        context.go('/home-cliente');
        return;
      }
      // Si se ocupa para profesionales en el futuro
      // else if (role == 'professional') {
      //   context.go('/prof-home');
      //   return;
      // }
    }

    context.go('/roles');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- EL ISOTIPO ANIMADO ---
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                );
              },
              child: Image.asset(
                'assets/images/Isotipo_Incide.png',
                width: 80, // Ajusta este tamaño según veas el emulador
              ),
            ),

            const SizedBox(height: 16),
            // --- EL LOGOTIPO ESTATICO ---
            Image.asset(
              'assets/images/Logo_Incide.png',
              width: 180,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}
