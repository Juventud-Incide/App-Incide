import 'package:incide_core/core/constants/app_strings.dart';
import 'package:app_proveedor/features/provider/quotes/widgets/chat_button_badge.dart';
import 'package:app_proveedor/features/shared/utils/quote_dialogs.dart';
import 'package:app_proveedor/features/shared/widgets/cached_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:incide_core/core/theme/app_colors.dart';
import '../models/quote_model.dart';
import '../../../shared/widgets/quote_status_badge.dart';
import '../providers/quotes_provider.dart';
import '../../../shared/widgets/opportunity_info_body.dart';

/// Pantalla de detalle exhaustivo para una cotización específica.
///
/// **Arquitectura Reactiva:**
/// Aunque la pantalla recibe un [QuoteModel] inicial a través del constructor (Router),
/// utiliza Riverpod para escuchar activamente los cambios de estado. Si la cotización
/// es aceptada, rechazada o cancelada mientras el usuario está en esta vista,
/// la UI se actualizará instantáneamente (ej. los colores del badge y los botones inferiores).
class QuoteDetailScreen extends ConsumerWidget {
  /// Copia estática (Snapshot) de la cotización pasada durante la navegación.
  /// Sirve como punto de partida y como respaldo en caso de errores de sincronización.
  final QuoteModel quote;

  const QuoteDetailScreen({super.key, required this.quote});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // -------------------------------------------------------------------------
    // LÓGICA DE SINCRONIZACIÓN DE ESTADO
    // -------------------------------------------------------------------------
    // Observamos la lista global de cotizaciones. Cada vez que cambie,
    // evaluaremos si nuestra cotización actual fue afectada.
    final currentQuotes = ref.watch(quotesProvider);

    // Intentamos encontrar la versión más fresca de esta cotización en la memoria global.
    // Si la cotización fue eliminada (ej. un borrado en cascada), evitamos un crash
    // usando `orElse` para devolver el snapshot original con el que entramos.
    final activeQuote = currentQuotes.firstWhere(
      (q) => q.id == quote.id,
      orElse: () => quote,
    );

    // -------------------------------------------------------------------------
    // CONSTRUCCIÓN DE LA UI
    // -------------------------------------------------------------------------
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // --- 1. CABECERA DESLIZABLE (SliverAppBar) ---
          // Se colapsa en un Appbar normal al hacer scroll hacia abajo, optimizando
          // el espacio en pantallas pequeñas mientras preserva el contexto del mapa.
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
                  // TODO: (MAPAS) Integración del componente nativo de mapa.
                  Container(
                    color: Colors.blueGrey[100],
                  ), // Placeholder estático del mapa
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

          // --- 2. CUERPO DE LA INFORMACIÓN (SliverToBoxAdapter) ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Estado actual con inyección semántica de colores vía Extension.
                  QuoteStatusBadge(status: activeQuote.status),
                  const SizedBox(height: 16),

                  // Componente reutilizable (Usado también en OpportunityDetail).
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

                  // Sección de Contacto del Cliente
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

                  const SizedBox(
                    height: 40,
                  ), // Margen para el SafeArea inferior
                ],
              ),
            ),
          ),
        ],
      ),
      // --- 3. BARRA DE ACCIONES ANCLADA (Sticky Bottom Bar) ---
      bottomNavigationBar: _buildStickyBottomBar(context, ref, activeQuote),
    );
  }

  // =================================--------------------------------------
  // WIDGETS AUXILIARES PRIVADOS
  // =================================--------------------------------------

  /// Construye la tarjeta de perfil del cliente.
  ///
  /// **Regla de Privacidad de Negocio:** /// Si la cotización NO ha sido aceptada por el cliente ([QuoteStatus.accepted]),
  /// el nombre, teléfono y fotografía permanecen ofuscados o genéricos para
  /// proteger la PII (Personally Identifiable Information) del cliente.
  Widget _buildClientInfoCard(QuoteModel q) {
    final isAccepted =
        q.status == QuoteStatus.accepted || q.status == QuoteStatus.completed;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CachedAvatar(
            imageUrl: q.clientAvatarUrl,
            radius: 24, // Ajusta al tamaño que tenías en tu diseño
            fallbackColor: AppColors.primaryBlue.withValues(alpha: 0.1),
            textColor: AppColors.textDark,
            // Extraemos las iniciales dinámicamente
            fallbackInitials: q.clientName.substring(0, 2).toUpperCase(),
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

  /// Construye la barra de acciones inferior, anclada permanentemente.
  ///
  /// Su composición es dinámica: si el trato sigue `pending`, permite cancelar.
  /// De lo contrario, destina todo el espacio al botón principal de comunicación.
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
              offset: const Offset(0, -5), // Sombra invertida (hacia arriba)
            ),
          ],
        ),
        child: Row(
          children: [
            // Botón de cancelación (Únicamente visible en etapa temprana)
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
                          true, // Forzamos el retroceso del Router (pop) tras la acción.
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

            // Botón principal de acción (Comunicación)
            Expanded(
              child: ChatButtonBadge(
                chatId: q.id.toString(),
                onPressed: () {
                  final String currentChatId = q.id.toString();
                  context.pushNamed(
                    'chat_detail',
                    pathParameters: {'chatId': currentChatId},
                    extra: {'isAccepted': q.status == QuoteStatus.accepted},
                  );
                },
                isPrimaryStyle: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
