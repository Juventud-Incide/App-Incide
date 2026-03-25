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

import '../../features/provider/dashboard/screens/prof_dashboard_shell.dart';
import '../../features/provider/dashboard/screens/prof_home_screen.dart';
import '../../features/provider/dashboard/screens/opportunity_detail_screen.dart';

import '../../features/auth/client_login_screen.dart';
import '../../features/auth/cliente_register_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation:
        '/prof-home', // Cambia esto para probar diferentes pantallas
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
                    builder: (context, state) =>
                        const OpportunityDetailScreen(),
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
    ],
  );
}
