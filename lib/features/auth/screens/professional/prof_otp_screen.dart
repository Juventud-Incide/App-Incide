import 'package:app_incide/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

class ProfOtpScreen extends StatefulWidget {
  const ProfOtpScreen({super.key});

  @override
  State<ProfOtpScreen> createState() => _ProfOtpScreenState();
}

class _ProfOtpScreenState extends State<ProfOtpScreen> {
  // Controladores y Nodos de Enfoque para las 4 cajitas
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

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

  void _verifyCode() {
    // Juntamos el texto de las 4 cajitas
    String otpCode = _controllers.map((c) => c.text).join();

    if (otpCode.length == 4) {
      context.pushNamed('prof_experience');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa los 4 dígitos'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color textDark = AppColors.textDark;
    const Color textGray = AppColors.textGray;
    const Color primaryBlue = AppColors.primaryBlue;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. TÍTULOS ---
              const Text(
                'VERIFICA TU NÚMERO',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 15, color: textGray, height: 1.4),
                  children: [
                    TextSpan(
                      text:
                          'Ingresa el código de 4 dígitos que enviamos por SMS al ',
                    ),
                    TextSpan(
                      text: 'terminación **45',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // --- 2. CAJAS DE OTP ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 65,
                    height: 75,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: primaryBlue,
                      ),
                      // Filtro para aceptar solo números
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: "",
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
                            color: primaryBlue,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        // Lógica de salto automático al siguiente campo
                        if (value.isNotEmpty) {
                          if (index < 3) {
                            _focusNodes[index + 1].requestFocus();
                          } else {
                            // Si es la última caja, ocultamos el teclado
                            _focusNodes[index].unfocus();
                          }
                        } else if (value.isEmpty && index > 0) {
                          // Si borra un número, regresa a la caja anterior
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),

              // --- 3. REENVIAR CÓDIGO ---
              Center(
                child: Column(
                  children: [
                    const Text(
                      '¿No recibiste el código?',
                      style: TextStyle(color: textGray, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        // TODO: Lógica para reiniciar temporizador y reenviar SMS
                      },
                      child: const Text(
                        'Reenviar código (00:45)',
                        style: TextStyle(
                          color: primaryBlue,
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
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Verificar Código',
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
