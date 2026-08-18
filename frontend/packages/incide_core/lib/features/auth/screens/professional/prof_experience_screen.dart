import 'package:incide_core/core/theme/app_colors.dart';
import 'package:incide_core/core/constants/app_strings.dart';
import 'package:incide_core/core/utils/app_formatters.dart';
import 'package:incide_core/features/auth/providers/categories_provider.dart';
import 'package:incide_core/features/auth/providers/registration_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_input_field.dart';
import '../../widgets/custom_dropdown_field.dart';
import 'dart:developer' as developer;

/// **Manejo de Estado (Multi-Step Form):**
/// Se apoya en la memoria global del `registrationProvider`, la cual contiene
/// la información personal y de seguridad validada en los pasos previos.
///
/// Al completar el formulario exitosamente, la pantalla recopila estos últimos
/// datos (Experiencia y Especialidad) y dispara el método `submitRegistration`
/// del Notifier. Este controlador orquesta la unión de toda la información y
/// la envía al servidor para registrar la cuenta de forma atómica y segura.
class ProfExperienceScreen extends ConsumerStatefulWidget {
  const ProfExperienceScreen({super.key});

  @override
  ConsumerState<ProfExperienceScreen> createState() =>
      _ProfExperienceScreenState();
}

class _ProfExperienceScreenState extends ConsumerState<ProfExperienceScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de UI
  final _yearsController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _descriptionController = TextEditingController();

  int? _selectedCategoryId;
  List<int> _selectedServiceIds = [];
  bool _isLoading = false;

  /// Controla cuándo se muestran los mensajes de error en rojo. Inicialmente
  /// apagado, se enciende si el usuario presiona "Enviar" con campos inválidos.
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    // LIMPIEZA: Liberamos memoria de los textfields al salir.
    _yearsController.dispose();
    _cedulaController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Ejecuta la validación del formulario y empaqueta el Payload final.
  void _submitForm() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      // 1. Validamos que haya elegido al menos un servicio
      if (_selectedCategoryId == null || _selectedServiceIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Por favor, selecciona una categoría y al menos un servicio.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // 2. Encendemos el loader local
      setState(() => _isLoading = true);

      try {
        // 3. Guardamos los catálogos en el estado global
        ref
            .read(registrationProvider.notifier)
            .updateServices(_selectedCategoryId!, _selectedServiceIds);

        // 4. Disparamos la petición final de registro
        final success = await ref
            .read(registrationProvider.notifier)
            .submitRegistration(
              yearsOfExperience: int.tryParse(_yearsController.text) ?? 0,
              professionalLicense: _cedulaController.text,
              description: _descriptionController.text,
            );

        if (success && mounted) {
          developer.log('Registro completado exitosamente', name: 'AuthModule');
          // 5. Transición al éxito (idealmente limpiando historial)
          context.goNamed('prof_success');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      // Si la validación falla, activamos la revisión en tiempo real (rojos vivos)
      setState(() => _autoValidateMode = AutovalidateMode.onUserInteraction);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos los providers de catálogos
    final asyncCategories = ref.watch(categoriesCatalogProvider);
    final asyncServices = ref.watch(servicesCatalogProvider);

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
                asyncCategories.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (err, stack) => Text(
                    'Error al cargar rubros: $err',
                    style: const TextStyle(color: Colors.red),
                  ),
                  data: (categoriesList) {
                    return CustomDropdownField<int>(
                      label: AppStrings.specialtyLabel,
                      hintText: AppStrings.specialtyHint,
                      value: _selectedCategoryId,
                      items: categoriesList.map((cat) {
                        return DropdownMenuItem<int>(
                          value: cat['id'] as int,
                          child: Text(cat['name'] as String),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedCategoryId = newValue;
                          // Limpiamos los servicios si el usuario cambia de categoría
                          _selectedServiceIds.clear();
                        });
                      },
                      validator: (value) => value == null
                          ? AppStrings.selectSpecialtyError
                          : null,
                    );
                  },
                ),
                const SizedBox(height: 20),

                if (_selectedCategoryId != null) ...[
                  const Text(
                    'Servicios que ofreces:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),

                  // Manejamos el estado asíncrono de los servicios
                  asyncServices.when(
                    loading: () => const CircularProgressIndicator(),
                    error: (err, stack) =>
                        Text('Error al cargar servicios: $err'),
                    data: (allServices) {
                      // Filtramos solo los servicios que pertenecen a la categoría seleccionada
                      final filteredServices = allServices
                          .where((s) => s['categoryId'] == _selectedCategoryId)
                          .toList();

                      if (filteredServices.isEmpty) {
                        return const Text(
                          'No hay servicios disponibles para esta categoría.',
                        );
                      }

                      return Wrap(
                        spacing: 8.0,
                        runSpacing: 4.0,
                        children: filteredServices.map((service) {
                          final serviceId = service['id'] as int;
                          final isSelected = _selectedServiceIds.contains(
                            serviceId,
                          );

                          return FilterChip(
                            label: Text(service['name'] as String),
                            selected: isSelected,
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected) {
                                  _selectedServiceIds.add(serviceId);
                                } else {
                                  _selectedServiceIds.remove(serviceId);
                                }
                              });
                            },
                            selectedColor: AppColors.primaryBlue.withValues(
                              alpha: 0.2,
                            ),
                            checkmarkColor: AppColors.primaryBlue,
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],

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
                        inputFormatters: [
                          ...AppFormatters.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
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
                        keyboardType: TextInputType.number,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          ...AppFormatters.digitsOnly,
                          LengthLimitingTextInputFormatter(8),
                        ],
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
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
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
                    onPressed: _isLoading ? null : _submitForm,
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
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
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
