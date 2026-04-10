import 'package:app_incide/core/constants/app_strings.dart';
import 'package:app_incide/features/shared/utils/quote_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../models/quote_model.dart';
import '../providers/quotes_provider.dart';
import '../../../shared/widgets/opportunity_info_body.dart';

class QuoteDetailScreen extends ConsumerWidget {
  final QuoteModel quote; // Recibimos el modelo desde el router

  const QuoteDetailScreen({super.key, required this.quote});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // MAGIA REACTIVA: Escuchamos el estado global buscando ESTA cotización en específico.
    // Si la cotización se cancela o acepta, la pantalla se redibuja sola.
    final currentQuotes = ref.watch(quotesProvider);

    // Buscamos la cotización actualizada. Si por alguna razón no existe (ej. se borró),
    // usamos la que nos pasaron por el router como respaldo (orElse).
    final activeQuote = currentQuotes.firstWhere(
      (q) => q.id == quote.id,
      orElse: () => quote,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // CABECERA (El mapa se queda en la pantalla porque maneja el SliverAppBar)
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                AppStrings.quoteDetailTitle,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: Colors.blueGrey[100],
                  ), // Fondo placeholder del mapa
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: AppColors.primaryBlue,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // TODO: (MAPAS) - Reemplazar este Stack con GoogleMap() o FlutterMap() centrado en las coordenadas del cliente.
          // CONTENIDO
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Estatus de la Cotización
                  _buildStatusBadge(activeQuote),
                  const SizedBox(height: 16),
                  OpportunityInfoBody(
                    title: activeQuote.title,
                    category: activeQuote.category,
                    distance: activeQuote.distance,
                    urgency: activeQuote.urgency,
                    priceRange: activeQuote.finalPrice != null
                        ? '\$${activeQuote.finalPrice!.toStringAsFixed(0)} MXN'
                        : null,
                    description: activeQuote.description,
                    clientAnswers: activeQuote.clientAnswers,
                    photoUrls: activeQuote.photoUrls,
                    isExclusive: activeQuote.isExclusive,
                  ),

                  // Información del Cliente (Exclusivo de Mis Cotizaciones)
                  const Text(
                    AppStrings.quoteDetailClientTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildClientInfoCard(activeQuote),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildStickyBottomBar(context, ref, activeQuote),
    );
  }

  Widget _buildStatusBadge(QuoteModel q) {
    final isAccepted = q.status == QuoteStatus.accepted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isAccepted ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isAccepted
            ? AppStrings.acceptedQuotesTitle
            : AppStrings.quotePendingTitle,
        style: TextStyle(
          color: isAccepted ? const Color(0xFF059669) : const Color(0xFFD97706),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildClientInfoCard(QuoteModel q) {
    final isAccepted = q.status == QuoteStatus.accepted;
    final bool showPhoto =
        isAccepted &&
        q.clientAvatarUrl != null &&
        q.clientAvatarUrl!.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
            backgroundImage: showPhoto
                ? NetworkImage(q.clientAvatarUrl!)
                : null,
            child: !showPhoto
                ? Text(
                    q.clientName[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAccepted
                      ? q.clientName
                      : AppStrings.quoteDetailClientNameProtected,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  isAccepted
                      ? q.clientPhoneNumber
                      : AppStrings.quoteDetailClientProtected,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBottomBar(
    BuildContext context,
    WidgetRef ref,
    QuoteModel q,
  ) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            if (q.status == QuoteStatus.pending) ...[
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => QuoteDialogs.showRetractConfirmation(
                      context: context,
                      ref: ref,
                      quoteId: q.id,
                      popScreenAfter:
                          true, // Importante para que regrese a la lista
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: BorderSide(color: Colors.red.shade200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(AppStrings.quoteRemoveBtn),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () {}, // Abrir chat
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text(AppStrings.quoteOpenChatBtn),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
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
