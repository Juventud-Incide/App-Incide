import 'package:app_incide/features/shared/widgets/custom_provider_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_incide/core/constants/app_strings.dart';
import '../../../../../core/theme/app_colors.dart';
import '../models/quote_model.dart';
import '../widgets/quote_pending_card.dart';
import '../widgets/quote_active_card.dart';
import '../providers/quotes_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:app_incide/features/shared/utils/quote_dialogs.dart';

/// Pantalla principal para la gestión de cotizaciones del proveedor.
///
/// **Arquitectura:**
/// Esta pantalla actúa como el "View" en el patrón MVVM/Riverpod. Su responsabilidad
/// es escuchar a [quotesProvider], filtrar los datos recibidos en listas categorizadas
/// (Todas, En Espera, Aceptadas, Terminadas) y renderizar el componente visual
/// adecuado ([QuotePendingCard] o [QuoteActiveCard]).
class ProfQuotesScreen extends ConsumerStatefulWidget {
  const ProfQuotesScreen({super.key});

  @override
  ConsumerState<ProfQuotesScreen> createState() => _ProfQuotesScreenState();
}

class _ProfQuotesScreenState extends ConsumerState<ProfQuotesScreen> {
  // ==========================================
  // LÓGICA DE INTERACCIÓN (Delegación)
  // ==========================================

  /// Inicia el flujo de comunicación directa con el cliente.
  ///
  /// Se dispara desde el botón "Abrir Chat" de cualquier tarjeta.
  void _handleOpenChat(QuoteModel quote) {
    // TODO: (ROUTING) Implementar navegación a `InboxScreen` inyectando el ID del chat.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Abriendo chat con ${quote.clientName}...')),
    );
  }

  /// Navega a la pantalla de detalles usando el router de la app.
  ///
  /// Pasa el objeto [QuoteModel] completo como payload (`extra`) para
  /// evitar llamadas innecesarias a la base de datos en la siguiente pantalla.
  void _navigateToDetail(QuoteModel quote) {
    context.pushNamed('quote_detail', extra: quote);
  }

  // ==========================================
  // CONSTRUCTOR DINÁMICO DE LISTAS
  // ==========================================

  /// Genera una lista scrolleable de tarjetas basada en el array proporcionado.
  ///
  /// Es un método auxiliar (Helper Method) que evita duplicar el código del
  /// `ListView.builder` cuatro veces (una por cada pestaña).
  Widget _buildList(List<QuoteModel> quotes) {
    // Manejo de estado vacío (Empty State)
    if (quotes.isEmpty) {
      return const Center(
        child: Text(
          AppStrings.quoteNoQuotes,
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    // Renderizado eficiente (solo dibuja las tarjetas visibles en pantalla)
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quotes.length,
      itemBuilder: (context, index) {
        final quote = quotes[index];

        // Lógica de Renderizado Polimórfico:
        // Si el estado permite "Retirar Propuesta", dibujamos la tarjeta especial.
        if (quote.status == QuoteStatus.pending) {
          return QuotePendingCard(
            quote: quote,
            onTap: () => _navigateToDetail(quote),
            onRetractProposal: () => QuoteDialogs.showRetractConfirmation(
              context: context,
              ref: ref,
              quoteId: quote.id,
            ),
            onOpenChat: () => _handleOpenChat(quote),
          );
        } else {
          // Para cualquier otro estado (Aceptado, Rechazado, Completado),
          // usamos la tarjeta genérica que no tiene el botón de retirar.
          return QuoteActiveCard(
            quote: quote,
            onTap: () => _navigateToDetail(quote),
            onOpenChat: () => _handleOpenChat(quote),
          );
        }
      },
    );
  }

  // ==========================================
  // CONSTRUCCIÓN DE LA UI (Método Build)
  // ==========================================
  @override
  Widget build(BuildContext context) {
    // 1. Escucha activa (Rebuild trigger):
    // Si una cotización cambia de estado en otra pantalla, esta línea forzará
    // a que todo el `build` se vuelva a ejecutar automáticamente.
    final allQuotes = ref.watch(quotesProvider);

    // 2. Cálculo derivado (Filtros en memoria):
    final pendingQuotes = allQuotes
        .where((q) => q.status == QuoteStatus.pending)
        .toList();
    final activeQuotes = allQuotes
        .where((q) => q.status == QuoteStatus.accepted)
        .toList();
    final completedQuotes = allQuotes
        .where(
          // Agrupamos el histórico (Terminadas o Rechazadas) en la misma pestaña.
          (q) =>
              q.status == QuoteStatus.completed ||
              q.status == QuoteStatus.rejected,
        )
        .toList();

    // 3. Renderizado del Scaffold con controlador de pestañas integrado.
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F5F7),

        // Cabecera global reutilizable con la campana inteligente.
        appBar: const CustomProviderAppBar(title: AppStrings.quoteTitle),

        body: Column(
          children: [
            // --- NAVEGACIÓN DE PESTAÑAS (TabBar) ---
            Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              width: double.infinity,
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

            // --- VISTAS ASOCIADAS A LAS PESTAÑAS (TabBarView) ---
            Expanded(
              child: TabBarView(
                children: [
                  _buildList(allQuotes), // Índice 0: TODAS
                  _buildList(pendingQuotes), // Índice 1: EN ESPERA
                  _buildList(activeQuotes), // Índice 2: ACEPTADAS
                  _buildList(
                    completedQuotes,
                  ), // Índice 3: TERMINADAS/RECHAZADAS
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
