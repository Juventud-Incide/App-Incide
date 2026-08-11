import 'package:app_incide/core/constants/app_strings.dart';
import 'package:app_incide/core/theme/app_colors.dart';
import 'package:app_incide/features/provider/chat/providers/chat_provider.dart';
import 'package:app_incide/features/provider/chat/screens/attachment_preview_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class ChatInputBar extends ConsumerStatefulWidget {
  final String chatId;
  const ChatInputBar({super.key, required this.chatId});

  @override
  ConsumerState<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends ConsumerState<ChatInputBar> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _textController.text;
    if (text.trim().isNotEmpty) {
      // Disparamos la función del provider
      ref.read(chatProvider.notifier).sendTextMessage(widget.chatId, text);

      // Limpiamos la caja de texto
      _textController.clear();
    }
  }

  Future<void> _processAttachment(String filePath, bool isImage) async {
    // Abrimos la pantalla de vista previa y esperamos el resultado
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            AttachmentPreviewScreen(filePath: filePath, isImage: isImage),
      ),
    );

    // Si el usuario presionó enviar, result tendrá los datos. Si canceló (botón atrás), será null.
    if (result != null && result is Map<String, dynamic>) {
      final finalPath = result['filePath'] as String;
      final caption = result['caption'] as String?;

      if (isImage) {
        ref
            .read(chatProvider.notifier)
            .sendImageMessage(widget.chatId, finalPath, caption);
      } else {
        ref
            .read(chatProvider.notifier)
            .sendDocumentMessage(widget.chatId, finalPath, caption);
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (image != null) {
        await _processAttachment(image.path, true);
      }
    } catch (e) {
      debugPrint(AppStrings.chatImageError + e.toString());
    }
  }

  Future<void> _pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        await _processAttachment(result.files.single.path!, false);
      }
    } catch (e) {
      debugPrint(AppStrings.chatDocumentError + e.toString());
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Wrap(
              children: [
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryBlue,
                    child: Icon(
                      Icons.photo_library,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    AppStrings.chatPhotoGallery,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Icon(
                      Icons.insert_drive_file,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    AppStrings.chatDocuments,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickDocument();
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Botón de adjuntar
            IconButton(
              icon: const Icon(Icons.attach_file, color: Colors.grey),
              onPressed: _showAttachmentOptions,
            ),
            // Botón de cámara (Acción rápida)
            IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.grey),
              onPressed: () => _pickImage(ImageSource.camera),
            ),
            // Campo de texto
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: TextField(
                  controller: _textController,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.newline,
                  minLines: 1,
                  maxLines: 4, // Crece un poco si el texto es largo
                  decoration: const InputDecoration(
                    hintText: AppStrings.chatHintText,
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Botón de enviar
            GestureDetector(
              onTap: _handleSend,
              child: Container(
                height: 45,
                width: 45,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
