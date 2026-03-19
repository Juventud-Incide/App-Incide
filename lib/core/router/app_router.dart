import 'package:go_router/go_router.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/roles/role_selection_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/login_screen.dart';
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
      GoRoute(
        path: '/registro',
        name: 'registro',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
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
