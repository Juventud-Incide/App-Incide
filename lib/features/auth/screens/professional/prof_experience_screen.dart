import 'package:app_incide/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_input_field.dart';

class ProfExperienceScreen extends StatefulWidget {
  const ProfExperienceScreen({super.key});

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
      // Todo está listo para mandar a la base de datos y avanzar a la pantalla de "En Revisión"

      // Por ahora simularemos el envío y avanzaremos a un dialog o la siguiente ruta
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Solicitud enviada con éxito!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      setState(() => _autoValidateMode = AutovalidateMode.onUserInteraction);
    }
  }

  InputDecoration _customDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black12, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color textDark = AppColors.textDark;
    const Color textGray = AppColors.textGray;
    const Color primaryBlue = AppColors.primaryBlue;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
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
                          color: primaryBlue,
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
                    color: textDark,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cuéntanos sobre tu oficio para conectarte con los mejores clientes.',
                  style: TextStyle(fontSize: 15, color: textGray, height: 1.4),
                ),
                const SizedBox(height: 30),

                // --- 3. FORMULARIO PROFESIONAL ---

                // DROPDOWN ESPECIALIDAD
                const Text(
                  'ESPECIALIDAD PRINCIPAL:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: _customDecoration('Seleccione un oficio...'),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: textGray,
                  ),
                  initialValue: _selectedSpecialty,
                  items: _specialties.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
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
                    // Años Exp
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AÑOS EXP.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _yearsController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: _customDecoration('Ej. 5'),
                            validator: (value) => value == null || value.isEmpty
                                ? 'Requerido'
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    // Cédula
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CÉDULA PROFESIONAL:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _cedulaController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: _customDecoration('Número (Opcional)'),
                            // Es opcional, no lleva validator requerido
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // DESCRIPCIÓN MULTILÍNEA
                const Text(
                  'DESCRIPCIÓN DE LOS SERVICIOS:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _customDecoration(
                    'Describe brevemente qué tipo de trabajos realizas, tus garantías, etc...',
                  ).copyWith(alignLabelWithHint: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty)
                      return 'Cuéntanos un poco sobre tu trabajo';
                    if (value.length < 20)
                      return 'Por favor escribe al menos 20 caracteres';
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
                      backgroundColor: primaryBlue,
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
