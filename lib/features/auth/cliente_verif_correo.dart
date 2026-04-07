import 'package:app_incide/core/constants/app_strings.dart';
import 'package:app_incide/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

class ClienteVerifCorreoScreen extends StatefulWidget {
  final Map<String, dynamic> formData;

  const ClienteVerifCorreoScreen({super.key, required this.formData});

  @override
  State<ClienteVerifCorreoScreen> createState() =>
      _ClienteVerifCorreoScreenState();
}

class _ClienteVerifCorreoScreenState extends State<ClienteVerifCorreoScreen> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(6, (_) => TextEditingController());
    _focusNodes = List.generate(6, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  /// Muestra solo los primeros 3 caracteres del correo y enmascara el resto
  /// hasta el @, ejemplo: eje***@correo.com
  String _getMaskedEmail() {
    final String email = widget.formData['email'] as String? ?? '';
    final int atIndex = email.indexOf('@');
    if (atIndex > 3) {
      return '${email.substring(0, 3)}***${email.substring(atIndex)}';
    } else if (atIndex > 0) {
      return '${email.substring(0, 1)}***${email.substring(atIndex)}';
    }
    return email;
  }

  Future<void> _verifyCode() async {
    final String otpCode = _controllers.map((c) => c.text).join();

    if (otpCode.length < 6) {
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
      // Simulación de verificación con el backend
      await Future.delayed(const Duration(seconds: 1));
      final bool isValid = otpCode == '123456'; // Código de prueba

      if (isValid) {
        for (var controller in _controllers) {
          controller.clear();
        }
        if (mounted) {
          // Navegar a la pantalla de permiso de ubicación del cliente (Tarea #76)
          context.goNamed('client_location_permission');
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
        for (var controller in _controllers) {
          controller.clear();
        }
        _focusNodes[0].requestFocus();
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

              // --- 2. TÍTULOS ---
              const Text(
                AppStrings.emailOtpTitle,
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
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textGray,
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(text: AppStrings.emailOtpSubtitle1),
                    TextSpan(
                      text: _getMaskedEmail(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // --- 3. CAJAS DE CÓDIGO ---
              Row(
                children: [
                  for (int i = 0; i < 6; i++) ...[
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
                              if (i < 5) {
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
                    if (i < 5) const SizedBox(width: 10),
                  ],
                ],
              ),
              const SizedBox(height: 40),

              // --- 4. REENVIAR CÓDIGO ---
              Center(
                child: Column(
                  children: [
                    const Text(
                      AppStrings.emailOtpNotReceived,
                      style: TextStyle(color: AppColors.textGray, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        // TODO: Lógica para reenviar código al correo
                      },
                      child: const Text(
                        AppStrings.emailOtpResendBtn,
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

              // --- 5. BOTÓN VERIFICAR ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primaryBlue.withOpacity(
                      0.7,
                    ),
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
