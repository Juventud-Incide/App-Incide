import 'package:app_incide/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_upload_card.dart';
import 'package:app_incide/core/constants/app_strings.dart';

/// Pantalla interactiva para la carga inicial de documentos legales obligatorios.
///
/// **Arquitectura y Flujo:**
/// Se presenta después de que el usuario aprueba el registro inicial (`ProfApprovedScreen`).
/// Actúa como un recolector de archivos. Cada documento tiene un estado individual de carga
/// (booleano) que la UI utiliza para marcar visualmente el progreso.
///
/// **Manejo de Estado (Form Validation):**
/// Utiliza un getter reactivo `_allDocsUploaded` para evaluar constantemente si los
/// cinco requisitos (INE, Domicilio, Cédula, Antecedentes, Foto) se han cumplido,
/// alterando el estado visual y funcional del botón de envío final.
class ProfUploadDocsScreen extends StatefulWidget {
  const ProfUploadDocsScreen({super.key});

  @override
  State<ProfUploadDocsScreen> createState() => _ProfUploadDocsScreenState();
}

class _ProfUploadDocsScreenState extends State<ProfUploadDocsScreen> {
  // TODO: (BACKEND) - Sustituir estos booleanos por objetos `File?` o URLs devueltas por Firebase Storage/AWS S3 una vez que el archivo sube al bucket.

  // Estados individuales de carga para cada documento
  bool _isIneUploaded = false;
  bool _isDomicilioUploaded = false;
  bool _isCedulaUploaded = false;
  bool _isAntecedentesUploaded = false;
  bool _isFotoUploaded = false;

  /// Getter reactivo. Retorna `true` únicamente si los 5 booleanos son verdaderos.
  bool get _allDocsUploaded =>
      _isIneUploaded &&
      _isDomicilioUploaded &&
      _isCedulaUploaded &&
      _isAntecedentesUploaded &&
      _isFotoUploaded;

  /// Despliega un menú inferior (Bottom Sheet) ofreciendo las opciones de cámara o galería.
  ///
  /// [docName] Nombre del documento, inyectado en el título del modal.
  /// [onSuccess] Callback ejecutado para actualizar el booleano correspondiente a `true`.
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
                  '${AppStrings.uploadText} $docName',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.primaryBlue,
                  ),
                  title: const Text(AppStrings.takePhoto),
                  onTap: () {
                    // TODO: (BACKEND) - Integrar paquete `image_picker` con ImageSource.camera
                    Navigator.pop(context); // Cierra el modal
                    onSuccess(); // Dispara el cambio de estado simulando éxito
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

  /// Evalúa el envío final. Si faltan documentos, lanza un SnackBar de advertencia.
  void _submitDocuments() {
    // La validación estricta ocurre aquí
    if (_allDocsUploaded) {
      // TODO: (BACKEND) - Llamada para actualizar el estatus del proveedor a "En Revisión"
      context.goNamed('prof_docs_success');
    } else {
      // UX: Retroalimentación inmediata si intenta forzar el envío prematuro
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.missingDocsError),
          backgroundColor: Colors.redAccent,
        ),
      );
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
        title: const Text(
          AppStrings.docsTitle,
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // --- LISTA DE DOCUMENTOS (Scrollable) ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      AppStrings.docsSubtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textGray,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // Componentes Reutilizables de Subida.
                    // Al inyectar el Callback, la tarjeta dispara el BottomSheet
                    // y a su vez, el BottomSheet dispara el setState() local de esta vista.
                    CustomUploadCard(
                      title: AppStrings.docIne,
                      subtitle: AppStrings.docIneSubtitle,
                      icon: Icons.badge_rounded,
                      isUploaded: _isIneUploaded,
                      onTap: () => _showUploadBottomSheet(
                        AppStrings.docIneShort,
                        () => setState(() => _isIneUploaded = true),
                      ),
                    ),
                    CustomUploadCard(
                      title: AppStrings.docDomicilio,
                      subtitle: AppStrings.docDomicilioSubtitle,
                      icon: Icons.receipt_long_rounded,
                      isUploaded: _isDomicilioUploaded,
                      onTap: () => _showUploadBottomSheet(
                        AppStrings.docDomicilioShort,
                        () => setState(() => _isDomicilioUploaded = true),
                      ),
                    ),
                    CustomUploadCard(
                      title: AppStrings.docCedula,
                      subtitle: AppStrings.docCedulaSubtitle,
                      icon: Icons.school_rounded,
                      isUploaded: _isCedulaUploaded,
                      onTap: () => _showUploadBottomSheet(
                        AppStrings.docCedulaShort,
                        () => setState(() => _isCedulaUploaded = true),
                      ),
                    ),
                    CustomUploadCard(
                      title: AppStrings.docAntecedentes,
                      subtitle: AppStrings.docAntecedentesSubtitle,
                      icon: Icons.gavel_rounded,
                      isUploaded: _isAntecedentesUploaded,
                      onTap: () => _showUploadBottomSheet(
                        AppStrings.docAntecedentesShort,
                        () => setState(() => _isAntecedentesUploaded = true),
                      ),
                    ),
                    CustomUploadCard(
                      title: AppStrings.docFoto,
                      subtitle: AppStrings.docFotoSubtitle,
                      icon: Icons.face_rounded,
                      isUploaded: _isFotoUploaded,
                      onTap: () => _showUploadBottomSheet(
                        AppStrings.docFotoShort,
                        () => setState(() => _isFotoUploaded = true),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- BOTÓN INFERIOR (Fijo) ---
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
                  onPressed: _submitDocuments,
                  // Estilizado reactivo: El botón cambia visualmente si faltan documentos
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _allDocsUploaded
                        ? AppColors.primaryBlue
                        : Colors.grey[300],
                    foregroundColor: _allDocsUploaded
                        ? Colors.white
                        : Colors.grey[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    AppStrings.sendDocsBtn,
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
