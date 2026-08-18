import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:incide_core/features/auth/providers/auth_provider.dart';
import 'package:incide_core/features/auth/splash_screen.dart';
import 'package:incide_core/features/auth/domain/models/application_status.dart';
import 'package:incide_core/features/auth/screens/professional/prof_register_screen.dart';
import 'package:incide_core/features/auth/screens/professional/prof_login_screen.dart';
import 'package:incide_core/features/auth/screens/professional/prof_otp_screen.dart';
import 'package:incide_core/features/auth/screens/professional/prof_experience_screen.dart';
import 'package:incide_core/features/auth/screens/professional/prof_review_status_screen.dart';
import 'package:incide_core/features/auth/screens/professional/prof_success_screen.dart';
import 'package:incide_core/features/auth/screens/professional/prof_approved_screen.dart';
import 'package:incide_core/features/auth/screens/professional/prof_upload_docs_screen.dart';
import 'package:incide_core/features/auth/screens/professional/prof_docs_success_screen.dart';
import 'package:incide_core/features/auth/screens/professional/prof_rejected_screen.dart';
import 'package:incide_core/features/auth/screens/professional/prof_activated_screen.dart';
import 'package:incide_core/features/auth/screens/professional/prof_docs_revision_screen.dart';
import 'package:incide_core/features/auth/screens/professional/prof_forgot_password_screen.dart';
import 'package:incide_core/features/auth/screens/professional/prof_forgot_password_sent_screen.dart';
import 'package:incide_core/features/auth/screens/professional/prof_new_password_screen.dart';
import 'package:incide_core/features/location/screens/prof_location_permission_screen.dart';

import 'package:incide_core/features/shared/widgets/custom_logout_button.dart';
import 'package:app_proveedor/features/provider/dashboard/screens/prof_dashboard_shell.dart';
import 'package:app_proveedor/features/provider/dashboard/screens/prof_home_screen.dart';
import 'package:app_proveedor/features/provider/dashboard/screens/opportunity_detail_screen.dart';
import 'package:app_proveedor/features/provider/dashboard/models/opportunity_model.dart';
import 'package:app_proveedor/features/provider/quotes/models/quote_model.dart';
import 'package:app_proveedor/features/provider/quotes/screens/prof_quotes_screen.dart';
import 'package:app_proveedor/features/provider/quotes/screens/quote_detail_screen.dart';
import 'package:app_proveedor/features/provider/chat/screens/chat_detail_screen.dart';
import 'package:app_proveedor/features/provider/wallet/screens/wallet_screen.dart';

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

final providerRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: notifier,
    initialLocation: '/',

    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final bool isInitialized = authState.isInitialized;
      final bool isAuthenticated = authState.isAuthenticated;
      final String? status = authState.profileStatus;
      final bool hasLocationPermission = authState.hasLocationPermission;

      final targetPath = state.matchedLocation;
      final isGoingToSplash = targetPath == '/';
      final isGoingToLocationScreen = targetPath == '/location-permission';

      final publicRoutes = [
        '/prof-login',
        '/prof-register',
        '/prof-otp',
        '/prof-experience',
        '/prof-success',
        '/prof-forgot-password',
        '/prof-forgot-password-sent',
        '/prof-new-password',
      ];
      final isGoingToPublicRoute = publicRoutes.contains(targetPath);

      if (isGoingToSplash) {
        if (!isInitialized) return null;
        if (!isAuthenticated) return '/prof-login';

        switch (status) {
          case 'pendiente':
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

      if (!isAuthenticated) {
        if (!isGoingToPublicRoute) return '/prof-login';
        return null;
      }

      // Proceso del Proveedor Autenticado
      if (status == 'pendiente') {
        final subStatus = authState.applicationStatus;
        switch (subStatus) {
          case ApplicationStatus.activated:
            if (targetPath != '/prof-activated') return '/prof-activated';
            return null;

          case ApplicationStatus.uploadingDocs:
            final allowedDocs = [
              '/prof-approved',
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

      if (status == 'aceptado') {
        final isGoingToLocation = targetPath == '/location-permission';

        if (!hasLocationPermission) {
          if (!isGoingToLocation) return '/location-permission';
          return null;
        }

        if (hasLocationPermission &&
            (isGoingToPublicRoute || isGoingToLocation)) {
          return '/prof-home';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
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
      GoRoute(
        path: '/prof-experience',
        name: 'prof_experience',
        builder: (context, state) => const ProfExperienceScreen(),
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
          final Map<String, dynamic> data =
              state.extra as Map<String, dynamic>? ?? {};
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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/prof-home',
                name: 'prof_home',
                builder: (context, state) => const ProfHomeScreen(),
                routes: [
                  GoRoute(
                    path: 'detail',
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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/prof-quotes',
                name: 'prof_quotes',
                builder: (context, state) => const ProfQuotesScreen(),
                routes: [
                  GoRoute(
                    path: 'detail',
                    name: 'quote_detail',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final quote = state.extra as QuoteModel;
                      return QuoteDetailScreen(quote: quote);
                    },
                  ),
                  GoRoute(
                    path: 'chat-detail/:chatId',
                    name: 'chat_detail',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/prof-wallet',
                name: 'prof_wallet',
                builder: (context, state) => const WalletScreen(),
              ),
            ],
          ),
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
                          text: 'Cerrar sesión',
                          variant: LogoutButtonVariant.destructiveOutlined,
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
    ],
  );
});
