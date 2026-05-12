import 'package:app_incide/features/auth/domain/models/application_status.dart';
import 'package:app_incide/features/auth/screens/professional/prof_activated_screen.dart';
import 'package:app_incide/features/provider/chat/screens/chat_detail_screen.dart';
import 'package:app_incide/features/shared/widgets/custom_logout_button.dart';
import 'package:app_incide/features/provider/quotes/screens/prof_quotes_screen.dart';
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
import '../../features/auth/screens/professional/prof_forgot_password_screen.dart';
import '../../features/auth/screens/professional/prof_forgot_password_sent_screen.dart';
import '../../features/auth/screens/professional/prof_new_password_screen.dart';
import '../../features/location/screens/prof_location_permission_screen.dart';
import '../../features/location/screens/client_location_permission_screen.dart';

import '../../features/provider/dashboard/screens/prof_dashboard_shell.dart';
import '../../features/provider/dashboard/screens/prof_home_screen.dart';
import '../../features/provider/dashboard/screens/opportunity_detail_screen.dart';
import '../../features/provider/dashboard/models/opportunity_model.dart';
import '../../features/provider/quotes/models/quote_model.dart';
import '../../features/provider/quotes/screens/quote_detail_screen.dart';

import '../../features/client/home/screens/client_login_screen.dart';
import '../../features/client/home/screens/cliente_register_screen.dart';
import '../../features/client/home/screens/cliente_verif_correo.dart';
import '../../features/client/home/tabs/Home/client_home_screen.dart';
import '../../features/client/home/tabs/Cotizaciones/client_quoting_screen.dart';
import '../../features/client/home/screens/forgot_password_screen.dart';
import '../../features/client/home/screens/forgot_password_sent_screen.dart';
import '../../features/client/home/screens/reset_password_screen.dart';
import '../../features/client/home/tabs/Cotizaciones/cliente_quote_detail_screen.dart';
import '../../features/client/home/models/cotizacion_model.dart';
import '../../features/client/home/screens/chat/cliente_chat_screen.dart';
import '../../features/client/home/providers/home_providers.dart';
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
    _ref.listen(authControllerProvider, (_, _) {
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
        '/roles',
        '/prof-login',
        '/prof-register',
        '/prof-forgot-password',
        '/prof-forgot-password-sent',
        '/login-cliente',
        '/registro-cliente',
        '/verif-correo-cliente',
        '/forgot-password',
        '/forgot-password-sent',
        '/reset-password',
      ];
      final isGoingToPublicRoute = publicRoutes.contains(targetPath);

      // 3. LAS REGLAS DEL GUARDIA (Evaluadas en orden)

      // REGLA 0: El Despachador del Splash
      if (isGoingToSplash) {
        if (!isInitialized) return null;
        if (!isAuthenticated) return '/roles';

        if (role == 'cliente') return '/home-cliente';

        if (role == 'proveedor') {
          switch (status) {
            case 'pendiente':
              // Dependiendo de su fase exacta, lo mandamos a su reanudación
              switch (authState.applicationStatus) {
                case ApplicationStatus.activated:
                  return '/prof-activated';
                case ApplicationStatus.uploadingDocs:
                  return '/prof-approved';
                case ApplicationStatus.correctingDocs:
                  return '/prof-docs-revision';
                case ApplicationStatus.validatingDocs:
                case ApplicationStatus.pendingReview:
                case ApplicationStatus.interviewScheduled:
                default:
                  return '/prof-review-status';
              }
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

      // REGLA 1: Guardia de Usuarios NO Logueados
      if (!isAuthenticated) {
        if (!isGoingToPublicRoute) return '/roles';
        return null;
      }

      // REGLA 2: Guardia del Cliente
      if (role == 'cliente') {
        if (isGoingToPublicRoute ||
            targetPath.contains('prof') ||
            isGoingToLocationScreen) {
          return '/home-cliente';
        }
        return null;
      }

      // REGLA 3: Guardia del Proveedor (El Sistema de 3 Fases)
      if (role == 'proveedor') {
        // Fase 1: Filtro de Estatus (Revisión de Documentos)
        if (status == 'pendiente') {
          final subStatus = authState.applicationStatus;
          switch (subStatus) {
            case ApplicationStatus.activated:
              if (targetPath != '/prof-activated') return '/prof-activated';
              return null;

            case ApplicationStatus.uploadingDocs:
              final allowedDocs = [
                'prof-approved',
                '/prof-upload-docs',
                '/prof-docs-success',
                '/prof-docs-revision',
              ];
              if (!allowedDocs.contains(targetPath)) return '/prof-approved';
              return null;

            case ApplicationStatus.correctingDocs:
              final allowedDocs = ['/prof-docs-revision', '/prof-docs-success'];
              if (!allowedDocs.contains(targetPath)) {
                return '/prof-docs-revision';
              }
              return null;

            case ApplicationStatus.validatingDocs:
              final allowedValidating = [
                '/prof-docs-success',
                '/prof-review-status',
              ];
              if (!allowedValidating.contains(targetPath)) {
                return '/prof-review-status';
              }
              return null;

            case ApplicationStatus.pendingReview:
            case ApplicationStatus.interviewScheduled:
            default:
              // Solo tiene permitido estar en la sala de espera
              if (targetPath != '/prof-review-status') {
                return '/prof-review-status';
              }
              return null;
          }
        }

        if (status == 'rechazado') {
          if (targetPath != '/prof-rejected') return '/prof-rejected';
          return null;
        }

        // Fase 2: Filtro Estricto de Permisos GPS (Solo para usuarios 'aceptados')
        if (status == 'aceptado') {
          final isGoingToLocation = targetPath == '/location-permission';

          if (!hasLocationPermission) {
            if (!isGoingToLocation) return '/location-permission';
            return null; // Lo dejamos estar en la pantalla de permisos
          }

          // Si SÍ tiene permiso y trata de regresar a pantallas públicas o de ubicación,
          // lo mandamos a su Home.
          if (hasLocationPermission &&
              (isGoingToPublicRoute || isGoingToLocation)) {
            return '/prof-home';
          }

          // Fase 3: Muro de Separación de Roles
          if (targetPath.contains('client') || targetPath.contains('cliente')) {
            return '/prof-home';
          }
        }
      }

      // Si sobrevivió a todas las reglas sin ser redirigido, tiene paso libre.
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
          final Map<String, dynamic> formData =
              state.extra as Map<String, dynamic>? ?? {};
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
        path: '/prof-activated',
        name: 'prof_activated',
        builder: (context, state) => const ProfActivatedScreen(),
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
      GoRoute(
        path: '/prof-forgot-password',
        name: 'prof_forgot_password',
        builder: (context, state) => const ProfForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/prof-forgot-password-sent',
        name: 'prof_forgot_password_sent',
        builder: (context, state) {
          // 1. Recibimos el paquete como un Mapa
          final Map<String, dynamic> data =
              state.extra as Map<String, dynamic>? ?? {};

          // 2. Extraemos el texto específico usando su llave ('email')
          final String email = data['email'] as String? ?? '';

          return ProfForgotPasswordSentScreen(email: email);
        },
      ),
      GoRoute(
        path: '/prof-new-password',
        name: 'prof_new_password',
        builder: (context, state) => const ProfNewPasswordScreen(),
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
                builder: (context, state) => const ProfQuotesScreen(),
                routes: [
                  // <-- Rutas hijas de Cotizaciones
                  GoRoute(
                    path: 'detail', // La URL será /prof-quotes/detail
                    name: 'quote_detail',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final quote = state.extra as QuoteModel;
                      return QuoteDetailScreen(quote: quote);
                    },
                  ),
                  GoRoute(
                    path: '/chat-detail/:chatId',
                    name: 'chat_detail',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      // Extraemos si la cotización ya fue aceptada desde los parámetros
                      // Ej: context.pushNamed('chat_detail', extra: {'isAccepted': true});
                      final chatId = state.pathParameters['chatId'] ?? '';
                      final extra = state.extra as Map<String, dynamic>?;
                      final isAccepted = extra?['isAccepted'] ?? false;

                      return ChatDetailScreen(
                        chatId: chatId,
                        isAccepted: isAccepted,
                      );
                    },
                  ),
                ],
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Pantalla de Perfil en construcción'),
                        SizedBox(height: 24),
                        CustomLogoutButton(
                          text: 'Cerrar sesión (Prueba)',
                          variant: LogoutButtonVariant
                              .destructiveOutlined, // O la variante que prefieras
                        ),
                      ],
                    ),
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
        builder: (context, state) => const ClientLocationPermissionScreen(),
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
