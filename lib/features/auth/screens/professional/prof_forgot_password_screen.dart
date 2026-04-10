import 'package:app_incide/core/constants/app_strings.dart';
import 'package:app_incide/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_input_field.dart';

/// Pantalla inicial del flujo de Recuperación de Contraseña.
///
/// Permite al usuario ingresar su correo electrónico para solicitar un enlace
/// de restablecimiento.
///
/// **Manejo de Estado y Validación:**
/// Utiliza un [GlobalKey<FormState>] para validar el formato del correo usando
/// una Expresión Regular (RegExp) antes de intentar la petición de red.
/// Controla un estado local `_isLoading` para deshabilitar el botón y mostrar
/// un indicador de progreso, previniendo múltiples envíos simultáneos.
class ProfForgotPasswordScreen extends StatefulWidget {
  const ProfForgotPasswordScreen({super.key});

  @override
  State<ProfForgotPasswordScreen> createState() =>
      _ProfForgotPasswordScreenState();
}

class _ProfForgotPasswordScreenState extends State<ProfForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  /// Bloquea el botón de envío mientras se resuelve la petición asíncrona.
  bool _isLoading = false;

  /// Controla la aparición de mensajes de error. Solo se activa si el usuario
  /// intenta enviar un formulario inválido.
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    // LIMPIEZA: Previene fugas de memoria al destruir el controlador.
    _emailController.dispose();
    super.dispose();
  }

  /// Ejecuta la validación y procesa la solicitud de recuperación.
  Future<void> _submitEmail() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      setState(() => _autoValidateMode = AutovalidateMode.onUserInteraction);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: (BACKEND) - Conectar con Firebase Auth: `await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text)`
      await Future.delayed(const Duration(seconds: 2)); // Simulamos carga

      // ÉXITO: Pasamos el correo como argumento 'extra' al enrutador para personalizar el mensaje en la siguiente pantalla.
      if (mounted) {
        context.pushNamed(
          'prof_forgot_password_sent',
          extra: {'email': _emailController.text},
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            autovalidateMode: _autoValidateMode,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. ÍCONO DE CANDADO ---
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.primaryBlue,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 30),

                // --- 2. TÍTULOS ---
                const Text(
                  AppStrings.forgotPassTitle,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  AppStrings.forgotPassSubtitle,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textGray,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 40),

                // --- 3. INPUT DE CORREO ---
                CustomInputField(
                  label: AppStrings.emailLabel,
                  hintText: AppStrings.emailHint,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.none,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.requiredField;
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
                      return AppStrings.emailInvalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 50),

                // --- 4. BOTÓN DE ENVIAR ---
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitEmail,
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
                            AppStrings.sendLinkBtn,
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
      ),
    );
  }
}
