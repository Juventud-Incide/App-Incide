import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ==========================================
// 1. EL REPOSITORIO (Simulador de Backend)
// ==========================================
final authRepositoryProvider = Provider((ref) => MockAuthRepository());

class MockAuthRepository {
  Future<String> login(String email, String password) async {
    // Simulamos la espera de 2 segundos de internet
    await Future.delayed(const Duration(seconds: 2));

    // Casos de prueba:

    // --- CREDENCIAL EXCLUSIVA PARA CLIENTES ---
    if (email == 'cliente@correo.com' && password == 'cliente123') {
      return 'aceptado';
    } 
    // --- CREDENCIALES GENERALES / PROFESIONISTAS ---
    else if (email == 'admin@correo.com' && password == '12345678') {
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

class AuthState {
  final String? token;
  final String? role;

  AuthState({this.token, this.role});

  bool get isAuthenticated => token != null;
}

// 2. PROVEEDOR DE SESIÓN (Nuevo - Para el Router y Clientes)
final sessionProvider = NotifierProvider<SessionController, AuthState>(() {
  return SessionController();
});

class SessionController extends Notifier<AuthState> {
  @override
  AuthState build() => AuthState();

  void updateSession(String? token, String? role) {
    state = AuthState(token: token, role: role);
  }

  void clearSession() {
    state = AuthState();
  }
}

// 3. EL CONTROLADOR DE CARGA (Para compatibilidad con Profesionales)
final authControllerProvider = NotifierProvider<AuthController, bool>(() {
  return AuthController();
});

class AuthController extends Notifier<bool> {
  @override
  bool build() => false; // false = no está cargando

  /// Carga inicial del estado desde almacenamiento local
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final role = prefs.getString('user_role');

    if (token != null) {
      ref.read(sessionProvider.notifier).updateSession(token, role);
    }
  }

  Future<String?> login(String email, String password) async {
    state = true; // Empieza carga

    try {
      final repository = ref.read(authRepositoryProvider);
      final result = await repository.login(email, password);

      if (result == 'aceptado') {
        final role = email == 'cliente@correo.com' ? 'client' : 'professional';
        final token = 'dummy_token_${DateTime.now().millisecondsSinceEpoch}';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setString('user_role', role);

        // Actualizamos el proveedor de sesión
        ref.read(sessionProvider.notifier).updateSession(token, role);
      }

      state = false;
      return result;
    } catch (e) {
      state = false;
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_role');
    
    // Limpiamos sesión
    ref.read(sessionProvider.notifier).clearSession();
    state = false;
  }
}
