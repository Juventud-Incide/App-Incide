import 'package:app_incide/core/constants/app_strings.dart';
import 'package:app_incide/features/provider/chat/widgets/typing_bubble.dart';
import 'package:app_incide/features/provider/quotes/models/quote_model.dart';
import 'package:app_incide/features/provider/quotes/providers/quotes_provider.dart';
import 'package:app_incide/features/shared/utils/quote_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../domain/models/chat_message.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/message_bubble.dart';
import '../widgets/system_bubble.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String chatId;
  final bool isAccepted;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    this.isAccepted = false,
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  late final ActiveChatNotifier _activeNotifier;

  final ScrollController _scrollController = ScrollController();

  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _activeNotifier = ref.read(activeChatProvider.notifier);
    // Usamos addPostFrameCallback por seguridad en Flutter.
    // Esto le dice al framework: "Espera a que la pantalla termine de dibujarse
    // por primera vez, y justo después, ejecuta esta función".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 1. Reportamos que estamos DENTRO de este chat
      _activeNotifier.setActiveChat(widget.chatId);
      ref.read(chatProvider.notifier).markMessagesAsRead(widget.chatId);
    });
  }

  @override
  void dispose() {
    Future.microtask(() => _activeNotifier.setActiveChat(null));
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Si estamos a 200 pixeles o menos de llegar al límite superior del historial...
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore) {
        _fetchOlderMessages();
      }
    }
  }

  Future<void> _fetchOlderMessages() async {
    setState(() {
      _isLoadingMore = true;
    });
    await ref.read(chatProvider.notifier).loadOlderMessages(widget.chatId);
    if (mounted) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  String _formatDateDivider(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return AppStrings.chatToday;
    } else if (messageDate == yesterday) {
      return AppStrings.chatYesterday;
    } else {
      // Si es más viejo, mostramos ej: "15/05/2026"
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages =
        ref.watch(chatProvider)[widget.chatId] ??
        [
          ChatMessage(
            id: 'sys',
            content: AppStrings.chatStartTitle,
            isMine: false,
            type: MessageType.system,
            timestamp: DateTime.now(),
          ),
        ];
    final displayMessages = messages.reversed.toList();
    final typingMap = ref.watch(typingProvider);
    final isTyping = typingMap[widget.chatId] ?? false;
    final currentQuote = ref
        .watch(quotesProvider)
        .firstWhere((q) => q.id == widget.chatId);
    final isCompletedByProvider = currentQuote.providerMarkedCompleted;
    final isReadOnly =
        currentQuote.status == QuoteStatus.completed ||
        currentQuote.status == QuoteStatus.rejected;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: ChatAppBar(
        isAccepted:
            currentQuote.status == QuoteStatus.accepted ||
            currentQuote.status == QuoteStatus.completed,
        isCompleted: isCompletedByProvider,
        isReadOnly: isReadOnly,
        realName: currentQuote.clientName,
        serviceTitle: currentQuote.title,
        clientAvatarUrl: currentQuote.clientAvatarUrl,
        onMarkAsCompleted: () => QuoteDialogs.showCompletionDialog(
          context: context,
          ref: ref,
          chatId: widget.chatId,
          isCurrentlyCompleted: isCompletedByProvider,
        ),
      ),
      body: Column(
        children: [
          // Área de mensajes
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 20, top: 10),
              reverse: true,
              itemCount:
                  displayMessages.length +
                  (isTyping ? 1 : 0) +
                  (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                // Si están escribiendo, la burbuja animada toma el índice 0 (abajo de todo)
                if (isTyping) {
                  if (index == 0) {
                    return const TypingBubble();
                  }
                  // Desplazamos el resto de los mensajes un lugar hacia arriba
                  index -= 1;
                }

                if (index == displayMessages.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final message = displayMessages[index];
                bool showDateDivider = false;

                if (index == displayMessages.length - 1) {
                  showDateDivider = true;
                } else {
                  // Comparamos con el mensaje "anterior" cronológicamente (index + 1 en reverse)
                  final previousMessage = displayMessages[index + 1];

                  final currentDate = DateTime(
                    message.timestamp.year,
                    message.timestamp.month,
                    message.timestamp.day,
                  );
                  final previousDate = DateTime(
                    previousMessage.timestamp.year,
                    previousMessage.timestamp.month,
                    previousMessage.timestamp.day,
                  );

                  if (currentDate != previousDate) {
                    showDateDivider = true;
                  }
                }

                Widget messageWidget;
                if (message.type == MessageType.system) {
                  messageWidget = SystemBubble(text: message.content);
                } else {
                  messageWidget = MessageBubble(message: message);
                }

                if (showDateDivider) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 16,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _formatDateDivider(message.timestamp),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Y debajo de la fecha, el mensaje correspondiente
                      messageWidget,
                    ],
                  );
                }

                return messageWidget;
              },
            ),
          ),

          // Barra de entrada de texto
          if (isReadOnly)
            Container(
              width: double.infinity,
              color: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Icon(
                      Icons.lock_outline,
                      color: Colors.grey.shade600,
                      size: 24,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.chatFinishedTitle,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.chatReadOnlyTitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ChatInputBar(chatId: widget.chatId),
        ],
      ),
    );
  }
}
