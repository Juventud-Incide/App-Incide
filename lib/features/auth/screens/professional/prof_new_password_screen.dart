import 'package:app_incide/core/constants/app_strings.dart';
import 'package:app_incide/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_input_field.dart';

class ProfNewPasswordScreen extends StatefulWidget {
  // Si usáramos Deep Links (URLs), aquí se recibe el token por parámetro
  // final String? token;
  const ProfNewPasswordScreen({super.key});

  @override
  State<ProfNewPasswordScreen> createState() => _ProfNewPasswordScreenState();
}

class _ProfNewPasswordScreenState extends State<ProfNewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      setState(() => _autoValidateMode = AutovalidateMode.onUserInteraction);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Llamada al backend -> authService.updatePassword(token, _passwordController.text)
      await Future.delayed(const Duration(seconds: 2));

      // Limpiamos las contraseñas de la memoria antes de salir
      _passwordController.clear();
      _confirmController.clear();

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            icon: const Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: 50,
            ),
            title: const Text(
              AppStrings.passwordUpdatedTitle,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              AppStrings.passwordUpdatedSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGray),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                  ),
                  onPressed: () {
                    context.pop();
                    context.goNamed('splash');
                  },
                  child: const Text(
                    AppStrings.goToLoginBtn,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
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
                  AppStrings.newPasswordTitle,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  AppStrings.newPasswordSubtitle,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textGray,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 40),

                // --- 3. INPUT NUEVA CONTRASEÑA ---
                CustomInputField(
                  label: AppStrings.newPasswordLabel,
                  hintText: AppStrings.passwordHint,
                  controller: _passwordController,
                  isPassword: true,
                  isPasswordVisible: _isPasswordVisible,
                  onToggleVisibility: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                  textCapitalization: TextCapitalization.none,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.requiredField;
                    }
                    if (value.length < 8) {
                      return AppStrings
                          .passwordInvalid; // Asumiendo que existe en tus strings
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // --- 4. INPUT CONFIRMAR CONTRASEÑA ---
                CustomInputField(
                  label: AppStrings.confirmPasswordLabel,
                  hintText: AppStrings.passwordHint,
                  controller: _confirmController,
                  isPassword: true,
                  isPasswordVisible: _isConfirmVisible,
                  onToggleVisibility: () =>
                      setState(() => _isConfirmVisible = !_isConfirmVisible),
                  textCapitalization: TextCapitalization.none,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.requiredField;
                    }
                    // Validación cruzada
                    if (value != _passwordController.text) {
                      return AppStrings.passwordsDoNotMatch;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 50),

                // --- 5. BOTÓN ACTUALIZAR ---
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updatePassword,
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
                            AppStrings.updatePasswordBtn,
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
