import 'package:app_incide/core/constants/app_strings.dart';
import 'package:app_incide/core/theme/app_colors.dart';
import 'package:app_incide/features/provider/dashboard/widgets/opportunity_badge.dart';
import 'package:flutter/material.dart';

/// Tarjeta principal para mostrar oportunidades de trabajo en el feed.
///
/// Encapsula un resumen de la información y provee accesos rápidos (Descartar/Interesado).
/// Implementa un [Stack] para dibujar una línea lateral indicadora de exclusividad
/// sin alterar el padding interno del contenido.
class OpportunityCard extends StatelessWidget {
  /// Define si se dibuja la línea lateral ámbar y el badge de "Exclusiva".
  final bool isExclusive;
  final String title;

  /// Descripción truncada automáticamente a 2 líneas.
  final String description;
  final String distance;

  /// Navega al detalle de la tarjeta.
  final VoidCallback onTap;

  /// Dispara el flujo de "Eliminación Suave" en la vista padre.
  final VoidCallback onDiscard;

  /// Abre el BottomSheet para enviar una cotización.
  final VoidCallback onInterested;

  const OpportunityCard({
    super.key,
    required this.isExclusive,
    required this.title,
    required this.description,
    required this.distance,
    required this.onTap,
    required this.onDiscard,
    required this.onInterested,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          // Usamos Stack para sobreponer la línea de color si es exclusiva
          child: Stack(
            children: [
              // --- EL CONTENIDO DE LA TARJETA ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Etiqueta y Distancia
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OpportunityBadge(isExclusive: isExclusive),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: AppColors.textGray,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${AppStrings.distancePrefix} $distance',
                              style: const TextStyle(
                                color: AppColors.textGray,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Título y Descripción
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textGray,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Botones de Acción
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: onDiscard,
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.grey.withValues(
                                  alpha: 0.1,
                                ),
                                foregroundColor: AppColors.textDark,
                                minimumSize: const Size(0, 48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                AppStrings.discardBtn,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            // 💡 Tip de limpieza: Eliminé el SizedBox vacío que había quedado aquí
                            child: ElevatedButton(
                              onPressed: onInterested,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                minimumSize: const Size(0, 48),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                AppStrings.interestedBtn,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --- LA LÍNEA INDICADORA DE EXCLUSIVIDAD ---
              if (isExclusive)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(width: 4, color: AppColors.accentYellow),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
