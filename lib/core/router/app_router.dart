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

import '../../features/auth/client_login_screen.dart';
import '../../features/auth/cliente_register_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/', // Cambia esto para probar diferentes pantallas
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
