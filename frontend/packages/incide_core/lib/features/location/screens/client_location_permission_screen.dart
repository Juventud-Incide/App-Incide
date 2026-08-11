import 'package:app_incide/core/constants/app_strings.dart';
import 'package:app_incide/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class ClientLocationPermissionScreen extends StatefulWidget {
  const ClientLocationPermissionScreen({super.key});

  @override
  State<ClientLocationPermissionScreen> createState() =>
      _ClientLocationPermissionScreenState();
}

class _ClientLocationPermissionScreenState
    extends State<ClientLocationPermissionScreen>
    with WidgetsBindingObserver {
  bool _checkingAfterSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Comprobamos el permiso DESPUÉS de que el primer frame ya se pintó,
    // así la pantalla aparece de inmediato sin spinner de carga.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialPermission();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Cuando el usuario regresa de la configuración del sistema,
  /// revisamos si ya concedió el permiso.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _checkingAfterSettings) {
      _checkingAfterSettings = false;
      _handlePermissionAfterSettings();
    }
  }

  Future<void> _checkInitialPermission() async {
    try {
      final status = await Permission.locationWhenInUse.status.timeout(
        const Duration(seconds: 3),
      );

      if (!mounted) return;

      if (status.isGranted) {
        // El usuario ya tenía permiso previo → ir al Dashboard
        context.goNamed('client_home');
      } else {
        // Mostrar el modal explicativo (la UI ya está visible)
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) _showExplanatoryModal();
      }
    } catch (_) {
      // Si el plugin tarda demasiado (ej. Flutter Web), simplemente
      // mostramos el modal para que el usuario pueda continuar.
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) _showExplanatoryModal();
      }
    }
  }

  /// Modal explicativo previo a la solicitud del sistema (tarea #76)
  void _showExplanatoryModal() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pill handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Ícono
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: AppColors.primaryBlue,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),

            // Título
            const Text(
              AppStrings.clientLocationModalTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Descripción (texto exacto de la tarea #76)
            const Text(
              AppStrings.clientLocationModalBody,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textGray,
                height: 1.55,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // Botón "Entendido, continuar"
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _requestPermission();
                },
                child: const Text(
                  AppStrings.clientLocationModalContinueBtn,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Botón secundario "Ahora no"
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                _handleDeniedOnce();
              },
              child: const Text(
                AppStrings.clientLocationModalLaterBtn,
                style: TextStyle(
                  color: AppColors.textGray,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Caso 1: Solicitar permiso al sistema y manejar los 3 resultados.
  Future<void> _requestPermission() async {
    final status = await Permission.locationWhenInUse.request();

    if (!mounted) return;

    if (status.isGranted) {
      // CASO 1 – Concedido: guardar coordenadas iniciales y avanzar
      // TODO BACKEND: Llamar a _saveInitialCoordinates() cuando el servicio
      //    de geolocalización (geolocator) y la API estén listos.
      await _saveInitialCoordinates();
      if (mounted) context.goNamed('client_home');
    } else if (status.isPermanentlyDenied) {
      // CASO 3 – Denegado permanentemente: redirigir a configuración del SO
      _showPermanentDenialDialog();
    } else {
      // CASO 2 – Denegado una vez: mostrar opción de reintentar más tarde
      _handleDeniedOnce();
    }
  }

  /// Caso 2: Denegado una vez — se puede reintentar más tarde.
  void _handleDeniedOnce() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          AppStrings.clientLocationDeniedOnceTitle,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: const Text(
          AppStrings.clientLocationDeniedOnceBody,
          style: TextStyle(color: AppColors.textGray, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Cerrar diálogo y mostrar modal de nuevo para reintentar
              Navigator.of(ctx).pop();
              _showExplanatoryModal();
            },
            child: const Text(
              AppStrings.clientLocationRetryBtn,
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // Por ahora permanecemos en la pantalla (o podemos ir a un home sin ubicación)
              Navigator.of(ctx).pop();
            },
            child: const Text(
              AppStrings.clientLocationLaterBtn,
              style: TextStyle(color: AppColors.textGray),
            ),
          ),
        ],
      ),
    );
  }

  /// Caso 3: Denegado permanentemente → abrir configuración del SO.
  void _showPermanentDenialDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          AppStrings.locationDeniedTitle,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: const Text(
          AppStrings.clientLocationPermanentDeniedBody,
          style: TextStyle(color: AppColors.textGray, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              AppStrings.clientLocationCancelBtn,
              style: TextStyle(color: AppColors.textGray),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              _checkingAfterSettings = true;
              await openAppSettings();
            },
            child: const Text(AppStrings.clientLocationOpenSettingsBtn),
          ),
        ],
      ),
    );
  }

  /// Después de que el usuario regresa de Configuración, revisamos de nuevo.
  Future<void> _handlePermissionAfterSettings() async {
    final status = await Permission.locationWhenInUse.status;
    if (!mounted) return;

    if (status.isGranted) {
      await _saveInitialCoordinates();
      if (mounted) context.goNamed('client_home');
    } else {
      // Sigue denegado — mostrar snackbar informativo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.locationDeniedMessage),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  /// TODO (Backend): Integrar con Geolocator para obtener lat/lng y guardarlos.
  Future<void> _saveInitialCoordinates() async {
    // Placeholder – aquí se llamará al servicio de geolocalización real
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 40.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // --- ILUSTRACIÓN ---
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.primaryBlue,
                    size: 64,
                  ),
                ),
                const SizedBox(height: 40),

                // --- TÍTULOS ---
                const Text(
                  AppStrings.clientLocationTitle,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  AppStrings.clientLocationSubtitle,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textGray,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),

                // --- BOTÓN PRINCIPAL ---
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _showExplanatoryModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      AppStrings.allowLocationBtn,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
