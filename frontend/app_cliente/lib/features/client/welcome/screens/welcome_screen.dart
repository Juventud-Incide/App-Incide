import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:incide_core/features/auth/providers/auth_provider.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(
      () => ref.read(authControllerProvider.notifier).initialize(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final imageHeight = (constraints.maxHeight * .46).clamp(300.0, 430.0);

            return SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: imageHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/images/construccion.jpg',
                          fit: BoxFit.cover,
                          alignment: Alignment.bottomCenter,
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: .04),
                                Colors.white.withValues(alpha: .12),
                                Colors.white,
                              ],
                              stops: const [0, .62, 1],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 14,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Image.asset(
                              'assets/images/Logo_Incide.png',
                              width: 102,
                              height: 42,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const Positioned(
                          left: 0,
                          right: 0,
                          bottom: 24,
                          child: _CategoryChips(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Column(
                      children: [
                        Text(
                          'Conecta con los\nmejores profesionistas',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: const Color(0xFF092B58),
                            fontWeight: FontWeight.w800,
                            height: 1.08,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Contrata servicios con total confianza',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF24466D),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const _TrustIndicators(),
                        const SizedBox(height: 16),
                        _LoginButton(onPressed: () => context.push('/login-cliente')),
                        const SizedBox(height: 12),
                        Text(
                          '¿No tienes cuenta?',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: const Color(0xFF707070),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 42,
                          child: OutlinedButton(
                            onPressed: () => context.push('/registro-cliente'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF092B58),
                              side: const BorderSide(color: Color(0xFFE0E0E0)),
                              shape: const StadiumBorder(),
                              elevation: 2,
                              shadowColor: Colors.black12,
                              backgroundColor: Colors.white,
                            ),
                            child: const Text(
                              'Regístrate',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Al continuar aceptas nuestros Términos de Uso y Privacidad',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: const Color(0xFF7B7B7B),
                            fontSize: 7,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: const [
        _CategoryChip(icon: Icons.handyman_outlined, label: 'Construcción'),
        _CategoryChip(icon: Icons.plumbing_outlined, label: 'Plomería'),
        _CategoryChip(icon: Icons.assignment_outlined, label: 'Gestiones'),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .94),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFFF28C00)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _TrustIndicators extends StatelessWidget {
  const _TrustIndicators();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _TrustItem(icon: Icons.verified_outlined, label: 'Verificados', color: Color(0xFF25A36F)),
        _TrustItem(icon: Icons.shield_outlined, label: 'Seguros', color: Color(0xFF2185E5)),
        _TrustItem(icon: Icons.star_border_rounded, label: 'Calificados', color: Color(0xFFF28C00)),
      ],
    );
  }
}

class _TrustItem extends StatelessWidget {
  const _TrustItem({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 8, color: Color(0xFF5D5D5D))),
      ],
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF203F96),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: const Row(
          children: [
            Icon(Icons.login_rounded, size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Iniciar Sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  Text(
                    'Busca profesionistas para tus proyectos',
                    style: TextStyle(fontSize: 12, color: Color.fromARGB(255, 191, 191, 191)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}
