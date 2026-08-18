import 'package:incide_core/core/utils/app_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:incide_core/core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../widgets/custom_input_field.dart';
import '../../providers/auth_provider.dart';

/// Pantalla de Inicio de Sesión para el rol de Proveedor.
///
/// **Arquitectura Reactiva (Riverpod):**
/// Esta pantalla es un `ConsumerStatefulWidget` que se comunica con el
/// [AuthController]. Observa la propiedad `isLoading` del estado global para
/// alternar visualmente entre el botón de "Iniciar Sesión" y un indicador de carga.
///
/// **Enrutamiento Dinámico:**
/// Dependiendo del estado de la cuenta devuelto por el backend (aceptado, pendiente
/// de revisión, o rechazado), el usuario es redirigido dinámicamente a la
/// pantalla correspondiente dentro de su flujo de acceso o sala de espera.
class ProfLoginScreen extends ConsumerStatefulWidget {
  const ProfLoginScreen({super.key});

  @override
  ConsumerState<ProfLoginScreen> createState() => _ProfLoginScreenState();
}

class _ProfLoginScreenState extends ConsumerState<ProfLoginScreen> {
  /// Llave maestra para validar que el correo y contraseña no estén vacíos
  /// ni rompan el formato esperado antes de enviar peticiones a la red.
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto para extraer las credenciales
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  /// Controla la visibilidad (ofuscación) del campo de contraseña.
  bool _isPasswordVisible = false;
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    // LIMPIEZA: Evitamos fugas de memoria (Memory Leaks) y aseguramos
    // que datos sensibles como la contraseña se borren de la RAM al salir de la vista.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Despacha las credenciales al Provider e intercepta la respuesta.
  Future<void> _submitForm() async {
    // Oculta el teclado nativo para despejar la pantalla
    FocusScope.of(context).unfocus();

    final isValidForm = _formKey.currentState!.validate();

    if (!isValidForm) {
      setState(() => _autoValidateMode = AutovalidateMode.onUserInteraction);
      return;
    } else {
      try {
        // Dispara la mutación del estado en Riverpod (Activa el loader y llama al API)
        await ref
            .read(authControllerProvider.notifier)
            .login(
              _emailController.text.trim(),
              _passwordController.text,
              //'proveedor',//borre role para que lo decida el backend
            );
      } catch (e) {
        if (!mounted) return;
        // Captura excepciones (ej. "Contraseña incorrecta" o "Usuario no encontrado")
        // y las muestra amigablemente a través del SnackBar del sistema.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observador Reactivo: Desata una reconstrucción rápida del botón
    // cada vez que el AuthProvider entra en modo de carga (API Request).
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Form(
            key: _formKey,
            autovalidateMode: _autoValidateMode,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- HEADER ---
                Center(
                  child: Image.asset(
                    'assets/images/Isotipo_Incide.png',
                    width: 60,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  AppStrings.loginTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF1E3A8A),
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  AppStrings.loginSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 16),
                ),

                const SizedBox(height: 48),

                // --- FORMULARIO ---
                CustomInputField(
                  label: AppStrings.emailLoginLabel,
                  hintText: AppStrings.emailLoginHint,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.none,
                  inputFormatters: AppFormatters.noSpaces,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppStrings.emailLoginEmpty;
                    }
                    // Expresión regular estándar del W3C para correos electrónicos
                    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                    if (!emailRegex.hasMatch(value)) {
                      return AppStrings.emailLoginError;
                    }
                    return null; // Null confirma que el campo es válido
                  },
                ),

                const SizedBox(height: 24),

                CustomInputField(
                  label: AppStrings.passwordLoginLabel,
                  hintText: AppStrings.passwordLoginHint,
                  isPassword: true,
                  isPasswordVisible: _isPasswordVisible,
                  controller: _passwordController,
                  onToggleVisibility: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  inputFormatters: AppFormatters.noSpaces,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.passwordLoginEmpty;
                    }
                    if (value.length < 8) {
                      return AppStrings.passwordLoginError;
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // --- ENLACE: OLVIDASTE CONTRASEÑA ---
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      context.push('/prof-forgot-password');
                    },
                    child: const Text(
                      AppStrings.forgotPassword,
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // --- BOTÓN PRINCIPAL (REACTIVO A CARGA) ---
                ElevatedButton(
                  // Si isLoading es true, anulamos el onPressed (se vuelve null)
                  // lo que previene que el usuario dispare múltiples peticiones de red simultáneas.
                  onPressed: isLoading ? null : () => _submitForm(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          AppStrings.loginBtn,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                const SizedBox(height: 32),

                // --- DIVISOR "O continúa con" ---
                Row(
                  children: [
                    const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        AppStrings.continueWith,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                  ],
                ),

                const SizedBox(height: 32),

                // --- BOTÓN DE GOOGLE ---
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: (BACKEND) - Integrar el paquete google_sign_in
                  },
                  icon: Image.asset('assets/images/logo_google.png', width: 32),
                  label: const Text(
                    AppStrings.googleLogin,
                    style: TextStyle(
                      color: Color(0xFF4B5563),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // --- FOOTER REDIRECCIÓN A REGISTRO ---
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4.0,
                  children: [
                    const Text(
                      AppStrings.notRegistered,
                      style: TextStyle(color: Color(0xFF4B5563)),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Navegamos empujando (push) para permitir volver atrás
                        context.push('/prof-register');
                      },
                      child: const Text(
                        AppStrings.registerNow,
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
