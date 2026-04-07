import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/forgot_password_sent_screen.dart';
import '../../features/auth/reset_password_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/', // Cambia esto para probar diferentes pantallas
    redirect: (context, state) {
      // 1. EL ESTADO DEL USUARIO
      //lo cambie a false ALAN
      final bool isAuthenticated = false; // TODO: Cambiar por estado real
      final bool hasLocationPermission = false; // TODO: Cambiar por estado real

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
        '/prof-otp',
        '/login-cliente',
        '/registro-cliente',
        '/verif-correo-cliente',
        '/client-location-permission',
      ];
      final isGoingToPublicRoute = publicRoutes.contains(targetPath);

      // 3. LAS REGLAS DEL GUARDIA (Evaluadas en orden de importancia)

      // Regla 0: SIEMPRE deja que se muestre el Splash Screen al abrir la app
      if (isGoingToSplash) {
        return null;
      }

      // Regla A: Si NO está autenticado y quiere ir a una zona privada
      if (!isAuthenticated && !isGoingToPublicRoute) {
        return '/roles'; // Lo pateamos al login
      }

      // Regla B: Si ya hizo login, PERO intenta ir a las pantallas de login/registro otra vez
      if (isAuthenticated && isGoingToPublicRoute) {
        // Lo mandamos al dashboard o a pedir permisos
        return hasLocationPermission ? '/prof-home' : '/location-permission';
      }

      // Regla C: Si está autenticado, NO tiene ubicación, y no está en la pantalla de pedirla
      if (isAuthenticated &&
          !hasLocationPermission &&
          !isGoingToLocationScreen) {
        return '/location-permission';
      }

      // Si pasó todas las reglas, déjalo continuar su camino
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
      GoRoute(
        path: '/client-location-permission',
        name: 'client_location_permission',
        builder: (context, state) =>
            const ClientLocationPermissionScreen(),
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
      // La ruta acepta el token como query param para deep links:
      // Ejemplo: incide://reset-password?token=abc123xyz
      // TODO (Backend): Configurar deep link en AndroidManifest / Info.plist
      //                 apuntando a esta ruta con el esquema de la app.
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) {
          final String token =
              state.uri.queryParameters['token'] ?? '';
          return ResetPasswordScreen(token: token);
        },
      ),
    ],
  );
}
