import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/widgets/custom_input_field.dart';
import '../../../auth/widgets/forgot_password_step_indicator.dart';

class ResetPasswordScreen extends StatefulWidget {
  /// Token que llega desde la URL del deep link.
  /// Ejemplo de URL: incide://reset-password?token=abc123xyz
  /// El backend debe validar este token antes de permitir el cambio.
  final String token;

  const ResetPasswordScreen({super.key, required this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;
  bool _isLoading = false;
  bool _success = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

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

  /// TRUE solo si se cumplen TODOS los requisitos de seguridad (P0):
  /// - Mínimo 8 caracteres 
  /// - Al menos una mayúscula (A-Z) 
  /// - Al menos una minúscula (a-z) 
  /// - Al menos un número (0-9) 
  /// (Carácter especial es recomedado, no obligatorio)
  bool get _allRequirementsMet =>
      _hasMinLength && _hasUppercase && _hasLowercase && _hasNumber;

  /// TRUE si ambas contraseñas coinciden exactamente y no están vacías
  /// Esto valida que el usuario confirmó correctamente su nueva contraseña
  bool get _passwordsMatch =>
      _passwordController.text == _confirmController.text &&
      _passwordController.text.isNotEmpty;

  /// LÓGICA DEL BOTÓN "Guardar nueva contraseña":
  /// El botón se DESHABILITA (onPressed: null) si CUALQUIERA de estas es false:
  /// 1. _allRequirementsMet = false → Faltan requisitos de seguridad
  /// 2. _passwordsMatch = false → Las contraseñas no coinciden
  /// 3. _isLoading = true → Hay un petición en curso al backend
  /// 
  /// El botón se HABILITA (onPressed: _submitForm) SOLO cuando TODAS son true:
  /// 1. _allRequirementsMet = true (todos los requisitos RegExp cumplidos)
  /// 2. _passwordsMatch = true  (contraseñas coinciden)
  /// 3. !_isLoading = true  (no hay petición en curso)
  bool get _isFormValid =>
      _allRequirementsMet && _passwordsMatch && !_isLoading;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    // ── VALIDACIÓN INICIAL DEL TOKEN (P0) ──────────────────────────────
    _validateTokenAndInitialize();

    // ── Listener para actualizar estado cuando cambian las contraseñas
    _passwordController.addListener(() => setState(() {}));
    _confirmController.addListener(() => setState(() {}));
  }

  /// Valida el token recibido de la URL.
  /// Si es nulo o vacío, redirecciona al login con un mensaje de error.
  void _validateTokenAndInitialize() {
    if (widget.token.isEmpty || widget.token.trim().isEmpty) {
      _showInvalidTokenDialog();
    }
  }

  /// Muestra un diálogo cuando el token es inválido y redirecciona al login.
  void _showInvalidTokenDialog() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Enlace Inválido'),
          content: const Text(
            'El enlace de recuperación de contraseña es inválido o ha expirado. '
            'Por favor, solicita un nuevo enlace desde la pantalla de login.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.goNamed('login-cliente');
              },
              child: const Text('Ir al Login'),
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // TODO (Backend): Llamar al endpoint para restablecer la contraseña.
    // Endpoint sugerido: POST /api/auth/reset-password
    // Body: {
    //   "token": widget.token,        <- Token de la URL (validar en backend)
    //   "password": _passwordController.text,
    // }
    // El backend debe:
    //   1. Verificar que el token sea válido y no haya expirado.
    //   2. Actualizar la contraseña del usuario asociado al token.
    //   3. Invalidar el token para que no pueda reutilizarse.
    // Respuesta esperada: 200 OK en éxito, 400/401 en error.
    await Future.delayed(
      const Duration(milliseconds: 900),
    ); // Simula la llamada

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _success = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: _success ? _buildSuccessView() : _buildFormView(),
            ),
          ),
        ),
      ),
    );
  }

  // ── VISTA DEL FORMULARIO ─────────────────────────────────────────────────
  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── STEP INDICATOR (paso 3 de 3) ──────────────────────────────
          const ForgotPasswordStepIndicator(currentStep: 3),
          const SizedBox(height: 20),

          // ── ÍCONO ──────────────────────────────────────────────────────
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.primaryBlue,
                size: 38,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── TÍTULO ─────────────────────────────────────────────────────
          const Text(
            'Nueva Contraseña',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Crea una contraseña segura para proteger tu cuenta.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textGray,
              height: 1.5,
            ),
          ),

          // ── TOKEN DEBUG (solo dev, remover en producción) ───────────────
          if (widget.token.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 14,
                    color: Color(0xFFD97706),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Token recibido: ${widget.token.length > 20 ? '${widget.token.substring(0, 20)}…' : widget.token}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 28),

          // ── CAMPO NUEVA CONTRASEÑA ─────────────────────────────────────
          _buildSectionTitle('NUEVA CONTRASEÑA'),
          const SizedBox(height: 8),
          CustomInputField(
            label: '',
            hintText: '••••••••',
            controller: _passwordController,
            isPassword: true,
            isPasswordVisible: _isPasswordVisible,
            onToggleVisibility: () =>
                setState(() => _isPasswordVisible = !_isPasswordVisible),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Campo requerido';
              if (!_allRequirementsMet) {
                return 'La contraseña no cumple los requisitos mínimos';
              }
              return null;
            },
          ),

          // ── INDICADOR DE REQUISITOS ────────────────────────────────────
          const SizedBox(height: 12),
          _buildPasswordRequirements(),
          const SizedBox(height: 20),

          // ── CAMPO CONFIRMAR CONTRASEÑA ─────────────────────────────────
          _buildSectionTitle('CONFIRMAR CONTRASEÑA'),
          const SizedBox(height: 8),
          CustomInputField(
            label: '',
            hintText: '••••••••',
            controller: _confirmController,
            isPassword: true,
            isPasswordVisible: _isConfirmVisible,
            onToggleVisibility: () =>
                setState(() => _isConfirmVisible = !_isConfirmVisible),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Campo requerido';
              if (value != _passwordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
          ),
          const SizedBox(height: 40),

          // ── BOTÓN GUARDAR ──────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              ///  LÓGICA DE DESHABILITACIÓN DEL BOTÓN (P0)                  
              /// onPressed: null → BOTÓN DESHABILITADO (gris opaco, no clickeable)
              /// onPressed: _submitForm → BOTÓN HABILITADO (azul, clickeable)
              /// 
              /// La condición es: _isFormValid ? _submitForm : null
              /// 
              /// _isFormValid = true SOLO si:
              /// ───────────────────────────────────
              /// TODOS los requisitos RegExp se cumplen:
              ///    ✓ Mínimo 8 caracteres
              ///    ✓ Al menos una mayúscula (A-Z)
              ///    ✓ Al menos una minúscula (a-z)
              ///    ✓ Al menos un número (0-9)
              /// 
              /// Las contraseñas COINCIDEN EXACTAMENTE:
              ///    ✓ campo "Nueva Contraseña" == campo "Confirmar Contraseña"
              ///    ✓ Ninguna contraseña está vacía
              /// 
              /// NO hay petición en curso:
              ///    ✓ _isLoading = false (el usuario no presionó recientemente)
              /// 
              /// ═══════════════════════════════════════════════════════════════
              /// 
              /// EJEMPLOS DE CUÁNDO ESTÁ DESHABILITADO ❌:
              /// ────────────────────────────────────────
              /// • Usuario abre la pantalla → Campos vacíos = disabled
              /// • Escribe "pass" (4 caracteres) → Falta longitud = disabled
              /// • Escribe "Pass123" (7 caracteres) → Falta 1 carácter = disabled
              /// • Escribe "Pass1234" pero confirma "Pass1235" → No coinciden = disabled
              /// • Usuario presiona botón (petición en curso) → _isLoading=true = disabled
              /// 
              /// EJEMPLO DE CUÁNDO ESTÁ HABILITADO ✅:
              /// ────────────────────────────────────
              /// • Nueva Contraseña: "Pass1234"
              /// • Confirmar: "Pass1234"
              /// • Checklist: TODOS los requisitos completados ✓
              /// • Estado: LISTO PARA GUARDAR 🟢
              onPressed: _isFormValid ? _submitForm : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFC7D2E0), // Gris opaco
                disabledForegroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Guardar nueva contraseña',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── VISTA DE ÉXITO ───────────────────────────────────────────────────────
  Widget _buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const ForgotPasswordStepIndicator(currentStep: 3),
        const SizedBox(height: 60),

        // Ícono de éxito
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          builder: (_, value, child) =>
              Transform.scale(scale: value, child: child),
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.successGreen,
              size: 54,
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          '¡Contraseña actualizada!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Tu contraseña se ha restablecido exitosamente. '
          'Ya puedes iniciar sesión con tu nueva contraseña.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey[500], height: 1.6),
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () => context.goNamed('login-cliente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Ir al inicio de sesión',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // ── REQUISITOS DE CONTRASEÑA ─────────────────────────────────────────────
  Widget _buildPasswordRequirements() {
    return AnimatedBuilder(
      animation: _passwordController,
      builder: (context, _) {
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
                text: 'Carácter especial (!@#\$…) — recomendado',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
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
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: met ? AppColors.successGreen : AppColors.textGray,
              fontWeight: met ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
