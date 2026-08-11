import 'dart:io';
import 'package:app_incide/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:app_incide/core/theme/app_colors.dart';

class AttachmentPreviewScreen extends StatefulWidget {
  final String filePath;
  final bool isImage;

  const AttachmentPreviewScreen({
    super.key,
    required this.filePath,
    required this.isImage,
  });

  @override
  State<AttachmentPreviewScreen> createState() =>
      _AttachmentPreviewScreenState();
}

class _AttachmentPreviewScreenState extends State<AttachmentPreviewScreen> {
  final TextEditingController _captionController = TextEditingController();

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Extraemos solo el nombre del archivo de toda la ruta para mostrarlo
    final fileName = widget.filePath.split('/').last;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          AppStrings.attachmentPreviewTitle,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ÁREA DE VISTA PREVIA
            Expanded(
              child: Center(
                child: widget.isImage
                    ? Image.file(File(widget.filePath), fit: BoxFit.contain)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.insert_drive_file,
                            color: Colors.white,
                            size: 80,
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Text(
                              fileName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            // ÁREA DE TEXTO Y ENVÍO
            Container(
              color: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _captionController,
                      style: const TextStyle(color: Colors.white),
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 3,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: AppStrings.attachmentCaptionHint,
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.1),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      // Al presionar enviar, regresamos a la pantalla anterior
                      // pasando un mapa con la ruta y el texto (si hay)
                      Navigator.of(context).pop({
                        'filePath': widget.filePath,
                        'caption': _captionController.text.trim().isEmpty
                            ? null
                            : _captionController.text.trim(),
                      });
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
