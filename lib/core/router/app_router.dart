import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app_incide/features/auth/providers/auth_provider.dart';

import '../../features/auth/splash_screen.dart';
import '../../features/roles/role_selection_screen.dart';

import '../../features/auth/screens/professional/prof_register_screen.dart';
import '../../features/auth/screens/professional/prof_login_screen.dart';
import '../../features/auth/screens/professional/prof_otp_screen.dart';
import '../../features/auth/screens/professional/prof_experience_screen.dart';
import '../../features/auth/screens/professional/prof_review_status_screen.dart';
import '../../features/auth/screens/professional/prof_success_screen.dart';
import '../../features/auth/screens/professional/prof_approved_screen.dart';
import '../../features/auth/screens/professional/prof_upload_docs_screen.dart';
import '../../features/auth/screens/professional/prof_docs_success_screen.dart';
import '../../features/auth/screens/professional/prof_rejected_screen.dart';
import '../../features/auth/screens/professional/prof_docs_revision_screen.dart';
import '../../features/location/screens/prof_location_permission_screen.dart';
import '../../features/location/screens/client_location_permission_screen.dart';

import '../../features/provider/dashboard/screens/prof_dashboard_shell.dart';
import '../../features/provider/dashboard/screens/prof_home_screen.dart';
import '../../features/provider/dashboard/screens/opportunity_detail_screen.dart';
import '../../features/provider/dashboard/models/opportunity_model.dart';

import '../../features/auth/client_login_screen.dart';
import '../../features/auth/cliente_register_screen.dart';
import '../../features/auth/cliente_verif_correo.dart';
import '../../features/client/home/screens/client_home_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/forgot_password_sent_screen.dart';
import '../../features/auth/reset_password_screen.dart';

// ==========================================
// 1. EL PUENTE ENTRE RIVERPOD Y GOROUTER
// ==========================================

/// Puente de reactividad para el enrutamiento.
///
/// GoRouter requiere un [Listenable] para saber cuándo debe reevaluar sus rutas.
/// Esta clase escucha los cambios del [authControllerProvider] (Riverpod) y
/// notifica a GoRouter automáticamente, eliminando la necesidad de usar
/// `context.go()` manualmente en los flujos de autenticación y permisos.
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    // Escuchamos el authControllerProvider. Cada vez que cambie, notificamos al Router
    _ref.listen(authControllerProvider, (_, __) {
      notifyListeners();
    });
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final _rootNavigatorKey = GlobalKey<NavigatorState>();

// ==========================================
// 2. EL ENRUTADOR REACTIVO
// ==========================================

/// Proveedor global de navegación de la aplicación (GoRouter).
///
/// Define el árbol de rutas y actúa como el **Guardia de Seguridad Global**.
/// En cada cambio de estado (o intento de navegación), ejecuta la función `redirect`
/// evaluando en orden estricto:
/// 1. Autenticación: ¿El usuario inició sesión?
/// 2. Zonas Públicas: Previene que usuarios logueados regresen al Login.
/// 3. Roles y Permisos (Muro de Separación):
///    - Obliga a los 'proveedores' a otorgar permisos de ubicación.
///    - Evita que los 'proveedores' accedan a rutas de 'clientes' y viceversa.
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: notifier, // Conectamos el puente aquí
    initialLocation: '/', // Cambia esto para probar diferentes pantallas

    redirect: (context, state) {
      // 1. EL ESTADO DEL USUARIO (Autenticación, Rol, Permisos)
      final authState = ref.read(authControllerProvider);
      final bool isInitialized = authState.isInitialized;
      final bool isAuthenticated = authState.isAuthenticated;
      final String? role = authState.role;
      final String? status = authState.profileStatus;
      final bool hasLocationPermission = authState.hasLocationPermission;

      // 2. ¿A DÓNDE QUIERE IR?
      final targetPath = state.matchedLocation;
      final isGoingToSplash = targetPath == '/';
      final isGoingToLocationScreen = targetPath == '/location-permission';

      // Rutas "Públicas" (no ocupan login)
      final publicRoutes = [
        '/',
        '/roles',
        '/prof-login',
        '/prof-register',
        /*'/prof-otp',
        '/prof-experience',
        '/prof-review-status',
        '/prof-success',
        '/prof-approved',
        '/prof-upload-docs',
        '/prof-docs-success',
        '/prof-rejected',
        '/prof-docs-revision',*/
        '/login-cliente',
        '/registro-cliente',
        '/verif-correo-cliente',
        '/forgot-password',
        '/forgot-password-sent',
        '/reset-password',
        /*'/client-location-permission',*/
      ];
      final isGoingToPublicRoute = publicRoutes.contains(targetPath);

      // 3. LAS REGLAS DEL GUARDIA (Evaluadas en orden)

      // Regla 0: Manejo del Splash Screen
      if (isGoingToSplash) {
        if (!isInitialized) {
          // Sigue corriendo la animación o cargando token de disco
          return null;
        }
        // Ya sabemos si tiene sesión o no
        if (isAuthenticated) {
          return role == 'cliente' ? '/home-cliente' : '/prof-home';
        } else {
          return '/roles';
        }
      }

      // Regla 1: USUARIO NO AUTENTICADO (El Cierre de Sesión)
      if (!isAuthenticated) {
        // Si intenta ir a una ruta pública (como /roles), déjalo. Si no, expúlsalo.
        return isGoingToPublicRoute ? null : '/roles';
      }

      // Regla 2: USUARIO AUTENTICADO intentando ir a zonas públicas (Login)
      if (isAuthenticated && isGoingToPublicRoute) {
        if (role == 'cliente') return '/home-cliente';

        if (role == 'proveedor') {
          // ¡LA CURA!: En lugar de mandarlos a todos a '/prof-home' a ciegas,
          // los enviamos directo a la pantalla que les toca.
          switch (status) {
            case 'pendiente':
              return '/prof-approved';
            case 'rechazado':
              return '/prof-rejected';
            case 'aceptado':
            default:
              return hasLocationPermission
                  ? '/prof-home'
                  : '/location-permission';
          }
        }
      }

      // Excepción para pruebas de frontend (si es necesario)
      // if (targetPath == '/home-cliente') return null;

      // Regla 3: MURO DE ESTADOS (Solo Proveedores)
      if (role == 'proveedor') {
        if (targetPath.contains('client') || targetPath.contains('cliente'))
          return '/prof-home';

        switch (status) {
          case 'pendiente':
            final allowedPendiente = [
              '/prof-approved',
              '/prof-upload-docs',
              '/prof-docs-success',
              '/prof-docs-revision',
            ];
            // Si intenta escapar hacia el Home u otro lado, lo regresamos a su flujo
            if (!allowedPendiente.contains(targetPath)) return '/prof-approved';
            return null;

          case 'rechazado':
            if (targetPath != '/prof-rejected') return '/prof-rejected';
            return null;

          case 'aceptado':
          default:
            if (!hasLocationPermission && !isGoingToLocationScreen)
              return '/location-permission';
            if (hasLocationPermission && isGoingToLocationScreen)
              return '/prof-home';
            return null;
        }
      }

      // Regla 4: MURO DE CLIENTES
      if (role == 'cliente') {
        if (targetPath.contains('prof') || isGoingToLocationScreen) {
          return '/home-cliente';
        }
      }

      // Si pasó todas las aduanas, déjalo continuar su camino
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/roles',
        name: 'roles',
        builder: (context, state) => const RoleSelectionScreen(),
      ),

      // ------------------------------------
      //  RUTAS DEL PROFESIONISTA
      // ------------------------------------
      GoRoute(
        path: '/prof-login',
        name: 'prof_login',
        builder: (context, state) => const ProfLoginScreen(),
      ),
      GoRoute(
        path: '/prof-register',
        name: 'prof_register',
        builder: (context, state) => const ProfRegisterScreen(),
      ),
      GoRoute(
        path: '/prof-otp',
        name: 'prof_otp',
        builder: (context, state) {
          // Extraemos los datos pasados desde la pantalla 1
          final Map<String, dynamic> formData =
              state.extra as Map<String, dynamic>? ?? {};
          // Le pasamos todo el paquete al OTP

          return ProfOtpScreen(formData: formData);
        },
      ),
      GoRoute(
        path: '/prof-experience',
        name: 'prof_experience',
        builder: (context, state) {
          // Extraemos TODO el mapa de datos que nos aventó el OTP
          final Map<String, dynamic> formData =
              state.extra as Map<String, dynamic>? ?? {};
          // Se lo damos a la pantalla final
          return ProfExperienceScreen(formData: formData);
        },
      ),
      GoRoute(
        path: '/prof-review-status',
        name: 'prof_review_status',
        builder: (context, state) => const ProfReviewStatusScreen(),
      ),
      GoRoute(
        path: '/prof-success',
        name: 'prof_success',
        builder: (context, state) => const ProfSuccessScreen(),
      ),
      GoRoute(
        path: '/prof-approved',
        name: 'prof_approved',
        builder: (context, state) => const ProfApprovedScreen(),
      ),
      GoRoute(
        path: '/prof-upload-docs',
        name: 'prof_upload_docs',
        builder: (context, state) => const ProfUploadDocsScreen(),
      ),
      GoRoute(
        path: '/prof-docs-success',
        name: 'prof_docs_success',
        builder: (context, state) => const ProfDocsSuccessScreen(),
      ),
      GoRoute(
        path: '/prof-rejected',
        name: 'prof_rejected',
        builder: (context, state) => const ProfRejectedScreen(),
      ),
      GoRoute(
        path: '/prof-docs-revision',
        name: 'prof_docs_revision',
        builder: (context, state) => const ProfDocsRevisionScreen(),
      ),
      GoRoute(
        path: '/location-permission',
        name: 'location_permission',
        builder: (context, state) => const ProfLocationPermissionScreen(),
      ),

      // --- DASHBOARD DEL PROFESIONISTA (SHELL ROUTE) ---
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ProfDashboardShell(navigationShell: navigationShell);
        },
        branches: [
          // RAMA 0: Inicio
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/prof-home',
                name: 'prof_home',
                builder: (context, state) => const ProfHomeScreen(),
                routes: [
                  // <-- Rutas hijas de Inicio
                  GoRoute(
                    path: 'detail', // La URL será /prof-home/detail
                    name: 'opportunity_detail',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final opportunity = state.extra as OpportunityModel;
                      return OpportunityDetailScreen(opportunity: opportunity);
                    },
                  ),
                ],
              ),
            ],
          ),
          // RAMA 1: Cotizaciones (Placeholder temporal)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/prof-quotes',
                name: 'prof_quotes',
                builder: (context, state) => const Scaffold(
                  body: Center(
                    child: Text('Pantalla de Cotizaciones en construcción'),
                  ),
                ),
              ),
            ],
          ),
          // RAMA 2: Billetera (Placeholder temporal)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/prof-wallet',
                name: 'prof_wallet',
                builder: (context, state) => const Scaffold(
                  body: Center(
                    child: Text('Pantalla de Billetera en construcción'),
                  ),
                ),
              ),
            ],
          ),
          // RAMA 3: Perfil (Placeholder temporal)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/prof-profile',
                name: 'prof_profile',
                builder: (context, state) => const Scaffold(
                  body: Center(
                    child: Text('Pantalla de Perfil en construcción'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      // ------------------------------------
      //  RUTAS DEL CLIENTE
      // ------------------------------------
      GoRoute(
        path: '/login-cliente',
        name: 'login-cliente',
        builder: (context, state) => const ClientLoginScreen(),
      ),
      GoRoute(
        path: '/registro-cliente',
        name: 'registro-cliente',
        builder: (context, state) => const ClienteRegisterScreen(),
      ),
      GoRoute(
        path: '/verif-correo-cliente',
        name: 'verif-correo-cliente',
        builder: (context, state) {
          final Map<String, dynamic> formData =
              state.extra as Map<String, dynamic>? ?? {};
          return ClienteVerifCorreoScreen(formData: formData);
        },
      ),
      // TODO: Agregar GoRoute para '/cliente-home' aquí en el futuro
      GoRoute(
        path: '/client-location-permission',
        name: 'client_location_permission',
        builder: (context, state) => const ClientLocationPermissionScreen(),
      ),
      GoRoute(
        path: '/home-cliente',
        name: 'home-cliente',
        builder: (context, state) => const ClientHomeScreen(),
      ),

      // ------------------------------------
      //  RUTAS DE RECUPERACIÓN DE CONTRASEÑA
      // ------------------------------------
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/forgot-password-sent',
        name: 'forgot-password-sent',
        builder: (context, state) {
          final Map<String, dynamic> data =
              state.extra as Map<String, dynamic>? ?? {};
          return ForgotPasswordSentScreen(data: data);
        },
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) {
          final String token = state.uri.queryParameters['token'] ?? '';
          return ResetPasswordScreen(token: token);
        },
      ),
    ],
  );
});
