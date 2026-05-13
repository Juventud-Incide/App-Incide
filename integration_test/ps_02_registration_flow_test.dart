import 'package:app_incide/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:app_incide/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('PS-02: Flujo completo de registro hasta solicitud recibida', (
    tester,
  ) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // ==========================================
    // 1. SPLASH -> SELECCIÓN DE ROL -> LOGIN -> REGISTRO
    // ==========================================
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

    // NOTA: Ajusta este texto al botón exacto que lleva al registro en tu Login
    final registerLink = find.byKey(const Key('btn_go_to_register'));
    await tester.tap(registerLink);
    await tester.pump();
    await Future.delayed(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // ==========================================
    // 2. PASO 1: DATOS PERSONALES Y LEGALES
    // ==========================================
    // Función auxiliar para no repetir código al buscar los campos de texto
    Future<void> fillCustomField(String keyName, String textToEnter) async {
      final customInput = find.byKey(Key(keyName));
      // Hacemos scroll si el campo está oculto por el teclado o muy abajo
      await tester.ensureVisible(customInput);
      final realField = find.descendant(
        of: customInput,
        matching: find.byType(TextFormField),
      );
      await tester.enterText(realField, textToEnter);
    }

    // Llenamos el formulario (Asegúrate de poner estas llaves en tus CustomInputField)
    await fillCustomField('register_name_input', 'Juan');
    await fillCustomField('register_last_name_input', 'Pérez');
    await fillCustomField('register_email_input', 'revision@incide.com');
    await fillCustomField('register_phone_input', '6621234567');
    await fillCustomField('register_password_input', '12345678');
    await fillCustomField('register_curp_input', 'PEPJ900101HSRRRN01');
    await fillCustomField('register_rfc_input', 'PEPJ900101XYZ');

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // Checkbox de Términos y Condiciones
    final termsCheckbox = find.byKey(const Key('register_terms_checkbox'));
    await tester.ensureVisible(termsCheckbox);
    await tester.tap(termsCheckbox);
    await tester.pumpAndSettle();

    // Botón Siguiente
    final nextButton1 = find.byKey(const Key('register_continue_button'));
    await tester.ensureVisible(nextButton1);
    await tester.tap(nextButton1);
    await tester.pumpAndSettle(const Duration(seconds: 1)); // Transición a OTP

    // ==========================================
    // 3. PASO 2: VERIFICACIÓN OTP
    // ==========================================
    // NOTA: Si usas una librería como 'pinput', a veces con escribir en el primer
    // campo se llenan todos. Aquí asumo que son 4 campos separados.
    await tester.enterText(find.byKey(const Key('otp_box_1')), '1');
    await tester.enterText(find.byKey(const Key('otp_box_2')), '2');
    await tester.enterText(find.byKey(const Key('otp_box_3')), '3');
    await tester.enterText(find.byKey(const Key('otp_box_4')), '4');

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final nextButton2 = find.byKey(const Key('otp_verify_button'));
    await tester.tap(nextButton2);
    await tester.pumpAndSettle(
      const Duration(seconds: 1),
    ); // Transición a Info Profesional

    // ==========================================
    // 4. PASO 3: INFORMACIÓN PROFESIONAL
    // ==========================================
    // EL TRUCO DEL DROPDOWN:
    // 1. Tocar el dropdown para que se despliegue el menú
    final dropdown = find.byKey(const Key('register_profession_dropdown'));
    await tester.ensureVisible(dropdown);
    await tester.tap(dropdown);
    await tester.pumpAndSettle(); // Espera la animación del menú bajando

    // 2. Tocar la opción deseada
    final dropdownItem = find.text('Carpintería').last;
    await tester.tap(dropdownItem);
    await tester.pumpAndSettle(); // Espera a que se cierre el menú

    // Llenamos el resto
    await fillCustomField('register_experience_input', '5');
    await fillCustomField('register_cedula_input', '12345678');
    await fillCustomField(
      'register_description_input',
      'Especialista en muebles a medida.',
    );

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    // Botón Finalizar Solicitud
    final submitButton = find.byKey(const Key('register_submit_button'));
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);

    // Esperamos a que la petición "Mock" termine y cambie a la pantalla de éxito
    await tester.pumpAndSettle(const Duration(seconds: 4));

    // ==========================================
    // 5. VERIFICACIÓN: PANTALLA FINAL
    // ==========================================
    // NOTA: Ajusta el texto para que coincida exactamente con tu diseño
    expect(
      find.text(AppStrings.submissionTitle),
      findsOneWidget,
      reason:
          'Debe llegar a la pantalla de validación en proceso tras finalizar',
    );
  });
}
