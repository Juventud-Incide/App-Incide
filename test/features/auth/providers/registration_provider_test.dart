import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_incide/features/auth/providers/registration_auth_provider.dart';

void main() {
  test('PU-01: RegistrationNotifier acumula estado multi-step correctamente', () {
    // 1. PRECONDICIÓN: RegistrationState inicializado con valores vacíos por defecto [cite: 95]
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final registrationNotifier = container.read(registrationProvider.notifier);

    // Verificamos estado inicial
    var currentState = container.read(registrationProvider);
    expect(
      currentState.firstName,
      isEmpty,
      reason: 'El nombre debe iniciar vacío',
    );
    expect(
      currentState.categoryId,
      isNull,
      reason: 'La categoría debe iniciar nula',
    );

    // 2. EJECUCIÓN PASO 1: Datos Personales [cite: 95]
    // (Asumiendo que tu método se llama updatePersonalData o saveStepOne)
    registrationNotifier.updatePersonalData(
      firstName: 'Juan',
      lastName: 'Pérez',
      email: 'juan@test.com',
      phoneNumber: '6621234567',
      password: 'Password123!',
    );

    // 3. EJECUCIÓN PASO 3: Catálogos y Servicios [cite: 95]
    registrationNotifier.updateServices(2, [
      3,
      4,
    ]); // Categoría 2, Servicios 3 y 4

    // 4. RESULTADO ESPERADO: Leer state resultante [cite: 95]
    final finalState = container.read(registrationProvider);

    // state.firstName, state.email, state.categoryId y state.serviceIds deben reflejar los valores proporcionados [cite: 95]
    expect(finalState.firstName, 'Juan');
    expect(finalState.email, 'juan@test.com');
    expect(finalState.categoryId, 2);
    expect(finalState.serviceIds, [3, 4]);

    // isLoading debe permanecer en false [cite: 95]
    expect(finalState.isLoading, isFalse);
  });
}
