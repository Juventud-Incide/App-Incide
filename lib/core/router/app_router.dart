import 'package:go_router/go_router.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/roles/role_selection_screen.dart';
import '../../features/auth/screens/professional/prof_register_screen.dart';
import '../../features/auth/screens/professional/prof_login_screen.dart';
import '../../features/auth/screens/professional/prof_otp_screen.dart';
import '../../features/auth/client_login_screen.dart';
import '../../features/auth/cliente_register_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
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
        builder: (context, state) => const ProfOtpScreen(),
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
