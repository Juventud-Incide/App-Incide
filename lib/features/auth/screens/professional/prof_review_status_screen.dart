import 'package:app_incide/core/theme/app_colors.dart';
import 'package:app_incide/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Enumeración que representa la Máquina de Estados del proceso de admisión.
///
/// Define las etapas por las que debe pasar un proveedor antes de que
/// se le permita el acceso al Dashboard principal de la aplicación.
enum ApplicationStatus {
  /// Recién registrado. Sus datos iniciales están siendo revisados.
  pendingReview,

  /// Aprobó la revisión inicial y se le asignó una entrevista presencial/virtual.
  interviewScheduled,

  /// Aprobó la entrevista y subió sus documentos. Esperando validación final.
  validatingDocs,

  /// Proceso completado. La cuenta está activa (este estado suele redirigir al Dashboard).
  activated,
}

/// Sala de espera (Waiting Room) dinámica para el Proveedor.
///
/// **Rol en la Arquitectura:**
/// Esta pantalla actúa como una vista de "solo lectura" persistente. Si un usuario
/// cierra la app y vuelve a iniciar sesión antes de ser activado, el Router
/// detectará su estado y lo enviará aquí automáticamente.
///
/// **Renderizado Condicional:**
/// La interfaz se reconstruye por completo (textos, íconos, línea de tiempo, y
/// la tarjeta de cita) evaluando el `ApplicationStatus` provisto por el Backend.
class ProfReviewStatusScreen extends StatefulWidget {
  const ProfReviewStatusScreen({super.key});

  @override
  State<ProfReviewStatusScreen> createState() => _ProfReviewStatusScreenState();
}

class _ProfReviewStatusScreenState extends State<ProfReviewStatusScreen> {
  // --- MOCK DATA (Simulando respuesta del Backend) ---
  // TODO: (BACKEND) - Reemplazar estas variables inyectando el perfil del usuario usando Riverpod (ej: `ref.watch(userProfileProvider).applicationStatus`)
  final ApplicationStatus _currentStatus = ApplicationStatus.interviewScheduled;
  final String _interviewDate = "Jueves 28 de Marzo, 10:00 AM";
  final String _interviewLocation = "Oficinas INCIDE (Col. Centro, Hermosillo)";
  // -----------------------------------------------------------

  /// Constructor del widget visual para cada paso de la línea de tiempo.
  ///
  /// [title] Texto descriptivo del paso.
  /// [isCompleted] Si es `true`, marca el círculo de color verde.
  /// [isActive] Si es `true` y no está completado, marca el círculo de azul con borde.
  /// [isLast] Si es `true`, elimina el padding inferior extra.
  Widget _buildTimelineStep({
    required String title,
    required bool isCompleted,
    required bool isActive,
    bool isLast = false,
  }) {
    // Lógica de cálculo de color centralizada
    final Color dotColor = isCompleted
        ? const Color(0xFF10B981) // Verde completado
        : isActive
        ? AppColors
              .primaryBlue // Azul actual (En progreso)
        : const Color(0xFFD1D5DB); // Gris pendiente (Pendiente futuro)

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20.0),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
              // Si es el paso activo, le agregamos un aura azul (borde exterior)
              border: isActive
                  ? Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.3),
                      width: 4,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 15),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              // Engrosa la fuente si el paso ya pasó o está activo
              fontWeight: isActive || isCompleted
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: isActive || isCompleted
                  ? AppColors.textDark
                  : AppColors.textGray,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 1),

              // --- 1. ICONO CENTRAL DINÁMICO ---
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: _currentStatus == ApplicationStatus.pendingReview
                      ? Colors.amber.withValues(alpha: 0.1)
                      : AppColors.primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _currentStatus == ApplicationStatus.pendingReview
                      ? Icons
                            .access_time_rounded // Reloj para revisión
                      : Icons
                            .calendar_month_rounded, // Calendario para cita programada
                  size: 45,
                  color: _currentStatus == ApplicationStatus.pendingReview
                      ? Colors.amber
                      : AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 25),

              // --- 2. TÍTULO Y DESCRIPCIÓN ---
              Text(
                _currentStatus == ApplicationStatus.pendingReview
                    ? AppStrings.underReviewTitle
                    : _currentStatus == ApplicationStatus.interviewScheduled
                    ? AppStrings.interviewScheduledTitle
                    : AppStrings.documentValidationTitle,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                _currentStatus == ApplicationStatus.pendingReview
                    ? AppStrings.underReviewSubtitle1
                    : _currentStatus == ApplicationStatus.interviewScheduled
                    ? AppStrings.interviewScheduledSubtitle1
                    : AppStrings.documentValidationSubtitle1,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textGray,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),

              // --- 3. TARJETA DE CITA (Solo visible si hay cita) ---
              // Solo se inyecta en el árbol de widgets si existe una cita programada
              if (_currentStatus == ApplicationStatus.interviewScheduled)
                Container(
                  margin: const EdgeInsets.only(bottom: 30),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _interviewDate,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _interviewLocation,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // --- 4. TIMELINE DINÁMICO ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25.0),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F5F7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Paso 1: Envio inicial (Siempre completado si llegó aquí)
                    _buildTimelineStep(
                      title: AppStrings.sentTimelineStep,
                      isCompleted: true,
                      isActive: false,
                    ),

                    // Paso 2: Revisión de datos
                    _buildTimelineStep(
                      title: AppStrings.reviewTimelineStep,
                      isCompleted:
                          _currentStatus != ApplicationStatus.pendingReview,
                      isActive:
                          _currentStatus == ApplicationStatus.pendingReview,
                    ),

                    // Paso 3: Entrevista Presencial/Virtual
                    _buildTimelineStep(
                      title: AppStrings.interviewTimelineStep,
                      isCompleted:
                          _currentStatus == ApplicationStatus.validatingDocs ||
                          _currentStatus == ApplicationStatus.activated,
                      isActive:
                          _currentStatus ==
                          ApplicationStatus.interviewScheduled,
                    ),

                    // Paso 4: Carga y validación de documentos oficiales
                    _buildTimelineStep(
                      title: AppStrings.reviewDocsTimelineStep,
                      isCompleted:
                          _currentStatus == ApplicationStatus.activated,
                      isActive:
                          _currentStatus == ApplicationStatus.validatingDocs,
                    ),

                    // Paso 5: Activación final
                    _buildTimelineStep(
                      title: AppStrings.activatedTimelineStep,
                      isCompleted:
                          _currentStatus == ApplicationStatus.activated,
                      isActive: false,
                      isLast: true,
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // --- 5. BOTÓN CERRAR SESIÓN ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: (BACKEND) - Invocar authController.logout() antes de salir
                    context.goNamed('splash');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    AppStrings.logoutBtn,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
