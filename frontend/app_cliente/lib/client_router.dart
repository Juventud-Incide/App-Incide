import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:incide_core/features/auth/providers/auth_provider.dart';

import 'features/client/home/screens/client_login_screen.dart';
import 'features/client/welcome/screens/welcome_screen.dart';
import 'features/client/home/screens/cliente_register_screen.dart';
import 'features/client/home/screens/cliente_verif_correo.dart';
import 'features/client/home/tabs/Home/client_home_screen.dart';
import 'features/client/home/tabs/Cotizaciones/client_quoting_screen.dart';
import 'features/client/home/screens/forgot_password_screen.dart';
import 'features/client/home/screens/forgot_password_sent_screen.dart';
import 'features/client/home/screens/reset_password_screen.dart';
import 'features/client/home/tabs/Cotizaciones/cliente_quote_detail_screen.dart';
import 'features/client/home/models/cotizacion_model.dart';
import 'features/client/home/screens/chat/cliente_chat_screen.dart';
import 'features/client/home/providers/home_providers.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authControllerProvider, (_, _) {
      notifyListeners();
    });
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final clientRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: notifier,
    initialLocation: '/',

    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final bool isInitialized = authState.isInitialized;
      final bool isAuthenticated = authState.isAuthenticated;

      final targetPath = state.matchedLocation;
      final isGoingToWelcome = targetPath == '/';

      final publicRoutes = [
        '/login-cliente',
        '/registro-cliente',
        '/verif-correo-cliente',
        '/forgot-password',
        '/forgot-password-sent',
        '/reset-password',
      ];
      final isGoingToPublicRoute = publicRoutes.contains(targetPath);

      if (!isInitialized) {
        return isGoingToWelcome ? null : '/';
      }

      if (!isAuthenticated) {
        if (!isGoingToPublicRoute && !isGoingToWelcome) return '/login-cliente';
        return null;
      }

      // Si está autenticado
      if (isGoingToPublicRoute || isGoingToWelcome) {
        return '/home-cliente';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
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
        path: '/home-cliente',
        name: 'home-cliente',
        builder: (context, state) => const ClientHomeScreen(),
      ),
      GoRoute(
        path: '/cliente/cotizar/:categoryId',
        name: 'cliente-cotizar',
        builder: (context, state) {
          final categoryId = state.pathParameters['categoryId'] ?? '';
          return ClientQuotingScreen(categoryId: categoryId);
        },
      ),
      GoRoute(
        path: '/cliente/cotizacion/:cotizacionId',
        name: 'cliente-cotizacion-detalle',
        builder: (context, state) {
          final cotizacionId = state.pathParameters['cotizacionId'] ?? '';
          CotizacionModel? cotizacion;

          if (state.extra is CotizacionModel) {
            cotizacion = state.extra as CotizacionModel;
          } else {
            final allCotizaciones = ref.read(allCotizacionesProvider);
            try {
              cotizacion = allCotizaciones.firstWhere(
                (c) => c.id == cotizacionId,
              );
            } catch (_) {
              cotizacion = null;
            }
          }

          if (cotizacion == null || cotizacion.id != cotizacionId) {
            return const Scaffold(
              body: Center(child: Text('Error: Cotización no encontrada')),
            );
          }

          return ClienteQuoteDetailScreen(cotizacion: cotizacion);
        },
      ),
      GoRoute(
        path: '/cliente/chat/:cotizacionId',
        name: 'cliente-chat',
        builder: (context, state) {
          final cotizacionId = state.pathParameters['cotizacionId'] ?? '';
          CotizacionModel? cotizacion;

          if (state.extra is CotizacionModel) {
            cotizacion = state.extra as CotizacionModel;
          } else {
            final allCotizaciones = ref.read(allCotizacionesProvider);
            try {
              cotizacion = allCotizaciones.firstWhere(
                (c) => c.id == cotizacionId,
              );
            } catch (_) {
              cotizacion = null;
            }
          }

          if (cotizacion == null || cotizacion.id != cotizacionId) {
            return const Scaffold(
              body: Center(child: Text('Error: Cotización no encontrada')),
            );
          }

          return ClienteChatScreen(cotizacion: cotizacion);
        },
      ),
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
