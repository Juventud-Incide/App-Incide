import 'package:app_incide/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_input_field.dart';

class ProfRegisterScreen extends StatefulWidget {
  const ProfRegisterScreen({super.key});

  @override
  State<ProfRegisterScreen> createState() => _ProfRegisterScreenState();
}

class _ProfRegisterScreenState extends State<ProfRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores exactos de la imagen
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    // Valida que todos los campos cumplan las reglas antes de avanzar
    if (_formKey.currentState!.validate()) {
      // Avanza a la siguiente pantalla (Paso 2 / OTP)
      context.pushNamed('prof_otp');
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color inactiveStepColor = Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. INDICADOR DE PASOS (Step Indicator) ---
                Row(
                  children: [
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
                const SizedBox(height: 20),

                // --- 2. TÍTULO Y SUBTÍTULO ---
                const Text(
                  'CREAR CUENTA',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Únete a la red de profesionistas INCIDE.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textGray,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 20),

                // --- 3. FORMULARIO ---
                CustomInputField(
                  label: 'NOMBRE(S):',
                  hintText: '',
                  controller: _nameController,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),

                CustomInputField(
                  label: 'APELLIDOS:',
                  hintText: '',
                  controller: _lastNameController,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),

                CustomInputField(
                  label: 'CORREO ELECTRÓNICO:',
                  hintText: 'ejemplo@correo.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Requerido';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value))
                      return 'Ingresa un correo válido';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                CustomInputField(
                  label: 'CELULAR (10 DIGITOS):',
                  hintText: '662 000 0000',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Requerido';
                    if (value.length < 10) return 'Inserta un celular válido';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                CustomInputField(
                  label: 'CONTRASEÑA:',
                  hintText: '*****',
                  controller: _passwordController,
                  isPassword: true,
                  isPasswordVisible: _isPasswordVisible,
                  onToggleVisibility: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Requerido';
                    if (value.length < 8) return 'Mínimo 8 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 50),

                // --- 4. BOTÓN DE CONTINUAR ---
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Continuar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
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
    );
  }
}
