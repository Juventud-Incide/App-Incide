import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:incide_core/core/theme/app_colors.dart';
import 'package:incide_core/features/auth/widgets/forgot_password_step_indicator.dart';

class ForgotPasswordSentScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const ForgotPasswordSentScreen({super.key, required this.data});

  @override
  State<ForgotPasswordSentScreen> createState() =>
      _ForgotPasswordSentScreenState();
}

class _ForgotPasswordSentScreenState extends State<ForgotPasswordSentScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _scaleAnim;

  String get _email => widget.data['email'] as String? ?? '';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── STEP INDICATOR (paso 2 de 3) ──────────────────────
                  const ForgotPasswordStepIndicator(currentStep: 2),
                  const SizedBox(height: 20),

                  // ── BOTÓN VOLVER ──────────────────────────────────────
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.arrow_back_ios_new,
                          color: AppColors.primaryBlue,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Volver',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // ── ÍCONO ANIMADO ─────────────────────────────────────
                  Center(
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.mark_email_read_rounded,
                          color: AppColors.successGreen,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── TÍTULO ────────────────────────────────────────────
                  const Center(
                    child: Text(
                      '¡Correo enviado!',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── DESCRIPCIÓN ───────────────────────────────────────
                  Center(
                    child: Text(
                      'Hemos enviado un enlace de recuperación a:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── CORREO EN CAJA DESTACADA ──────────────────────────
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFBFDBFE),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _email,
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Center(
                    child: Text(
                      'Revisa tu bandeja de entrada y haz clic en el enlace '
                      'para continuar. Si no lo encuentras, revisa la carpeta '
                      'de spam o correo no deseado.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                        height: 1.6,
                      ),
                    ),
                  ),
                  //BORRAR ESTE BOTON ES SOLO PARA PROBAR LA NUEVA CONTRASEÑA
                  // ── BOTÓN CONTINUAR → nueva contraseña ───────────────
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => context.pushNamed(
                        'reset-password',
                        queryParameters: {'token': 'token-prueba-123'},
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Continuar (boton de prueba)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── BOTÓN REENVIAR ────────────────────────────────────
                  _ResendButton(email: _email),

                  const SizedBox(height: 16),

                  // ── VOLVER AL LOGIN ───────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      onPressed: () => context.goNamed('login-cliente'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.primaryBlue,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Volver al inicio de sesión',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── BOTÓN REENVIAR CON COOLDOWN ──────────────────────────────────────────────
class _ResendButton extends StatefulWidget {
  final String email;
  const _ResendButton({required this.email});

  @override
  State<_ResendButton> createState() => _ResendButtonState();
}

class _ResendButtonState extends State<_ResendButton> {
  bool _isSending = false;
  bool _sent = false;
  int _cooldown = 0;

  Future<void> _resend() async {
    if (_isSending || _cooldown > 0) return;

    setState(() => _isSending = true);

    // TODO (Backend): Volver a llamar POST /api/auth/forgot-password
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    setState(() {
      _isSending = false;
      _sent = true;
      _cooldown = 60;
    });

    _startCooldown();
  }

  void _startCooldown() async {
    while (_cooldown > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _cooldown--);
    }
    if (mounted) setState(() => _sent = false);
  }

  @override
  Widget build(BuildContext context) {
    final canResend = !_isSending && _cooldown == 0;

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: canResend ? _resend : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFE2E8F0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: _isSending
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                _cooldown > 0
                    ? 'Reenviar en ${_cooldown}s'
                    : (_sent ? '¡Correo reenviado!' : 'Reenviar correo'),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: canResend ? Colors.white : AppColors.textGray,
                ),
              ),
      ),
    );
  }
}
