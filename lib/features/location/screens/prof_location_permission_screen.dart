import 'package:app_incide/core/constants/app_strings.dart';
import 'package:app_incide/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfLocationPermissionScreen extends StatefulWidget {
  const ProfLocationPermissionScreen({super.key});

  @override
  State<ProfLocationPermissionScreen> createState() =>
      _ProfLocationPermissionScreenState();
}

class _ProfLocationPermissionScreenState
    extends State<ProfLocationPermissionScreen>
    with WidgetsBindingObserver {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkInitialPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Esto detecta si el usuario fue a la configuración del celular y regresó a la app
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkInitialPermission();
    }
  }

  Future<void> _checkInitialPermission() async {
    final status = await Permission.locationWhenInUse.status;

    if (status.isGranted) {
      // Si ya tiene permiso, lo mandamos directo al Dashboard sin mostrar esta UI
      if (mounted) {
        context.goNamed('prof_home');
      }
    } else {
      // Si no tiene permiso, quitamos el loader y mostramos nuestra UI para convencerlo
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.locationWhenInUse.request();

    if (status.isGranted) {
      if (mounted) context.goNamed('prof_home');
    } else if (status.isPermanentlyDenied) {
      // Si le dio a "Nunca permitir", el sistema operativo ya no nos deja mostrar la alerta.
      // Tenemos que mandarlo a la configuración de su celular.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.locationDeniedMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
        await openAppSettings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          ),
        ),
      );
    }

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
                // --- 1. ILUSTRACIÓN / ÍCONO ---
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: AppColors.primaryBlue,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 40),

                // --- 2. TEXTOS PERSUASIVOS ---
                const Text(
                  AppStrings.locationTitle,
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
                  AppStrings.locationSubtitle,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textGray,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),

                // --- 3. BOTONES DE ACCIÓN ---
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _requestPermission,
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
                const SizedBox(height: 16),

                // Plan B: Si el usuario es terco y no quiere dar su ubicación GPS
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text(AppStrings.locationDeniedTitle),
                        content: const Text(AppStrings.locationDeniedSubtitle),
                        actions: [
                          TextButton(
                            onPressed: () => context.pop(),
                            child: const Text(AppStrings.understandBtn),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text(
                    AppStrings.locationWhyRequired,
                    style: TextStyle(
                      color: AppColors.textGray,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
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
