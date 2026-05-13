import 'package:app_incide/core/theme/app_colors.dart';
import 'package:app_incide/core/utils/app_formatters.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_input_field.dart';
import 'package:app_incide/core/constants/app_strings.dart';

/// Primer paso del Asistente (Wizard) de Registro para Proveedores.
///
/// **Arquitectura de Recolección de Datos:**
/// Esta pantalla actúa como el recolector inicial. En lugar de hacer llamadas
/// parciales a la base de datos, recopila la Información Personal, de Cuenta
/// y Legal, empaquetándola en un [Map] (`formData`). Este mapa es inyectado y
/// transportado a las siguientes pantallas (OTP, Experiencia) a través del
/// enrutador, permitiendo un registro atómico (todo o nada) al final del flujo.
class ProfRegisterScreen extends StatefulWidget {
  const ProfRegisterScreen({super.key});

  @override
  State<ProfRegisterScreen> createState() => _ProfRegisterScreenState();
}

class _ProfRegisterScreenState extends State<ProfRegisterScreen> {
  /// Llave maestra para disparar la validación de todos los campos a la vez.
  final _formKey = GlobalKey<FormState>();

  // Controladores de estado para cada campo de texto
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _curpController = TextEditingController();
  final _rfcController = TextEditingController();

  /// Controla la visibilidad del campo de contraseña.
  bool _isPasswordVisible = false;

  /// Seguro booleano: Previene el avance si no se aceptan las políticas.
  bool _termsAccepted = false;
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    // LIMPIEZA: Evitamos fugas de memoria y destruimos información personal
    // identificable (PII) de la memoria RAM del dispositivo.
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _curpController.dispose();
    _rfcController.dispose();
    super.dispose();
  }

  /// Evalúa el formulario, verifica políticas y orquesta la transición de datos.
  void _submitForm() {
    final isValidForm = _formKey.currentState!.validate();

    if (!isValidForm) {
      // Activa las alertas rojas en vivo si el usuario intentó avanzar con errores
      setState(() => _autoValidateMode = AutovalidateMode.onUserInteraction);
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
      // SOLUCIÓN P0 COMPLETA: Empaquetamos todo el estado del formulario.
      // Al ser un mapa dinámico, nos aseguramos de que no se pierda nada al
      // navegar con GoRouter hacia el validador OTP.
      final formData = {
        'name': _nameController.text,
        'lastName': _lastNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'password': _passwordController.text,
        'curp': _curpController.text,
        'rfc': _rfcController.text,
      };

      // Inyectamos todo el mapa de datos en la ruta hacia el Paso 2 (OTP)
      context.pushNamed('prof_otp', extra: formData);
    }
  }

  /// Constructor auxiliar para mantener la UI limpia al crear los divisores de sección.
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
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryBlue,
                letterSpacing: 1.2,
              ),
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
                  AppStrings.registerTitle,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  AppStrings.registerSubtitle,
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
                  key: const Key('register_name_input'),
                  label: AppStrings.nameLabel,
                  hintText: '',
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: AppFormatters.nameFormatter,
                  validator: (value) => value == null || value.isEmpty
                      ? AppStrings.requiredField
                      : null,
                ),
                const SizedBox(height: 12),
                CustomInputField(
                  key: const Key('register_last_name_input'),
                  label: AppStrings.lastNameLabel,
                  hintText: '',
                  controller: _lastNameController,
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: AppFormatters.nameFormatter,
                  validator: (value) => value == null || value.isEmpty
                      ? AppStrings.requiredField
                      : null,
                ),

                _buildSectionTitle(AppStrings.accountData),
                CustomInputField(
                  key: const Key('register_email_input'),
                  label: AppStrings.emailLabel,
                  hintText: AppStrings.emailHint,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.none,
                  inputFormatters: AppFormatters.noSpaces,
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
                  key: const Key('register_phone_input'),
                  label: AppStrings.phoneLabel,
                  hintText: AppStrings.phoneHint,
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textCapitalization: TextCapitalization.none,
                  inputFormatters: [AppFormatters.phoneMask],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.requiredField;
                    }
                    if (value.length < 10) return AppStrings.phoneInvalid;
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomInputField(
                  key: const Key('register_password_input'),
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
                    if (value.length < 8) return AppStrings.passwordInvalid;
                    return null;
                  },
                  textCapitalization: TextCapitalization.none,
                  inputFormatters: AppFormatters.noSpaces,
                ),

                // SECCIÓN: DATOS LEGALES (Validación Oficial MX)
                _buildSectionTitle(AppStrings.legalData),
                CustomInputField(
                  key: const Key('register_curp_input'),
                  label: AppStrings.curpLabel,
                  hintText: AppStrings.curpHint,
                  controller: _curpController,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: AppFormatters.curpFormatter,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppStrings.requiredField;
                    }
                    if (value.length != 18) return AppStrings.curpInvalid;

                    // Validación oficial de formato CURP mediante Expresión Regular
                    final curpRegex = RegExp(
                      r'^[A-Z]{4}[0-9]{6}[H,M][A-Z]{5}[A-Z0-9][0-9]$',
                    );
                    if (!curpRegex.hasMatch(value.toUpperCase())) {
                      return AppStrings.invalidFormat;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomInputField(
                  key: const Key('register_rfc_input'),
                  label: AppStrings.rfcLabel,
                  hintText: AppStrings.rfcHint,
                  controller: _rfcController,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: AppFormatters.rfcFormatter,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppStrings.requiredField;
                    }
                    if (value.length != 13) {
                      return AppStrings.rfcInvalid;
                    }
                    // Validación oficial de formato RFC Persona Física
                    final rfcRegex = RegExp(r'^[A-ZÑ&]{4}\d{6}[A-Z0-9]{3}$');
                    if (!rfcRegex.hasMatch(value.toUpperCase())) {
                      return AppStrings.invalidFormat;
                    }
                    return null;
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
                        key: const Key('register_terms_checkbox'),
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
                        AppStrings.termsAndConditions,
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
                    key: const Key('register_continue_button'),
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
