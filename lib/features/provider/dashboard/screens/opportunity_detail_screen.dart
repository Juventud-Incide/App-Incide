import 'package:app_incide/core/constants/app_strings.dart';
import 'package:app_incide/core/theme/app_colors.dart';
import 'package:app_incide/features/provider/dashboard/widgets/proposal_bottom_sheet.dart';
import 'package:app_incide/features/provider/dashboard/models/opportunity_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_incide/features/shared/widgets/opportunity_info_body.dart';

/// Vista de detalle inmersiva para una Oportunidad (Solicitud de trabajo).
///
/// Esta pantalla muestra la información completa del [OpportunityModel] seleccionado.
///
/// **Contrato de Navegación:**
/// Esta pantalla actúa como una vista modal de pantalla completa. Al cerrarse
/// mediante los botones de acción inferiores, hace un `pop` devolviendo un [String]:
/// - `'discarded'`: Si el usuario descartó la oportunidad.
/// - `'accepted'`: Si el usuario envió una cotización exitosamente.
/// - `null`: Si el usuario simplemente retrocedió usando la flecha del sistema.
class OpportunityDetailScreen extends StatelessWidget {
  /// El modelo de datos inyectado por el enrutador al abrir la pantalla.
  final OpportunityModel opportunity;

  const OpportunityDetailScreen({super.key, required this.opportunity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      // Utiliza un CustomScrollView con arquitectura de Slivers para lograr
      // animaciones de compresión en la cabecera (efecto Parallax) al hacer scroll.
      body: CustomScrollView(
        slivers: [
          // 1. La Cabecera Animada (El Mapa)
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                AppStrings.detailTitle,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
              ),
              // TODO: (MAPAS) - Reemplazar este Stack con GoogleMap() o FlutterMap() centrado en las coordenadas del cliente.
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

          // 2. El Contenido de la Pantalla
          // SliverToBoxAdapter nos permite incrustar widgets normales (Column, Row)
          // dentro de un entorno de Slivers.
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: OpportunityInfoBody(
                title: opportunity.title,
                category: opportunity.category,
                distance: opportunity.formattedDistance,
                urgency: opportunity.urgency,
                priceRange: opportunity.formattedPriceRange,
                description: opportunity.description,
                isExclusive: opportunity.isExclusive,
                clientAnswers: opportunity.clientAnswers,
                photoUrls: opportunity.photoUrls,
              ),
            ),
          ),
        ],
      ),

      // 3. BOTONES DE ACCIÓN (Siempre visibles)
      bottomNavigationBar: _buildStickyBottomBar(context),
    );
  }

  // --- MÉTODOS DE CONSTRUCCIÓN INTERNOS (UI) ---
  Widget _buildStickyBottomBar(BuildContext context) {
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
            // Botón Descartar: Notifica a la vista principal para remover la tarjeta
            Expanded(
              child: SizedBox(
                height: 48,
                child: TextButton(
                  onPressed: () => context.pop('discarded'),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.grey.withValues(alpha: 0.1),
                    foregroundColor: AppColors.textDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    AppStrings.discardBtn,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Botón Interesado: Abre el flujo de cotización
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    // Lanzamos el modal y esperamos a ver si el proveedor la completó
                    final result = await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useRootNavigator: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const ProposalBottomSheet(),
                    );

                    // Si el modal devolvió 'true' (éxito), cerramos esta pantalla
                    // y le avisamos a la pantalla principal que aplique la animación verde.
                    if (result == true && context.mounted) {
                      context.pop('accepted');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    AppStrings.interestedBtn,
                    style: TextStyle(fontWeight: FontWeight.bold),
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
