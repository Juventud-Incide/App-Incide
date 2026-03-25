import 'package:app_incide/core/constants/app_strings.dart';
import 'package:app_incide/core/theme/app_colors.dart';
import 'package:app_incide/features/provider/dashboard/widgets/opportunity_badge.dart';
import 'package:app_incide/features/provider/dashboard/widgets/proposal_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OpportunityDetailScreen extends StatelessWidget {
  const OpportunityDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      // CustomScrollView permite animaciones complejas al hacer scroll
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
              // Aquí iría el widget de Google Maps.
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y Estado
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          AppStrings.opportunityTitle2,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      OpportunityBadge(isExclusive: false),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Info Rápida (Categoría, Distancia, Urgencia)
                  _buildQuickInfoRow(),
                  const SizedBox(height: 24),

                  // Presupuesto del Sistema
                  _buildEstimatedPriceBox(),
                  const SizedBox(height: 24),

                  // Descripción
                  const Text(
                    AppStrings.descriptionTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    AppStrings.opportunityDetailSubtitle2,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textGray,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Cuestionario del Cliente
                  const Text(
                    AppStrings.clientAnswers,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildQuestionAnswer(
                    AppStrings.question1,
                    AppStrings.answer1,
                  ),
                  _buildQuestionAnswer(
                    AppStrings.question2,
                    AppStrings.answer2,
                  ),
                  _buildQuestionAnswer(
                    AppStrings.question3,
                    AppStrings.answer3,
                  ),
                  const SizedBox(height: 32),

                  // Fotos Adjuntas
                  const Text(
                    AppStrings.attachedPhotos,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPhotoGallery(),

                  const SizedBox(height: 40), // Espacio extra al final
                ],
              ),
            ),
          ),
        ],
      ),

      // 3. Botones Fijos en la parte inferior (Siempre visibles)
      bottomNavigationBar: _buildStickyBottomBar(context),
    );
  }

  // --- SUB-WIDGETS ---

  Widget _buildQuickInfoRow() {
    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: [
        _infoChip(Icons.build_rounded, AppStrings.opportunityCategory),
        _infoChip(
          Icons.location_on_rounded,
          '${AppStrings.distancePrefix} ${AppStrings.opportunityDistance2}',
        ),
        _infoChip(
          Icons.access_time_filled_rounded,
          AppStrings.opportunityUrgency,
        ),
      ],
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.primaryBlue),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstimatedPriceBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.estimatedPrice,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Text(
                AppStrings.systemCalculated,
                style: TextStyle(fontSize: 11, color: Colors.green),
              ),
            ],
          ),
          Text(
            AppStrings.priceRange,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.green[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionAnswer(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textGray,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: const TextStyle(fontSize: 14, color: AppColors.textDark),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGallery() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.image, color: Colors.grey),
          );
        },
      ),
    );
  }

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
            Expanded(
              child: SizedBox(
                height: 48,
                child: TextButton(
                  onPressed: () => context.pop(true),
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
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useRootNavigator: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const ProposalBottomSheet(),
                    );
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
