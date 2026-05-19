import 'package:app_incide/core/constants/app_strings.dart';
import 'package:app_incide/core/theme/app_colors.dart';
import 'package:app_incide/features/auth/providers/auth_provider.dart';
import 'package:app_incide/features/auth/providers/registration_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'dart:async';

/// Pantalla de Verificación SMS (One-Time Password) para el Proveedor.
///
/// **Flujo de Registro (Wizard):**
/// Recibe el `formData` (Nombre, Email, Password, Teléfono) de la pantalla anterior.
/// Si el OTP es correcto, hereda este diccionario a la siguiente vista (`prof_experience`)
/// para continuar construyendo el Payload final.
///
/// **UX de Campos Divididos:**
/// Utiliza una lista de `FocusNode` para implementar el "Auto-Avance". Cuando el
/// usuario escribe un dígito, el foco salta automáticamente a la siguiente caja,
/// mejorando radicalmente la experiencia de usuario.
class ProfOtpScreen extends ConsumerStatefulWidget {
  const ProfOtpScreen({super.key});

  @override
  ConsumerState<ProfOtpScreen> createState() => _ProfOtpScreenState();
}

class _ProfOtpScreenState extends ConsumerState<ProfOtpScreen> {
  // Controladores y Nodos de Enfoque para las 6 cajas de texto individuales
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  bool _isLoading = false;

  /// Temporizador Anti-Spam para prevenir reenvíos masivos de SMS.
  Timer? _timer;
  int _secondsRemaining = 59;
  bool _canResend = false;
  int _codeLength = 6; // Número de dígitos del OTP

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_codeLength, (_) => TextEditingController());
    _focusNodes = List.generate(_codeLength, (_) => FocusNode());
    _startTimer();
  }

  @override
  void dispose() {
    // SEGURIDAD P0: Limpieza profunda de memoria RAM.
    // Previene que los dígitos del OTP o los manejadores de foco queden huérfanos,
    // causando Memory Leaks o vulnerabilidades si la app es enviada a segundo plano.
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  /// Inicia la cuenta regresiva que bloquea el botón de "Reenviar SMS".
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

  /// Solicita al servidor un nuevo código y reinicia el bloqueo temporal.
  void _resendOTP() {
    // TODO: (BACKEND) - Invocar authService.resendSms(widget.formData['phone'])
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nuevo código SMS enviado'),
        backgroundColor: Colors.green,
      ),
    );
    _startTimer();
    _focusNodes[0].requestFocus(); // Devuelve el cursor a la primera caja
  }

  /// Formatea los segundos restantes (ej. "00:09").
  String get timerText => '00:${_secondsRemaining.toString().padLeft(2, '0')}';

  /// Función de ofuscación para no mostrar el número completo en pantalla.
  /// Ej: Si el número es 6621234567, retorna "**4567".
  String _getMaskedPhone() {
    final userPhone = ref.read(registrationProvider).phoneNumber;

    if (userPhone.length >= 4) {
      return '**${userPhone.substring(userPhone.length - 4)}';
    }
    return '**00';
  }

  /// Concatena los 6 dígitos, valida y verifica contra el servidor.
  Future<void> _verifyCode() async {
    FocusScope.of(context).unfocus();

    // Une el texto de todos los controladores en un solo String
    String otpCode = _controllers.map((c) => c.text).join();

    if (otpCode.length < _codeLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.otpIncomplete.replaceAll('X', '$_codeLength'),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Extraemos el celular del estado global
      final phoneNumber = ref.read(registrationProvider).phoneNumber;

      // 2. Disparamos la petición al repositorio (que usará el Mock por ahora)
      final isValid = await ref
          .read(authRepositoryProvider)
          .verifyOtp(phoneNumber, otpCode);

      // 3. Si es exitoso, navegamos al Paso 3 (Experiencia Profesional)
      if (isValid) {
        for (var controller in _controllers) {
          controller.clear();
        }

        if (mounted) {
          context.pushNamed('prof_experience');
        }
      }
    } catch (e) {
      // ERROR: Si el Mock (o el futuro backend) rechaza el código o falla la red
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
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
                    TextSpan(
                      text: AppStrings.otpSubtitle1.replaceAll(
                        'X',
                        '$_codeLength',
                      ),
                    ),
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

              // --- 3. CAJAS DE OTP ---
              Row(
                children: [
                  for (int i = 0; i < _codeLength; i++) ...[
                    Expanded(
                      child: AspectRatio(
                        aspectRatio:
                            1, // Fuerza a que la caja sea un cuadrado perfecto
                        child: TextField(
                          controller: _controllers[i],
                          focusNode: _focusNodes[i],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          maxLength: 1, // Solo admite un dígito por caja
                          obscureText: true, // Oculta el dígito por seguridad
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            counterText: "", // Esconde el indicador "0/1"
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
                            // Lógica de "Auto-Avance" y "Auto-Retroceso"
                            if (value.isNotEmpty) {
                              if (i < _codeLength - 1) {
                                _focusNodes[i + 1]
                                    .requestFocus(); // Salta al siguiente
                              } else {
                                _focusNodes[i]
                                    .unfocus(); // Oculta teclado si es el último
                              }
                            } else {
                              if (i > 0) {
                                _focusNodes[i - 1]
                                    .requestFocus(); // Regresa si borró
                              }
                            }
                          },
                        ),
                      ),
                    ),
                    if (i < _codeLength - 1) const SizedBox(width: 16),
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
                    _canResend
                        ? TextButton(
                            onPressed: _resendOTP,
                            child: const Text(
                              AppStrings.otpResendBtn,
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          )
                        : Text(
                            '${AppStrings.otpResendBtn}($timerText)',
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
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
