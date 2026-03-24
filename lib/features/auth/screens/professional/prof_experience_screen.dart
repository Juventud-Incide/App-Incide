import 'package:app_incide/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_input_field.dart';
import '../../widgets/custom_dropdown_field.dart';
import 'dart:developer' as developer;

class ProfExperienceScreen extends StatefulWidget {
  final Map<String, dynamic> formData;

  const ProfExperienceScreen({super.key, required this.formData});

  @override
  State<ProfExperienceScreen> createState() => _ProfExperienceScreenState();
}

class _ProfExperienceScreenState extends State<ProfExperienceScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  String? _selectedSpecialty;
  final _yearsController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _descriptionController = TextEditingController();

  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  // Catálogo de oficios (Ejemplo estático, vendrá de una llamada a API)
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
    _yearsController.dispose();
    _cedulaController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> finalPayload = {
        ...widget.formData,
        'specialty': _selectedSpecialty,
        'yearsOfExperience': int.tryParse(_yearsController.text) ?? 0,
        'cedula': _cedulaController.text,
        'description': _descriptionController.text,
      };

      // TODO: Aquí se realiza await authService.registerProfessional(finalPayload);
      developer.log(
        'Payload del registro completado exitosamente',
        name: 'AuthModule',
        error: finalPayload
            .toString(), // Mandamos los datos aquí para depuración estructurada
      );

      // Todo está listo para mandar a la base de datos y avanzar a la pantalla de "En Revisión"
      context.goNamed('prof_success');
    } else {
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
                  'TU EXPERIENCIA',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cuéntanos sobre tu oficio para conectarte con los mejores clientes.',
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
                  label: 'ESPECIALIDAD PRINCIPAL:',
                  hintText: 'Seleccione un oficio...',
                  value: _selectedSpecialty,
                  items: _specialties
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (newValue) =>
                      setState(() => _selectedSpecialty = newValue),
                  validator: (value) =>
                      value == null ? 'Selecciona una especialidad' : null,
                ),
                const SizedBox(height: 20),

                // ROW: AÑOS DE EXPERIENCIA + CÉDULA
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: CustomInputField(
                        label: 'AÑOS EXP.',
                        hintText: 'Ej. 5',
                        controller: _yearsController,
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value == null || value.isEmpty ? 'Req.' : null,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      flex: 4,
                      child: CustomInputField(
                        label: 'CÉDULA PROFESIONAL:',
                        hintText: 'Número (Opcional)',
                        controller: _cedulaController,
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // DESCRIPCIÓN MULTILÍNEA
                CustomInputField(
                  label: 'DESCRIPCIÓN DE LOS SERVICIOS:',
                  hintText:
                      'Describe brevemente qué tipo de trabajos realizas...',
                  controller: _descriptionController,
                  maxLines: 5, // <-- AQUÍ USAMOS LA MAGIA DE LA NUEVA VARIABLE
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Cuéntanos un poco sobre tu trabajo';
                    }
                    if (value.length < 20) {
                      return 'Por favor escribe al menos 20 caracteres';
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
                      'Enviar Solicitud',
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
