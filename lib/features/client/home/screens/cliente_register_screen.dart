import 'package:app_incide/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/widgets/custom_input_field.dart';
import 'package:app_incide/core/constants/app_strings.dart';

class ClienteRegisterScreen extends StatefulWidget {
  const ClienteRegisterScreen({super.key});

  @override
  State<ClienteRegisterScreen> createState() => _ClienteRegisterScreenState();
}

class _ClienteRegisterScreenState extends State<ClienteRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para cliente
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _termsAccepted = false;
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  // ── Requisitos de contraseña ──────────────────────────────────────────────
  /// Valida que la contraseña tenga al menos 8 caracteres
  bool get _hasMinLength => _passwordController.text.length >= 8;

  /// Valida que la contraseña contenga al menos una letra MAYÚSCULA (A-Z)
  bool get _hasUppercase => RegExp(r'[A-Z]').hasMatch(_passwordController.text);

  /// Valida que la contraseña contenga al menos una letra minúscula (a-z)
  bool get _hasLowercase => RegExp(r'[a-z]').hasMatch(_passwordController.text);

  /// Valida que la contraseña contenga al menos un número (0-9)
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_passwordController.text);

  /// Valida que la contraseña contenga un carácter especial (recomendado)
  bool get _hasSpecial =>
      RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(_passwordController.text);

  /// TRUE solo si se cumplen TODOS los requisitos de seguridad:
  /// - Mínimo 8 caracteres 
  /// - Al menos una mayúscula (A-Z) 
  /// - Al menos una minúscula (a-z) 
  /// - Al menos un número (0-9) 
  /// (Carácter especial es recomendado, no obligatorio)
  bool get _allRequirementsMet =>
      _hasMinLength && _hasUppercase && _hasLowercase && _hasNumber;

  /// TRUE si ambas contraseñas coinciden exactamente y no están vacías
  bool get _passwordsMatch =>
      _passwordController.text == _confirmPasswordController.text &&
      _passwordController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    // Listeners para actualizar estado cuando cambian las contraseñas
    _passwordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    final isValidForm = _formKey.currentState!.validate();

    if (!isValidForm) {
      setState(() => _autoValidateMode = AutovalidateMode.onUserInteraction);
      return;
    } else if (!_passwordsMatch) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.passwordMismatch),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    } else if (!_allRequirementsMet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña no cumple todos los requisitos necesarios'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    } else if (!_termsAccepted) {
      // Mostrar advertencia si no aceptó los términos
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.termsNotAccepted),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // Solución P0 COMPLETA: Empaquetamos todo el estado del formulario
      // para que no se pierda al navegar con GoRouter.
      final formData = {
        'name': _nameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
      };

      // Cliente: ir a verificar correo antes del login
      context.pushNamed('verif-correo-cliente', extra: formData);
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
              fontSize: 13,//Ignorar este coemtnario 
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

  Widget _buildPasswordRequirements() {
    return AnimatedBuilder(
      animation: _passwordController,
      builder: (context, _) {
        if (_passwordController.text.isEmpty) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Requisitos de contraseña:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              _RequirementRow(met: _hasMinLength, text: 'Mínimo 8 caracteres'),
              _RequirementRow(
                met: _hasUppercase,
                text: 'Al menos una mayúscula (A-Z)',
              ),
              _RequirementRow(
                met: _hasLowercase,
                text: 'Al menos una minúscula (a-z)',
              ),
              _RequirementRow(
                met: _hasNumber,
                text: 'Al menos un número (0-9)',
              ),
              _RequirementRow(
                met: _hasSpecial,
                text: 'Carácter especial (!@#\$...) — recomendado',
              ),
            ],
          ),
        );
      },
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

                // --- 2. TÍTULO Y SUBTÍTULO PARA CLIENTE ---
                const Text(
                  'Registro Cliente',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Encuentra profesionistas certificados para tu proyecto en minutos.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textGray,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 20),

                // --- 3. FORMULARIO ---
                _buildSectionTitle(AppStrings.personalData),
                CustomInputField(
                  label: AppStrings.nameLabel,
                  hintText: '',
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) => value == null || value.isEmpty
                      ? AppStrings.requiredField
                      : null,
                ),
                const SizedBox(height: 12),
                CustomInputField(
                  label: AppStrings.lastNameLabel,
                  hintText: '',
                  controller: _lastNameController,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) => value == null || value.isEmpty
                      ? AppStrings.requiredField
                      : null,
                ),

                _buildSectionTitle(AppStrings.accountData),
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
                const SizedBox(height: 12),
                CustomInputField(
                  label: AppStrings.passwordLabel,
                  hintText: AppStrings.passwordHint,
                  controller: _passwordController,
                  isPassword: true,
                  isPasswordVisible: _isPasswordVisible,
                  onToggleVisibility: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.requiredField;
                    }
                    if (!_allRequirementsMet) {
                      return 'La contraseña no cumple todos los requisitos';
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.none,
                ),
                const SizedBox(height: 16),
                
                // --- CHECKLIST DE REQUISITOS DE CONTRASEÑA ---
                _buildPasswordRequirements(),
                
                const SizedBox(height: 12),
                CustomInputField(
                  label: AppStrings.confirmPasswordLabel,
                  hintText: AppStrings.confirmPasswordHint,
                  controller: _confirmPasswordController,
                  isPassword: true,
                  isPasswordVisible: _isPasswordVisible,
                  onToggleVisibility: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.requiredField;
                    }
                    if (value != _passwordController.text) {
                      return AppStrings.passwordMismatch;
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.none,
                ),
                const SizedBox(height: 16),
                // --- 4. TÉRMINOS Y CONDICIONES ---
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
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
                          AppStrings.termsAndConditionsCliente,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textGray,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),

                // --- 4.5. OPCIÓN REGISTRARTE CON GOOGLE ---
                Row(
                  children: [
                    const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        AppStrings.orSignInWith,
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
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implementar login con Google
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Función Google pendiente.'),
                          ),
                        );
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
                  ),
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
                      AppStrings.continueBtn,
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

// ── FILA DE REQUISITO ────────────────────────────────────────────────────────
class _RequirementRow extends StatelessWidget {
  final bool met;
  final String text;

  const _RequirementRow({required this.met, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Icon(
              met ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
              key: ValueKey(met),
              size: 16,
              color: met ? AppColors.successGreen : const Color(0xFFD1D5DB),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: met ? AppColors.successGreen : AppColors.textGray,
                fontWeight: met ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
