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
  final _curpController = TextEditingController();
  final _rfcController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _termsAccepted = false;
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _curpController.dispose();
    _rfcController.dispose();
    super.dispose();
  }

  void _submitForm() {
    final isValidForm = _formKey.currentState!.validate();

    if (!isValidForm) {
      setState(() => _autoValidateMode = AutovalidateMode.onUserInteraction);
      return;
    } else if (!_termsAccepted) {
      // Mostrar advertencia si no aceptó los términos
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Debes aceptar los Términos y Condiciones para continuar.',
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      context.pushNamed('prof_otp');
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 25.0, bottom: 15.0),
      child: Row(
        children: [
          const Icon(
            Icons.arrow_right_rounded,
            color: AppColors.primaryBlue,
            size: 20,
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryBlue,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
        ],
      ),
    );
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
            autovalidateMode: _autoValidateMode,
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
                _buildSectionTitle('INFORMACIÓN PERSONAL'),
                CustomInputField(
                  label: 'NOMBRE(S):',
                  hintText: '',
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                CustomInputField(
                  label: 'APELLIDOS:',
                  hintText: '',
                  controller: _lastNameController,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Requerido' : null,
                ),

                _buildSectionTitle('DATOS DE CONTACTO'),
                CustomInputField(
                  label: 'CORREO ELECTRÓNICO:',
                  hintText: 'ejemplo@correo.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.none,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Requerido';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
                      return 'Ingresa un correo válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomInputField(
                  label: 'CELULAR (10 DÍGITOS):',
                  hintText: '662 000 0000',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textCapitalization: TextCapitalization.none,
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
                  textCapitalization: TextCapitalization.none,
                ),

                _buildSectionTitle('IDENTIDAD FISCAL Y LEGAL'),
                CustomInputField(
                  label: 'CURP (18 CARACTERES):',
                  hintText: 'AAAA000000AAAAAA00',
                  controller: _curpController,
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Requerido';
                    }
                    if (value.length != 18) return 'Debe tener 18 caracteres';

                    // Validación oficial de formato CURP mediante Expresión Regular
                    final curpRegex = RegExp(
                      r'^[A-Z]{4}[0-9]{6}[H,M][A-Z]{5}[A-Z0-9][0-9]$',
                    );
                    if (!curpRegex.hasMatch(value.toUpperCase())) {
                      return 'Formato inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomInputField(
                  label: 'RFC (13 CARACTERES):',
                  hintText: 'AAAA000000AAA',
                  controller: _rfcController,
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Requerido';
                    }
                    if (value.length != 13) {
                      return 'Personas físicas requieren 13 caracteres';
                    }
                    return null; // Aquí puedes agregar un Regex de RFC más adelante si lo necesitas
                  },
                ),
                const SizedBox(height: 30),

                // --- 4. TÉRMINOS Y CONDICIONES ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _termsAccepted,
                        activeColor: AppColors.primaryBlue,
                        side: const BorderSide(
                          color: Colors.black54,
                          width: 1.5,
                        ),
                        onChanged: (value) =>
                            setState(() => _termsAccepted = value!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Acepto los Términos y Condiciones y el aviso de privacidad. Entiendo que mi cuenta debe ser validada por un administrador.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textGray,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),

                // --- 5. BOTÓN DE CONTINUAR ---
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
