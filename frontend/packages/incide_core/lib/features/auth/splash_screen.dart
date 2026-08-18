import 'package:incide_core/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
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

    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Esperamos un poco para que se vea la animación
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // --- INICIALIZACIÓN DE SESIÓN (Lógica Riverpod) ---
    // Le pedimos al controlador que lea el storage local (SecureStorage).
    // Al actualizarse el estado de authControllerProvider, el RouterNotifier 
    // reaccionará automáticamente y nos llevará a donde corresponda.
    await ref.read(authControllerProvider.notifier).initialize();
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
