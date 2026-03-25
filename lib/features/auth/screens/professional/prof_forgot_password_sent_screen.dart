import 'dart:async';
import 'package:app_incide/core/constants/app_strings.dart';
import 'package:app_incide/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfForgotPasswordSentScreen extends StatefulWidget {
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
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 59;
      _canResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void _resendEmail() {
    // TODO: Llamada al backend para reenviar el correo
    // authService.sendPasswordResetEmail(widget.email);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.newLinkSent),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    _startTimer(); // Reiniciamos el reloj
  }

  // Helper para formatear los segundos como "00:0X"
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
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: () => context.goNamed('splash'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(
                      color: AppColors.primaryBlue,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    AppStrings.backToHomeBtn,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- 4. SECCIÓN DE REENVÍO ---
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
