import 'package:flutter_riverpod/flutter_riverpod.dart';

// ==========================================
// 1. EL ESTADO INMUTABLE (La Memoria)
// ==========================================
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? role; // 'cliente' o 'proveedor'
  final bool hasLocationPermission;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.role,
    this.hasLocationPermission = false,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? role,
    bool? hasLocationPermission,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      role: role ?? this.role,
      hasLocationPermission:
          hasLocationPermission ?? this.hasLocationPermission,
    );
  }
}

// ==========================================
// 2. EL REPOSITORIO (Simulador de Backend)
// ==========================================
final authRepositoryProvider = Provider((ref) => MockAuthRepository());

class MockAuthRepository {
  // Ahora pedimos el rol intentado para simular la separación de apps
  Future<String> login(
    String email,
    String password,
    String requestedRole,
  ) async {
    // TODO: (BACKEND) - Reemplazar con llamada real a Firebase Auth o API PaaS
    await Future.delayed(const Duration(seconds: 2));

    // Casos de prueba actualizados para soportar roles:
    if (email == 'admin@correo.com' && password == '12345678') {
      return 'aceptado';
    } else if (email == 'cliente@correo.com' && password == '12345678') {
      return 'aceptado'; // Cuenta de prueba para el cliente
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
// 3. EL CONTROLADOR DE ESTADO
// ==========================================
final authControllerProvider = NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    // TODO: (BACKEND) - Al iniciar la app, revisar SharedPreferences/SecureStorage
    // para ver si ya había un token guardado y restaurar la sesión automáticamente.
    return AuthState();
  }

  Future<String?> login(String email, String password, String role) async {
    state = state.copyWith(isLoading: true); // Encendemos la ruedita de carga

    try {
      final repository = ref.read(authRepositoryProvider);
      final result = await repository.login(email, password, role);

      if (result == 'aceptado') {
        // TODO: (BACKEND) - Guardar el token JWT y el rol en almacenamiento local
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          role: role, // Guardamos si entró como cliente o proveedor
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  void logout() {
    // TODO: (BACKEND) - Eliminar tokens del almacenamiento local
    state =
        AuthState(); // Esto resetea todo a falso y nulo, pateándolo al login
  }

  void grantLocation() {
    // TODO: (BACKEND) - Guardar en base de datos que el proveedor ya aceptó permisos
    state = state.copyWith(hasLocationPermission: true);
  }
}
