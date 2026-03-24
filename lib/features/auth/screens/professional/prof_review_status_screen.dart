import 'package:app_incide/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Definimos los posibles estados del usuario en la base de datos
enum ApplicationStatus {
  pendingReview, // Recién registrado
  interviewScheduled, // Ya tiene cita
  validatingDocs, // Ya subió documentos
  activated, // Cuenta activada
}

class ProfReviewStatusScreen extends StatefulWidget {
  const ProfReviewStatusScreen({super.key});

  @override
  State<ProfReviewStatusScreen> createState() => _ProfReviewStatusScreenState();
}

class _ProfReviewStatusScreenState extends State<ProfReviewStatusScreen> {
  // --- MOCK DATA (Simulando lo que vendría del Backend) ---
  // Cambia esto para ver cómo cambian los estados de espera
  final ApplicationStatus _currentStatus = ApplicationStatus.interviewScheduled;
  final String? _interviewDate = "Jueves 28 de Marzo, 10:00 AM";
  final String? _interviewLocation =
      "Oficinas INCIDE (Col. Centro, Hermosillo)";
  // -----------------------------------------------------------

  Widget _buildTimelineStep({
    required String title,
    required bool isCompleted,
    required bool isActive,
    bool isLast = false,
  }) {
    final Color dotColor = isCompleted
        ? const Color(0xFF10B981) // Verde completado
        : isActive
        ? AppColors
              .primaryBlue // Azul actual
        : const Color(0xFFD1D5DB); // Gris pendiente

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
                      ? Icons.access_time_rounded
                      : Icons.calendar_month_rounded,
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
                    ? 'Cuenta en Revisión'
                    : _currentStatus == ApplicationStatus.interviewScheduled
                    ? 'Entrevista Programada'
                    : 'Documentos en Validación',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                _currentStatus == ApplicationStatus.pendingReview
                    ? 'Hemos recibido tu solicitud. Nuestro equipo validará tu perfil para agendar tu Entrevista Presencial.'
                    : _currentStatus == ApplicationStatus.interviewScheduled
                    ? 'Tu perfil ha pasado el primer filtro. Te esperamos en nuestras oficinas para conocerte en persona.'
                    : 'Estamos revisando tus documentos. Te contactaremos una vez concluyamos el proceso.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textGray,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),

              // --- 3. TARJETA DE CITA (Solo visible si hay cita) ---
              if (_currentStatus == ApplicationStatus.interviewScheduled &&
                  _interviewDate != null &&
                  _interviewLocation != null)
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
                    _buildTimelineStep(
                      title: 'Solicitud enviada',
                      isCompleted: true,
                      isActive: false,
                    ),
                    _buildTimelineStep(
                      title: 'Revisión de INCIDE',
                      isCompleted:
                          _currentStatus != ApplicationStatus.pendingReview,
                      isActive:
                          _currentStatus == ApplicationStatus.pendingReview,
                    ),
                    _buildTimelineStep(
                      title: 'Entrevista Presencial',
                      isCompleted:
                          _currentStatus == ApplicationStatus.validatingDocs ||
                          _currentStatus == ApplicationStatus.activated,
                      isActive:
                          _currentStatus ==
                          ApplicationStatus.interviewScheduled,
                    ),
                    _buildTimelineStep(
                      title: 'Revisión de Documentos',
                      isCompleted:
                          _currentStatus == ApplicationStatus.activated,
                      isActive:
                          _currentStatus == ApplicationStatus.validatingDocs,
                    ),
                    _buildTimelineStep(
                      title: 'Activación de cuenta',
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
                  onPressed: () => context.go('/'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Cerrar Sesión',
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
