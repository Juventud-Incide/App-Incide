import 'package:incide_core/core/theme/app_colors.dart';
import 'package:incide_core/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_approved_card.dart';
import '../../widgets/custom_expandable_card.dart';

/// Pantalla interactiva para la corrección de documentos rechazados.
///
/// Muestra al proveedor una lista de documentos que no pasaron la validación
/// administrativa, junto con la retroalimentación del revisor.
///
/// **Gestión de Estado (Form Validation):**
/// Utiliza variables de estado locales para rastrear qué documentos han sido
/// reemplazados en la sesión actual. El botón principal se activa dinámicamente
/// a través del getter `_canResubmit` solo cuando todos los errores han sido atendidos.
class ProfDocsRevisionScreen extends StatefulWidget {
  const ProfDocsRevisionScreen({super.key});

  @override
  State<ProfDocsRevisionScreen> createState() => _ProfDocsRevisionScreenState();
}

class _ProfDocsRevisionScreenState extends State<ProfDocsRevisionScreen> {
  // TODO: (BACKEND) - Sustituir estos booleanos por un modelo de datos dinámico devuelto por la API que indique exactamente qué documentos fallaron.

  /// Estado: Indica si el usuario ya actualizó la foto del INE.
  bool _ineFixed = false;

  /// Estado: Indica si el usuario ya actualizó la carta de antecedentes.
  bool _antecedentesFixed = false;

  /// Getter reactivo. Valida que todos los documentos requeridos estén marcados como fijos.
  /// Se inyecta en la propiedad `onPressed` del botón inferior para activarlo/desactivarlo.
  bool get _canResubmit => _ineFixed && _antecedentesFixed;

  /// Muestra un modal deslizable para capturar el nuevo documento.
  ///
  /// [docName] Nombre del documento a mostrar en el título del modal.
  /// [onSuccess] Callback ejecutado si el usuario completa la captura exitosamente,
  /// utilizado para actualizar el estado del documento específico a `true`.
  void _showUploadBottomSheet(String docName, VoidCallback onSuccess) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${AppStrings.reupload}$docName',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                // TODO: (BACKEND) - Integrar paquete `image_picker` con ImageSource.camera
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.primaryBlue,
                  ),
                  title: const Text(AppStrings.takeNewPhoto),
                  onTap: () {
                    Navigator.pop(context);
                    onSuccess(); // Dispara el cambio de estado en la vista padre
                  },
                ),

                // TODO: (BACKEND) - Integrar paquete `file_picker` (PDF) o `image_picker` (Galería)
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_rounded,
                    color: AppColors.primaryBlue,
                  ),
                  title: const Text(AppStrings.chooseFromGallery),
                  onTap: () {
                    Navigator.pop(context);
                    onSuccess();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
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
          onPressed: () => context.goNamed('splash'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER ---
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Text(
                            AppStrings.requiredAction,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      AppStrings.reviewSubtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textGray,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // --- DOCUMENTOS CON ERROR ---
                    const Text(
                      AppStrings.correctionFiles,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 10),

                    CustomExpandableCard(
                      title: AppStrings.docIne,
                      subtitle: _ineFixed
                          ? AppStrings.correctedFile
                          : AppStrings.requiredUpdate,
                      feedbackMessage: AppStrings.docIneFeedback,
                      isCompleted: _ineFixed,
                      onActionTapped: (value) => _showUploadBottomSheet(
                        AppStrings.docIneShort,
                        () => setState(() => _ineFixed = value),
                      ),
                    ),

                    CustomExpandableCard(
                      title: AppStrings.docAntecedentes,
                      subtitle: _antecedentesFixed
                          ? AppStrings.correctedFile
                          : AppStrings.requiredUpdate,
                      feedbackMessage: AppStrings.docAntecedentesFeedback,
                      isCompleted: _antecedentesFixed,
                      onActionTapped: (value) => _showUploadBottomSheet(
                        AppStrings.docAntecedentesShort,
                        () => setState(() => _antecedentesFixed = value),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- DOCUMENTOS APROBADOS ---
                    const Text(
                      AppStrings.approvedDocs,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textGray,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const CustomApprovedCard(title: AppStrings.docDomicilio),
                    const CustomApprovedCard(title: AppStrings.docCedula),
                    const CustomApprovedCard(title: AppStrings.docFoto),
                  ],
                ),
              ),
            ),

            // --- BOTÓN INFERIOR ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // Si _canResubmit es false, pasamos null.
                  // Flutter automáticamente desactiva y vuelve gris el botón si onPressed es null.
                  onPressed: _canResubmit
                      ? () {
                          // Lo mandamos a la pantalla de éxito de documentos que ya hicimos
                          context.goNamed('prof_docs_success');
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canResubmit
                        ? AppColors.primaryBlue
                        : Colors.grey[300],
                    foregroundColor: _canResubmit
                        ? Colors.white
                        : Colors.grey[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    AppStrings.resendDocs,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
