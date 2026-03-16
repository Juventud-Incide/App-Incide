import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/custom_input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Llave maestra para validar el formulario
  final _formKey = GlobalKey<FormState>();

  // Controladores para extraer el texto que el usuario escribe
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    // Si la validación pasa, ejecutamos la lógica
    if (_formKey.currentState!.validate()) {
      // TODO: Aquí conectaremos el mock del Backend para autenticar al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Validación exitosa. Simulando envío a backend...'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Form(
            key: _formKey,
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
                  'Bienvenido de Nuevo',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF1E3A8A),
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ingresa para ver tus cotizaciones',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 16),
                ),

                const SizedBox(height: 48),

                // --- FORMULARIO ---
                CustomInputField(
                  label: 'CORREO O USUARIO:',
                  hintText: 'ejemplo@correo.com',
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa tu correo';
                    }
                    if (!value.contains('@')) {
                      return 'Ingresa un correo válido';
                    }
                    return null; // Null significa que pasó la validación
                  },
                ),

                const SizedBox(height: 24),

                CustomInputField(
                  label: 'CONTRASEÑA:',
                  hintText: '*****',
                  isPassword: true,
                  isPasswordVisible: _isPasswordVisible,
                  controller: _passwordController,
                  onToggleVisibility: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña es muy corta';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // --- OLVIDASTE CONTRASEÑA ---
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Navegar a recuperación de contraseña
                    },
                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // --- BOTÓN PRINCIPAL VERDE ---
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Iniciar Sesión',
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
                        'O continúa con',
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
                    // TODO: Lógica de Google Sign-In
                  },
                  icon: Image.asset('assets/images/logo_google.png', width: 32),
                  label: const Text(
                    'Google',
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

                // --- FOOTER REGISTRO ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿No tienes cuenta? ',
                      style: TextStyle(color: Color(0xFF4B5563)),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.push('/registro');
                      },
                      child: const Text(
                        'Regístrate Aquí',
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
