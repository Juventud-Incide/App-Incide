import 'package:app_incide/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../models/quote_model.dart';
import '../widgets/quote_pending_card.dart';
import '../widgets/quote_active_card.dart';

class ProfQuotesScreen extends StatefulWidget {
  const ProfQuotesScreen({super.key});

  @override
  State<ProfQuotesScreen> createState() => _ProfQuotesScreenState();
}

class _ProfQuotesScreenState extends State<ProfQuotesScreen> {
  // ==========================================
  // MOCK DATA
  // ==========================================
  final List<QuoteModel> _mockQuotes = [
    QuoteModel(
      id: 'Q-001',
      clientId: 'C-001',
      clientName: 'Cliente Anónimo',
      clientPhoneNumber: '6620000000',
      serviceCategory: 'Construcción de Habitación',
      problemDescription:
          'Necesito ampliar mi casa con un cuarto extra de 4x4m.',
      requestDate: DateTime.now().subtract(const Duration(days: 1)),
      dateQuoteSent: DateTime.now().subtract(const Duration(hours: 2)),
      estimatedPrice: 8000,
      status: QuoteStatus.pending,
    ),
    QuoteModel(
      id: 'Q-002',
      clientId: 'C-002',
      clientName: 'Angie Serna',
      clientPhoneNumber: '6621234567',
      serviceCategory: 'Instalación de 4 Minisplits (2 Ton)',
      problemDescription:
          'El centro de carga hizo un chispazo y la mitad de la casa se quedó sin energía.',
      requestDate: DateTime.now().subtract(const Duration(days: 3)),
      dateQuoteSent: DateTime.now().subtract(const Duration(days: 2)),
      estimatedPrice: 3200,
      status: QuoteStatus.accepted,
      unreadMessagesCount: 1,
    ),
    // NUEVA COTIZACIÓN DE PRUEBA: Terminada
    QuoteModel(
      id: 'Q-003',
      clientId: 'C-003',
      clientName: 'Carlos López',
      clientPhoneNumber: '6629998888',
      serviceCategory: 'Reparación de Tubería',
      problemDescription: 'Fuga de agua en el baño principal. Inundación leve.',
      requestDate: DateTime.now().subtract(const Duration(days: 10)),
      dateQuoteSent: DateTime.now().subtract(const Duration(days: 9)),
      estimatedPrice: 850,
      status: QuoteStatus.completed,
    ),
  ];

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
              // TODO: (BACKEND) Llamar a Riverpod para actualizar el status a Cancelled
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
          'No hay cotizaciones en esta categoría.',
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
            onRetractProposal: () => _handleRetractProposal(quote),
            onOpenChat: () => _handleOpenChat(quote),
          );
        } else {
          // Reutilizamos QuoteActiveCard para Aceptadas y Terminadas (cambia colores solita)
          return QuoteActiveCard(
            quote: quote,
            onOpenChat: () => _handleOpenChat(quote),
          );
        }
      },
    );
  }

  // ==========================================
  // CONSTRUCCIÓN DE LA UI
  // ==========================================
  @override
  Widget build(BuildContext context) {
    // Filtramos las listas en vivo
    final pendingQuotes = _mockQuotes
        .where((q) => q.status == QuoteStatus.pending)
        .toList();
    final activeQuotes = _mockQuotes
        .where((q) => q.status == QuoteStatus.accepted)
        .toList();
    final completedQuotes = _mockQuotes
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
                  Tab(text: 'Todas (${_mockQuotes.length})'),
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
            _buildList(_mockQuotes), // TODAS
            _buildList(pendingQuotes), // EN ESPERA
            _buildList(activeQuotes), // ACEPTADAS
            _buildList(completedQuotes), // TERMINADAS
          ],
        ),
      ),
    );
  }
}
