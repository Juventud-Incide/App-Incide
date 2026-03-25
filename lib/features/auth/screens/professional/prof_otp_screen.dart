import 'package:app_incide/core/constants/app_strings.dart';
import 'package:app_incide/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

class ProfOtpScreen extends StatefulWidget {
  final Map<String, dynamic> formData;

  const ProfOtpScreen({super.key, required this.formData});

  @override
  State<ProfOtpScreen> createState() => _ProfOtpScreenState();
}

class _ProfOtpScreenState extends State<ProfOtpScreen> {
  // Controladores y Nodos de Enfoque para las 4 cajitas
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(4, (_) => TextEditingController());
    _focusNodes = List.generate(4, (_) => FocusNode());
  }

  @override
  void dispose() {
    // Limpieza profunda de memoria RAM (Security P0)
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String _getMaskedPhone() {
    final String phone = widget.formData['phone'] as String? ?? '';
    if (phone.length >= 4) {
      return '**${phone.substring(phone.length - 4)}'; // Muestra los últimos 4
    }
    return '**00';
  }

  Future<void> _verifyCode() async {
    // Juntamos el texto de las 4 cajitas
    String otpCode = _controllers.map((c) => c.text).join();

    if (otpCode.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.otpIncomplete),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simulación de llamada al backend (authService.verifyOTP)
      await Future.delayed(const Duration(seconds: 1));
      bool isValid = otpCode == '1234'; // Código de prueba

      if (isValid) {
        // Limpiamos los datos sensibles de la RAM inmediatamente antes de navegar
        for (var controller in _controllers) {
          controller.clear();
        }
        if (mounted) {
          context.pushNamed('prof_experience', extra: widget.formData);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.otpError),
              backgroundColor: Colors.red,
            ),
          );
        }
        // Si falla, también limpiamos para evitar intentos de extracción de memoria
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus(); // Regresamos el foco al inicio
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color inactiveStepColor = Color(0xFFE2E8F0);

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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. INDICADOR DE PASOS ---
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: inactiveStepColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // --- 1. TÍTULOS ---
              const Text(
                AppStrings.otpTitle,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textGray,
                    height: 1.4,
                  ),
                  children: [
                    TextSpan(text: AppStrings.otpSubtitle1),
                    TextSpan(
                      text: _getMaskedPhone(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // --- 2. CAJAS DE OTP ---
              Row(
                children: [
                  for (int i = 0; i < 4; i++) ...[
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: TextField(
                          controller: _controllers[i],
                          focusNode: _focusNodes[i],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          maxLength: 1,
                          obscureText: true,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            counterText: "",
                            contentPadding: EdgeInsets.zero,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: AppColors.primaryBlue,
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              if (i < 3) {
                                _focusNodes[i + 1].requestFocus();
                              } else {
                                _focusNodes[i].unfocus();
                              }
                            } else {
                              if (i > 0) {
                                _focusNodes[i - 1].requestFocus();
                              }
                            }
                          },
                        ),
                      ),
                    ),
                    if (i < 3) const SizedBox(width: 16),
                  ],
                ],
              ),
              const SizedBox(height: 40),

              // --- 3. REENVIAR CÓDIGO ---
              Center(
                child: Column(
                  children: [
                    const Text(
                      AppStrings.otpNotReceived,
                      style: TextStyle(color: AppColors.textGray, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        // TODO: Lógica para reiniciar temporizador y reenviar SMS
                      },
                      child: const Text(
                        AppStrings.otpResendBtn,
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),

              // --- 4. BOTÓN VERIFICAR ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          AppStrings.otpVerifyBtn,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
