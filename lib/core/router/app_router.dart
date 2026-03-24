import 'package:go_router/go_router.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/roles/role_selection_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/client_login_screen.dart';
// TODO: Descomentar cuando el dev termine la pantalla de registro de cliente
// import '../../features/auth/cliente_register_screen.dart';

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
        // TODO: Restaurar la llamada a ClienteRegisterScreen() cuando el archivo deje de estar vacío
        // builder: (context, state) => const ClienteRegisterScreen(),
      ),
    ],
  );
}
