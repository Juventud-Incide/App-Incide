import 'package:app_incide/core/constants/app_strings.dart';
import 'package:app_incide/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:app_incide/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('PS-01: El profesionista inicia sesión exitosamente y llega al Dashboard', (
    tester,
  ) async {
    // 1. Levantamos la app y esperamos a que pase el Splash
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // 2. Pantalla de selección de rol: El robot elige "Profesional"
    final roleButton = find.byKey(const Key('professional_role_card'));

    expect(
      roleButton,
      findsOneWidget,
      reason: 'Debe estar en la pantalla de selección de rol',
    );

    await tester.tap(roleButton);

    await tester.pump();
    await Future.delayed(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // 3. Pantalla de login: El robot encuentra los campos de correo y contraseña
    final emailField = find.byKey(const Key('login_email_input'));
    final passwordField = find.byKey(const Key('login_password_input'));
    final loginButton = find.byKey(const Key('login_submit_button'));

    // Comprobamos que el robot encontró los campos
    expect(
      emailField,
      findsOneWidget,
      reason: 'Debe encontrar el campo de correo',
    );
    expect(
      passwordField,
      findsOneWidget,
      reason: 'Debe encontrar el campo de contraseña',
    );
    expect(
      loginButton,
      findsOneWidget,
      reason: 'Debe encontrar el botón de iniciar sesión',
    );

    await tester.enterText(emailField, 'aceptado@incide.com');
    await tester.enterText(passwordField, '12345678');

    // Cerramos el teclado del emulador
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // El robot toca el botón de iniciar sesión
    await tester.tap(loginButton);

    // Esperamos a que pase la petición falsa (que tarda 2 segundos según tu Mock) y la animación del GoRouter
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // 4. Pantalla de Permisos de Ubicación: El robot debe ser redirigido aquí automáticamente
    final permissionScreenText = find.text(AppStrings.locationTitle);
    expect(
      permissionScreenText,
      findsOneWidget,
      reason: 'Debe ser interceptado por la pantalla de permisos',
    );

    // Inyectamos el permiso directamente en la memoria RAM para evadir el OS nativo.
    // Tomamos el contexto de la pantalla actual para acceder a Riverpod.
    final BuildContext context = tester.element(permissionScreenText);
    final container = ProviderScope.containerOf(context);

    // Llamamos al método que ya tenías programado en tu AuthController
    container.read(authControllerProvider.notifier).grantLocation();

    // GoRouter detectará el cambio (hasLocationPermission = true) y hará la redirección
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // 5. Pantalla de Dashboard: El robot debe ver el texto de bienvenida
    expect(
      find.text(AppStrings.welcomeText),
      findsOneWidget,
      reason: 'Debe haber llegado al Dashboard tras conceder permisos',
    );
  });
}
