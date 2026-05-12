import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../models/cotizacion_model.dart';
import '../../models/chat_message_model.dart';
import '../../providers/home_providers.dart';
import 'chat_input_bar.dart';
import 'chat_service_completion.dart';

// --- Pantalla Principal ---

class ClienteChatScreen extends ConsumerStatefulWidget {
  final CotizacionModel cotizacion;

  const ClienteChatScreen({super.key, required this.cotizacion});

  @override
  ConsumerState<ClienteChatScreen> createState() => _ClienteChatScreenState();
}

class _ClienteChatScreenState extends ConsumerState<ClienteChatScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToBottomButton = false;
  bool _isTyping = false;
  bool _isCompletingService = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    // Hacer scroll hacia el último mensaje al entrar a la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // Mostrar el botón si estamos a más de 150 píxeles del final
    final shouldShow = (maxScroll - currentScroll) > 150;

    if (shouldShow != _showScrollToBottomButton) {
      setState(() {
        _showScrollToBottomButton = shouldShow;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _sendMessage(String text, Attachment? attachment) {
    // 1. Validar que el chat no esté bloqueado (solo lectura)
    final messages = ref.read(chatMessagesProvider)[widget.cotizacion.id] ?? [];
    if (ChatServiceCompletion.hasClientConfirmed(messages)) return;

    if (text.isNotEmpty || attachment != null) {
      final cotId = widget.cotizacion.id;

      // 1. Cliente envía mensaje
      ref
          .read(chatMessagesProvider.notifier)
          .sendMessage(cotId, text, SenderType.client, attachment: attachment);

      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _scrollToBottom();
      });

      // 2. Simular respuesta automática del proveedor para probar el estado "escribiendo..."
      // ----------------------------------------------------------------------
      // TODO (Backend): ELIMINAR ESTA SIMULACIÓN EN LA VERSIÓN FINAL
      // Esta lógica falsa hace que el proveedor "escriba" y "responda" automáticamente
      // después de 3 segundos para demostrar que la UI reacciona correctamente.
      //
      // Al conectar con Sockets o Firebase:
      // 1. Borra todo este bloque de código (hasta la línea punteada inferior).
      // 2. El estado `_isTyping` se actualizará de forma local
      //    a través de eventos del servidor (ej. socket.on('typing')).
      // ----------------------------------------------------------------------
      setState(() => _isTyping = true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() => _isTyping = false);
          ref
              .read(chatMessagesProvider.notifier)
              .sendMessage(
                cotId,
                'Entendido, lo revisaré y te confirmo.',
                SenderType.provider,
              );
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) _scrollToBottom();
          });
        }
      });
      // ----------------------------------------------------------------------
      // FIN DE LA SIMULACIÓN
      // ----------------------------------------------------------------------
    }
  }

  // ── Acción: confirmar la finalización (con estado de carga) ─────
  Future<void> _onConfirmCompletion() async {
    setState(() {
      _isCompletingService = true;
    });

    // Simular tiempo de petición al servidor (2 segundos)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    ChatServiceCompletion.markAsCompleted(
      ref: ref,
      cotId: widget.cotizacion.id,
      onScrollToBottom: _scrollToBottom,
      isMounted: () => mounted,
    );

    if (mounted) {
      setState(() {
        _isCompletingService = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final allChats = ref.watch(chatMessagesProvider);
    final messages = allChats[widget.cotizacion.id] ?? [];
    final bool isAccepted =
        widget.cotizacion.estado == EstadoCotizacion.aceptada;

    // ── Derivar estado a partir del historial de mensajes ──
    final providerRequested = ChatServiceCompletion.hasProviderRequested(
      messages,
    );
    final clientConfirmed = ChatServiceCompletion.hasClientConfirmed(messages);

    // Si el cliente ya confirmó, el chat es de solo lectura.
    final chatReadOnly = clientConfirmed;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: _buildAppBar(
        context,
        isAccepted,
        providerRequested,
        clientConfirmed,
      ),
      body: Column(
        children: [
          // Área de Mensajes
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  itemCount:
                      messages.length +
                      1, // +1 para el separador de fecha inicial
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _DateSeparator(
                        dateText: (() {
                          final now = DateTime.now();
                          const months = [
                            'ENERO',
                            'FEBRERO',
                            'MARZO',
                            'ABRIL',
                            'MAYO',
                            'JUNIO',
                            'JULIO',
                            'AGOSTO',
                            'SEPTIEMBRE',
                            'OCTUBRE',
                            'NOVIEMBRE',
                            'DICIEMBRE',
                          ];
                          return 'HOY, ${now.day} DE ${months[now.month - 1]}';
                        })(),
                      );
                    }
                    final message = messages[index - 1];

                    // Burbuja de sistema
                    if (message.sender == SenderType.system) {
                      return SystemBubble(message: message);
                    }

                    return _ChatBubble(message: message);
                  },
                ),
                if (_showScrollToBottomButton)
                  Positioned(
                    right: 16,
                    bottom: 8,
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryBlue,
                      elevation: 3,
                      onPressed: _scrollToBottom,
                      child: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ),
              ],
            ),
          ),

          // Indicador de "escribiendo..."
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'El proveedor está escribiendo...',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textGray.withOpacity(0.8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),

          // ── Barra de solo lectura o Input normal ──
          if (chatReadOnly)
            const ReadOnlyBar()
          else
            ChatInputBar(onSendMessage: _sendMessage),
        ],
      ),
    );
  }

  String _getProviderName(String cotizacionId) {
    switch (cotizacionId) {
      case 'q1':
        return 'Juan Pérez';
      case 'q2':
        return 'Roberto Gómez';
      case 'q3':
        return 'María Silva';
      case 'q4':
        return 'Carlos Ruiz';
      case 'q5':
        return 'Ana Torres';
      case 'q6':
        return 'Luis Mendoza';
      default:
        return 'Proveedor Asignado';
    }
  }

  String _getProviderInitials(String name) {
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.length > 1 ? name.substring(0, 2).toUpperCase() : 'P';
  }

  // Encabezado (AppBar)
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    bool isAccepted,
    bool providerRequested,
    bool clientConfirmed,
  ) {
    final providerName = _getProviderName(widget.cotizacion.id);
    final providerInitials = _getProviderInitials(providerName);

    return AppBar(
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFE0E7FF), // Azul muy claro
            child: Text(
              providerInitials, // Iniciales
              style: const TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  providerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  widget
                      .cotizacion
                      .titulo, // Ej: "Instalación de 4 Minisplits (2 Ton)"
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Mostrar el botón de confirmar solo si el proveedor lo solicitó
        // y el cliente aún no lo ha confirmado.
        if (isAccepted && providerRequested && !clientConfirmed)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: _isCompletingService
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF10B981),
                          ),
                        ),
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFF10B981),
                    ),
                    tooltip: 'Confirmar finalización',
                    onPressed: _onConfirmCompletion,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
          ),
        IconButton(icon: const Icon(Icons.phone), onPressed: () {}),
        IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
      ],
    );
  }
}

// --- Componentes Adicionales ---

// Separador de Fechas
class _DateSeparator extends StatelessWidget {
  final String dateText;
  const _DateSeparator({required this.dateText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.borderLight.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            dateText,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.textGray,
            ),
          ),
        ),
      ),
    );
  }
}

// Burbuja de Chat Individual
class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isClient = message.sender == SenderType.client;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isClient
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isClient) const SizedBox(width: 4),

          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isClient
                    ? const Color(0xFFE0E7FF)
                    : Colors
                          .white, // Azul claro (cliente) vs Blanco (proveedor)
                border: !isClient
                    ? Border.all(color: AppColors.borderLight)
                    : null,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isClient
                      ? const Radius.circular(16)
                      : Radius.zero,
                  bottomRight: isClient
                      ? Radius.zero
                      : const Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: isClient
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // --- Archivo adjunto (si existe) ---
                  if (message.attachment != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: message.attachment!.type == AttachmentType.image
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: kIsWeb
                                  ? Image.network(
                                      message.attachment!.path,
                                      width: 250,
                                      fit: BoxFit.contain,
                                    )
                                  : Image.file(
                                      File(message.attachment!.path),
                                      width: 250,
                                      fit: BoxFit.contain,
                                    ),
                            )
                          : Container(
                              width: 200,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isClient
                                    ? Colors.white
                                    : AppColors.backgroundWhite,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.borderLight,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.insert_drive_file,
                                    color: Colors.orange,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      message.attachment!.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),

                  // Imagen original por compatibilidad con mocks antiguos
                  if (message.imageUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          message.imageUrl!,
                          width: 250,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 250,
                                height: 150,
                                color: AppColors.borderLight,
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: AppColors.textGray,
                                ),
                              ),
                        ),
                      ),
                    ),

                  // Texto del mensaje
                  if (message.text != null)
                    Text(
                      message.text!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textDark,
                        height: 1.3,
                      ),
                    ),
                  const SizedBox(height: 4),

                  // Hora y Doble Check
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textGray.withOpacity(0.8),
                        ),
                      ),
                      if (isClient) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.done_all,
                          size: 14,
                          color: message.isRead
                              ? AppColors.primaryBlue
                              : AppColors.textGray,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (isClient) const SizedBox(width: 4),
        ],
      ),
    );
  }

  // Utilidad para formatear la hora (ej. 10:15 am)
  String _formatTime(DateTime time) {
    String hour = time.hour > 12
        ? (time.hour - 12).toString()
        : time.hour.toString();
    if (time.hour == 0) hour = '12';
    String minute = time.minute.toString().padLeft(2, '0');
    String ampm = time.hour >= 12 ? 'pm' : 'am';
    return '$hour:$minute $ampm';
  }
}
