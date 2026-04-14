import 'dart:async';
import 'package:app_incide/core/constants/app_strings.dart';
import 'package:app_incide/core/theme/app_colors.dart';
import 'package:app_incide/features/shared/widgets/custom_logout_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Pantalla de confirmación de envío de enlace de recuperación.
///
/// **Recepción de Datos:**
/// Recibe el `email` proporcionado en la pantalla anterior para mostrarlo en el texto,
/// dando certeza al usuario de a dónde se envió la información.
///
/// **Mecanismo Anti-Spam (Rate Limiting en UI):**
/// Implementa un [Timer.periodic] de 60 segundos. Durante este tiempo,
/// el botón de "Reenviar" permanece bloqueado y muestra una cuenta regresiva.
/// Esto previene que el usuario sature el servidor o agote la cuota de correos
/// de Firebase Auth pulsando repetidamente el botón.
class ProfForgotPasswordSentScreen extends StatefulWidget {
  /// El correo electrónico al que se acaba de enviar el enlace.
  final String email;

  const ProfForgotPasswordSentScreen({super.key, required this.email});

  @override
  State<ProfForgotPasswordSentScreen> createState() =>
      _ProfForgotPasswordSentScreenState();
}

class _ProfForgotPasswordSentScreenState
    extends State<ProfForgotPasswordSentScreen> {
  Timer? _timer;
  int _secondsRemaining = 59;

  /// Define si el temporizador ha terminado y se habilita el enlace de reenvío.
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    // LIMPIEZA: Los Timers huérfanos causan Memory Leaks y errores si intentan hacer setState en una pantalla destruida.
    _timer?.cancel();
    super.dispose();
  }

  /// Inicia o reinicia la cuenta regresiva de bloqueo.
  void _startTimer() {
    setState(() {
      _secondsRemaining = 59;
      _canResend = false;
    });

    _timer?.cancel(); // Limpia cualquier timer previo por seguridad
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Prevención: Si el usuario sale de la pantalla antes de que el timer acabe.
      if (!mounted) return;

      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _canResend = true;
          timer.cancel(); // Detiene la ejecución en bucle
        }
      });
    });
  }

  /// Procesa el reenvío del correo y reinicia el bloqueo temporal.
  void _resendEmail() {
    // TODO: (BACKEND) - Llamada real: await FirebaseAuth.instance.sendPasswordResetEmail(email: widget.email)

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.newLinkSent),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    _startTimer(); // Reiniciamos el reloj para imponer el "Cooldown" de nuevo
  }

  /// Getter auxiliar para formatear los segundos de manera elegante (ej. "00:09").
  String get timerText {
    return '00:${_secondsRemaining.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // --- 1. ÍCONO DE SOBRE ---
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: .06),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mail_outline_rounded,
                  color: AppColors.primaryBlue,
                  size: 38,
                ),
              ),
              const SizedBox(height: 30),

              // --- 2. TÍTULOS Y MENSAJES ---
              const Text(
                AppStrings.linkSentTitle,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textGray,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: '${AppStrings.linkSentSubtitle1}\n'),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              const Text(
                AppStrings.linkSentSubtitle2,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textGray,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // --- 3. BOTÓN VOLVER AL INICIO ---
              CustomLogoutButton(
                text: AppStrings.backToHomeBtn,
                variant: LogoutButtonVariant.outlined,
              ),
              const SizedBox(height: 30),

              // --- 4. SECCIÓN DE REENVÍO (Manejo de Estado Dinámico) ---
              Text(
                AppStrings.didNotReceiveEmail,
                style: const TextStyle(color: AppColors.textGray, fontSize: 14),
              ),
              const SizedBox(height: 8),

              _canResend
                  ? InkWell(
                      onTap: _resendEmail,
                      borderRadius: BorderRadius.circular(4),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 8.0,
                        ),
                        child: Text(
                          AppStrings.resendNow,
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    )
                  : Text(
                      '${AppStrings.resendIn} $timerText',
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
