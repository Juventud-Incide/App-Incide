import 'package:app_incide/core/theme/app_colors.dart';
import 'package:app_incide/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_input_field.dart';
import '../../widgets/custom_dropdown_field.dart';
import 'dart:developer' as developer;

/// Paso Final del Asistente (Wizard) de Registro del Proveedor.
///
/// **Manejo de Estado (Multi-Step Form):**
/// Esta pantalla recibe un [Map<String, dynamic>] llamado `formData` inyectado
/// por GoRouter a través del atributo `extra`. Este mapa contiene los datos
/// recopilados en las pantallas anteriores (Nombre, Email, Contraseña, OTP).
///
/// Al validar exitosamente, la pantalla combina el `formData` original con
/// los nuevos datos (Experiencia y Especialidad) para crear el `finalPayload`
/// que se envía al servidor para registrar la cuenta definitivamente.
class ProfExperienceScreen extends StatefulWidget {
  /// Diccionario acumulativo con los datos de registro de las vistas anteriores.
  final Map<String, dynamic> formData;

  const ProfExperienceScreen({super.key, required this.formData});

  @override
  State<ProfExperienceScreen> createState() => _ProfExperienceScreenState();
}

class _ProfExperienceScreenState extends State<ProfExperienceScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de UI
  String? _selectedSpecialty;
  final _yearsController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _descriptionController = TextEditingController();

  /// Controla cuándo se muestran los mensajes de error en rojo. Inicialmente
  /// apagado, se enciende si el usuario presiona "Enviar" con campos inválidos.
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  // TODO: (BACKEND) - Reemplazar este arreglo estático con una petición GET al endpoint `/api/specialties` para cargar las categorías dinámicamente.
  final List<String> _specialties = [
    'Carpintería',
    'Plomería',
    'Electricidad',
    'Albañilería',
    'Arquitectura',
    'Ingeniería Civil',
    'Pintura e Impermeabilización',
  ];

  @override
  void dispose() {
    // LIMPIEZA: Liberamos memoria de los textfields al salir.
    _yearsController.dispose();
    _cedulaController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Ejecuta la validación del formulario y empaqueta el Payload final.
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // 1. Unificamos los datos heredados con los nuevos
      final Map<String, dynamic> finalPayload = {
        ...widget.formData, // Spread operator para volcar el diccionario previo
        'specialty': _selectedSpecialty,
        'yearsOfExperience': int.tryParse(_yearsController.text) ?? 0,
        'cedula': _cedulaController.text,
        'description': _descriptionController.text,
      };

      // TODO: (BACKEND) - Reemplazar el logger con la llamada real asíncrona:
      // await ref.read(authControllerProvider.notifier).registerProfessional(finalPayload);
      developer.log(
        'Payload del registro completado exitosamente',
        name: 'AuthModule',
        error: finalPayload
            .toString(), // Envía el JSON a la consola de forma estructurada
      );

      // 2. Transición al éxito
      context.goNamed('prof_success');
    } else {
      // Si la validación falla, activamos la revisión en tiempo real (rojos vivos)
      setState(() => _autoValidateMode = AutovalidateMode.onUserInteraction);
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Form(
            key: _formKey,
            autovalidateMode: _autoValidateMode,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. INDICADOR DE PASOS ---
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // --- 2. TÍTULOS ---
                const Text(
                  AppStrings.experienceTitle,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  AppStrings.experienceSubtitle,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textGray,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 30),

                // --- 3. FORMULARIO PROFESIONAL ---

                // DROPDOWN ESPECIALIDAD
                CustomDropdownField<String>(
                  label: AppStrings.specialtyLabel,
                  hintText: AppStrings.specialtyHint,
                  value: _selectedSpecialty,
                  items: _specialties
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (newValue) =>
                      setState(() => _selectedSpecialty = newValue),
                  validator: (value) =>
                      value == null ? AppStrings.selectSpecialtyError : null,
                ),
                const SizedBox(height: 20),

                // ROW: AÑOS DE EXPERIENCIA + CÉDULA
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomInputField(
                        label: AppStrings.yearsExperienceLabel,
                        hintText: AppStrings.yearsExperienceHint,
                        controller: _yearsController,
                        keyboardType: TextInputType.number,
                        validator: (value) => value == null || value.isEmpty
                            ? AppStrings.requiredFieldShort
                            : null,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      flex: 4,
                      child: CustomInputField(
                        label: AppStrings.cedulaLabel,
                        hintText: AppStrings.cedulaHint,
                        controller: _cedulaController,
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // DESCRIPCIÓN MULTILÍNEA
                CustomInputField(
                  label: AppStrings.descriptionLabel,
                  hintText: AppStrings.descriptionHint,
                  controller: _descriptionController,
                  maxLines: 5, // <-- AQUÍ USAMOS LA MAGIA DE LA NUEVA VARIABLE
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppStrings.descriptionError;
                    }
                    if (value.length < 20) {
                      return AppStrings.descriptionTooShortError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // --- 4. BOTÓN FINALIZAR ---
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
                      AppStrings.sendBtn,
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
