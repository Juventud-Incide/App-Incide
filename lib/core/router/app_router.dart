import 'package:go_router/go_router.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/roles/role_selection_screen.dart';

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
    ],
  );
}
