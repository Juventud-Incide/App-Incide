import 'package:app_incide/core/constants/app_strings.dart';
import 'package:app_incide/core/theme/app_colors.dart';
import 'package:app_incide/core/utils/app_formatters.dart';
import 'package:app_incide/features/provider/chat/providers/chat_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_incide/features/provider/quotes/providers/quotes_provider.dart';
import 'package:app_incide/features/provider/dashboard/models/opportunity_model.dart';
import 'package:flutter/material.dart';

/// Modal deslizante inferior (Bottom Sheet) para enviar una cotización.
///
/// Permite al proveedor ingresar un mensaje descriptivo y un precio estimado.
///
/// **UX Resiliente al Teclado:** Utiliza `MediaQuery.viewInsetsOf(context).bottom`
/// para empujar el contenido hacia arriba dinámicamente cuando el teclado nativo
/// del sistema operativo aparece, evitando que los campos de texto queden ocultos.
///
/// **Contrato de Navegación:**
/// Al presionar "Enviar Propuesta", hace un `pop` devolviendo `true`. La pantalla
/// que invocó este modal debe estar a la escucha de este booleano para ejecutar
/// la animación de éxito (SnackBar) y remover la tarjeta localmente.
class ProposalBottomSheet extends ConsumerStatefulWidget {
  final OpportunityModel opportunity;

  const ProposalBottomSheet({super.key, required this.opportunity});

  @override
  ConsumerState<ProposalBottomSheet> createState() =>
      _ProposalBottomSheetState();
}

class _ProposalBottomSheetState extends ConsumerState<ProposalBottomSheet> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  @override
  void dispose() {
    // LIMPIEZA: Los controladores de texto deben destruirse para evitar Memory Leaks
    _messageController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // viewInsets.bottom es la altura del teclado cuando se abre
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Container(
      // Hacemos que el contenedor crezca si el teclado aparece
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: bottomInset > 0 ? bottomInset + 16 : 32,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Se adapta al contenido interno
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. La "Píldora" superior para arrastrar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Textos de Cabecera
            const Text(
              AppStrings.proposalTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              AppStrings.proposalSubtitle,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textGray,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),

            // 3. Campo de Mensaje (Multilínea)
            Text(
              AppStrings.messageLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: AppStrings.messageHint,
                hintStyle: const TextStyle(
                  color: AppColors.textGray,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryBlue),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 4. Campo de Precio Estimado (Numérico)
            Text(
              AppStrings.priceLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: AppFormatters.priceFormatter,
              decoration: InputDecoration(
                prefixText: '\$ ',
                prefixStyle: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                suffixText: ' MXN',
                suffixStyle: const TextStyle(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                fillColor: AppColors.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primaryBlue),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 5. Botón de Enviar
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  final price = double.tryParse(_priceController.text) ?? 0;
                  final String nuevoChatId = ref
                      .read(quotesProvider.notifier)
                      .addQuoteFromOpportunity(widget.opportunity, price);

                  final customMessage = _messageController.text.trim();

                  final mensajeAEnviar = customMessage.isEmpty
                      ? '¡Hola! Vi tu solicitud para "${widget.opportunity.title}" y estoy interesado en el proyecto.'
                      : customMessage;

                  // 3. Creamos el Chat y mandamos los mensajes automáticamente
                  final chatNotifier = ref.read(chatProvider.notifier);

                  // Mensaje automático del Proveedor
                  chatNotifier.sendTextMessage(nuevoChatId, mensajeAEnviar);

                  // Retornamos 'true' para avisarle a la vista padre que fue exitoso
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  AppStrings.sendProposalBtn,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
