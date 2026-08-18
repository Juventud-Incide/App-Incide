import 'package:incide_core/core/constants/app_strings.dart';
import 'package:incide_core/core/theme/app_colors.dart';
import 'package:incide_core/features/shared/widgets/custom_logout_button.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:incide_core/features/auth/providers/auth_provider.dart';

/// Pantalla de interceptación obligatoria para solicitar permisos de GPS.
///
/// Esta vista actúa como un "Muro de Contención" en el enrutador. Un proveedor
/// no puede acceder al Dashboard (`/prof-home`) sin antes otorgar estos permisos.
///
/// **Arquitectura Reactiva:** /// Esta pantalla no utiliza `context.go()` para salir. Su única responsabilidad
/// es interactuar con el SO (Sistema Operativo) y, en caso de éxito, notificar
/// al [authControllerProvider]. El GoRouter detecta ese cambio y extrae
/// al usuario automáticamente de esta pantalla.
class ProfLocationPermissionScreen extends ConsumerStatefulWidget {
  const ProfLocationPermissionScreen({super.key});

  @override
  ConsumerState<ProfLocationPermissionScreen> createState() =>
      _ProfLocationPermissionScreenState();
}

/// Estado de la pantalla. Implementa [WidgetsBindingObserver] para "escuchar"
/// cuando la aplicación pasa a segundo plano o regresa al primer plano.
class _ProfLocationPermissionScreenState
    extends ConsumerState<ProfLocationPermissionScreen>
    with WidgetsBindingObserver {
  /// Controla si se muestra un loader mientras verificamos los permisos en silencio.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Suscribimos esta pantalla para que escuche los eventos del ciclo de vida del SO.
    WidgetsBinding.instance.addObserver(this);
    _checkInitialPermission();
  }

  @override
  void dispose() {
    // LIMPIEZA: Es vital remover el observador para evitar Memory Leaks al destruir la vista.
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Detecta si el usuario minimizó la app (ej. para ir a los ajustes del celular)
  /// y acaba de regresar.
  ///
  /// Si el usuario regresa ([AppLifecycleState.resumed]), volvemos a evaluar
  /// si ya nos dio el permiso desde la configuración nativa de Android/iOS.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkInitialPermission();
    }
  }

  /// Verifica silenciosamente el estado actual del permiso de ubicación.
  ///
  /// Se ejecuta al cargar la pantalla por primera vez o al regresar de los ajustes.
  /// Si el permiso ya fue otorgado previamente, dispara el estado en Riverpod
  /// para saltarse la interfaz gráfica por completo.
  Future<void> _checkInitialPermission() async {
    // En web, permission_handler no está soportado para locationWhenInUse.
    // El navegador gestiona su propio permiso, por lo que asumimos concedido.
    if (kIsWeb) {
      if (mounted) ref.read(authControllerProvider.notifier).grantLocation();
      return;
    }

    final status = await Permission.locationWhenInUse.status;

    if (status.isGranted) {
      // Si ya tiene permiso, lo mandamos directo al Dashboard sin mostrar esta UI
      if (mounted) {
        // Disparador reactivo: GoRouter nos sacará de aquí.
        ref.read(authControllerProvider.notifier).grantLocation();
      }
    } else {
      // Si no tiene permiso, apagamos el loader para mostrar la UI persuasiva
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Lanza el diálogo nativo (Pop-up) del sistema operativo pidiendo acceso al GPS.
  Future<void> _requestPermission() async {
    // En web no se puede llamar a permission_handler — el navegador maneja
    // su propio flujo de permisos de ubicación de forma independiente.
    if (kIsWeb) {
      if (mounted) ref.read(authControllerProvider.notifier).grantLocation();
      return;
    }

    final status = await Permission.locationWhenInUse.request();

    if (status.isGranted) {
      if (mounted) ref.read(authControllerProvider.notifier).grantLocation();
    } else if (status.isPermanentlyDenied) {
      // Si el usuario marcó "No volver a preguntar", el SO bloquea nuestro pop-up.
      // La única solución es llevarlo a mano a la configuración de su dispositivo.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.locationDeniedMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
        // Abre la pantalla de ajustes nativa de INCIDE en Android/iOS
        await openAppSettings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // PopScope(canPop: false) bloquea el botón físico de retroceso de Android
      // para evitar que el usuario se salte este paso obligatorio.
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
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
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
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Plan B: Si el usuario es terco y rechaza el primer intento
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text(AppStrings.locationDeniedTitle),
                              content: const Text(
                                AppStrings.locationDeniedSubtitle,
                              ),
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

                      const CustomLogoutButton(
                        text: AppStrings.logoutBtn,
                        variant: LogoutButtonVariant.text,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
