import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_incide/core/constants/app_strings.dart';
import '../../../../../core/theme/app_colors.dart';
import '../models/quote_model.dart';
import '../widgets/quote_pending_card.dart';
import '../widgets/quote_active_card.dart';
import '../providers/quotes_provider.dart';
import 'package:go_router/go_router.dart';

class ProfQuotesScreen extends ConsumerStatefulWidget {
  const ProfQuotesScreen({super.key});

  @override
  ConsumerState<ProfQuotesScreen> createState() => _ProfQuotesScreenState();
}

class _ProfQuotesScreenState extends ConsumerState<ProfQuotesScreen> {
  // ==========================================
  // LÓGICA DE INTERACCIÓN
  // ==========================================

  void _handleRetractProposal(QuoteModel quote) {
    // Alerta de confirmación (Doble Check)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.quoteAlertTitle),
        content: const Text(AppStrings.quoteAlertContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              AppStrings.quoteCancelLbl,
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(quotesProvider.notifier).retractProposal(quote.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(AppStrings.quoteRetiredLbl)),
              );
            },
            child: const Text(
              AppStrings.quoteRetireLbl,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _handleOpenChat(QuoteModel quote) {
    // TODO: (ROUTING) Navegar a la pantalla de Chat pasando el quote.id
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Abriendo chat con ${quote.clientName}...')),
    );
  }

  // ==========================================
  // CONSTRUCTOR DINÁMICO DE LISTAS
  // ==========================================
  Widget _buildList(List<QuoteModel> quotes) {
    if (quotes.isEmpty) {
      return const Center(
        child: Text(
          AppStrings.quoteNoQuotes,
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quotes.length,
      itemBuilder: (context, index) {
        final quote = quotes[index];

        // Elige qué tarjeta dibujar según el estado real de la cotización
        if (quote.status == QuoteStatus.pending) {
          return QuotePendingCard(
            quote: quote,
            onTap: () => _navigateToDetail(quote),
            onRetractProposal: () => _handleRetractProposal(quote),
            onOpenChat: () => _handleOpenChat(quote),
          );
        } else {
          // Reutilizamos QuoteActiveCard para Aceptadas y Terminadas (cambia colores solita)
          return QuoteActiveCard(
            quote: quote,
            onTap: () => _navigateToDetail(quote),
            onOpenChat: () => _handleOpenChat(quote),
          );
        }
      },
    );
  }

  void _navigateToDetail(QuoteModel quote) {
    // Aquí usamos el router para ir a la pantalla de detalles
    // pasándole la cotización completa a través de 'extra'
    context.pushNamed('quote_detail', extra: quote);
  }

  // ==========================================
  // CONSTRUCCIÓN DE LA UI
  // ==========================================
  @override
  Widget build(BuildContext context) {
    final allQuotes = ref.watch(quotesProvider);
    // Filtramos las listas en vivo
    final pendingQuotes = allQuotes
        .where((q) => q.status == QuoteStatus.pending)
        .toList();
    final activeQuotes = allQuotes
        .where((q) => q.status == QuoteStatus.accepted)
        .toList();
    final completedQuotes = allQuotes
        .where((q) => q.status == QuoteStatus.completed)
        .toList();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F5F7),
        appBar: AppBar(
          backgroundColor: AppColors.primaryBlue,
          elevation: 0,
          title: const Text(
            AppStrings.quoteTitle,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.notifications_active_rounded,
                color: Colors.amber,
              ),
              onPressed: () {},
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: AppColors.primaryBlue,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey.shade600,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(text: 'Todas (${allQuotes.length})'),
                  Tab(text: 'En Espera (${pendingQuotes.length})'),
                  Tab(text: 'Aceptadas (${activeQuotes.length})'),
                  Tab(text: 'Terminadas (${completedQuotes.length})'),
                ],
              ),
            ),
          ),
        ),

        // --- CONTENIDO DE LAS PESTAÑAS ---
        body: TabBarView(
          children: [
            _buildList(allQuotes), // TODAS
            _buildList(pendingQuotes), // EN ESPERA
            _buildList(activeQuotes), // ACEPTADAS
            _buildList(completedQuotes), // TERMINADAS
          ],
        ),
      ),
    );
  }
}
