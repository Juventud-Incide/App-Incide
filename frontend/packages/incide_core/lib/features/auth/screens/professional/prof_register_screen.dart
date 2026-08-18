import 'package:incide_core/core/theme/app_colors.dart';
import 'package:incide_core/core/utils/app_formatters.dart';
import 'package:incide_core/features/auth/providers/registration_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_input_field.dart';
import 'package:incide_core/core/constants/app_strings.dart';

/// Primer paso del Asistente (Wizard) de Registro para Proveedores.
///
/// **Arquitectura de Recolección de Datos:**
/// Esta pantalla actúa como el recolector inicial. Recopila la Información
/// Personal, de Cuenta y Legal, y la guarda centralizada en la memoria global
/// mediante `registrationProvider`. Esto permite mantener los datos seguros en
/// RAM y navegar a las siguientes pantallas sin saturar las rutas del sistema,
/// logrando un registro atómico (todo o nada) al final del flujo.
class ProfRegisterScreen extends ConsumerStatefulWidget {
  const ProfRegisterScreen({super.key});

  @override
  ConsumerState<ProfRegisterScreen> createState() => _ProfRegisterScreenState();
}

class _ProfRegisterScreenState extends ConsumerState<ProfRegisterScreen> {
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

  bool _isLoading = false;

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
  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();

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
      try {
        final cleanPhone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
        // Guardamos en la memoria global de Riverpod
        ref
            .read(registrationProvider.notifier)
            .saveStepOne(
              firstName: _nameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
              phoneNumber: cleanPhone,
              curp: _curpController.text.trim().toUpperCase(),
              rfc: _rfcController.text.trim().toUpperCase(),
            );

        setState(() => _isLoading = true);

        final smsSent = await ref
            .read(registrationProvider.notifier)
            .requestInitialOtp();

        if (!mounted) return;

        // 4. Solo avanzamos si el servidor confirmó el envío
        if (smsSent) {
          context.pushNamed('prof_otp');
        } else {
          // Si falló, mostramos el error (ej. Número inválido)
          final errorMsg = ref.read(registrationProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        // Manejo de errores visuales si algo falla en la lectura
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar datos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
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
                    onPressed: _submitForm,
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
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
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
