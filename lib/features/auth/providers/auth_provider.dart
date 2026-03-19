import 'package:flutter_riverpod/flutter_riverpod.dart';

// ==========================================
// 1. EL REPOSITORIO (Simulador de Backend)
// ==========================================
final authRepositoryProvider = Provider((ref) => MockAuthRepository());

class MockAuthRepository {
  Future<String> login(String email, String password) async {
    // Simulamos la espera de 2 segundos de internet
    await Future.delayed(const Duration(seconds: 2));

    // Casos de prueba:
    if (email == 'admin@correo.com' && password == '123456') {
      return 'aceptado';
    } else if (email == 'espera@correo.com') {
      return 'pendiente';
    } else if (email == 'rechazado@correo.com') {
      return 'rechazado';
    } else {
      throw Exception('Correo o contraseña incorrectos');
    }
  }
}

// ==========================================
// 2. EL CONTROLADOR DE ESTADO (Sintaxis Moderna)
// ==========================================
// Usamos NotifierProvider en lugar de StateNotifierProvider
final authControllerProvider = NotifierProvider<AuthController, bool>(() {
  return AuthController();
});

// Usamos Notifier en lugar de StateNotifier
class AuthController extends Notifier<bool> {
  @override
  bool build() {
    // El método build define el estado inicial (false = no está cargando)
    return false;
  }

  Future<String?> login(String email, String password) async {
    state = true; // Encendemos la ruedita de carga en la UI

    try {
      // En la sintaxis moderna, usamos ref.read directamente adentro del Notifier
      final repository = ref.read(authRepositoryProvider);
      final result = await repository.login(email, password);

      state = false; // Apagamos la ruedita
      return result;
    } catch (e) {
      state = false; // Apagamos la ruedita aunque haya error
      throw e.toString().replaceAll('Exception: ', '');
    }
  }
}
