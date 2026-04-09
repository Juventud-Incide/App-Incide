import 'package:flutter_riverpod/flutter_riverpod.dart';

// ==========================================
// 1. EL ESTADO INMUTABLE (La Memoria)
// ==========================================
/// Representa una "fotografía" inmutable de la sesión actual del usuario.
///
/// Agrupa múltiples variables (carga, sesión, rol, permisos) en un solo
/// objeto. Esto garantiza que Riverpod y GoRouter evalúen todas las condiciones
/// al mismo tiempo, evitando estados inconsistentes o condiciones de carrera en la UI.
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? role; // 'cliente' o 'proveedor'
  final String? profileStatus; // 'aceptado', 'pendiente', 'rechazado' o null
  final bool hasLocationPermission;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.role,
    this.profileStatus,
    this.hasLocationPermission = false,
  });

  /// Crea una nueva copia del estado modificando solo las variables indicadas.
  /// Requerido por Riverpod para garantizar la inmutabilidad.
  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? role,
    String? profileStatus,
    bool? hasLocationPermission,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      role: role ?? this.role,
      profileStatus: profileStatus ?? this.profileStatus,
      hasLocationPermission:
          hasLocationPermission ?? this.hasLocationPermission,
    );
  }
}

// ==========================================
// 2. EL REPOSITORIO (Simulador de Backend)
// ==========================================
final authRepositoryProvider = Provider((ref) => MockAuthRepository());

/// Capa de acceso a datos para la autenticación (Patrón Repositorio).
///
/// Aísla la lógica de red (API/Firebase) del manejador de estado.
/// Actualmente utiliza datos en duro para simular respuestas del servidor
/// y permitir el desarrollo Frontend sin bloqueos.
class MockAuthRepository {
  // Ahora pedimos el rol intentado para simular la separación de apps
  /// Ejecuta la petición HTTP de inicio de sesión.
  Future<String> login(
    String email,
    String password,
    String requestedRole,
  ) async {
    // TODO: (BACKEND) - Reemplazar la simulación con el SDK de Firebase Auth o API PaaS.
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
/// Proveedor global expuesto a la UI para leer o modificar la sesión.
final authControllerProvider = NotifierProvider<AuthController, AuthState>(() {
  return AuthController();
});

/// Controlador global del estado de autenticación (Cerebro de la sesión).
///
/// Gestiona la lógica de negocio. Al heredar de [Notifier], cualquier
/// reasignación a la variable `state` notificará automáticamente a todos los
/// listeners (incluyendo el RouterNotifier, provocando navegación automática).
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    // TODO: (BACKEND) - Al iniciar la app, revisar SharedPreferences/SecureStorage
    // para ver si ya había un token guardado y restaurar la sesión automáticamente.
    return AuthState();
  }

  /// Procesa el inicio de sesión y actualiza el estado global de la aplicación.
  ///
  /// Enciende el indicador de carga en la UI y delega la validación al repositorio.
  /// Si tiene éxito, marca al usuario como autenticado, lo que dispara las
  /// reglas de [GoRouter] para expulsarlo del Login.
  ///
  /// Parámetros:
  /// - [email]: Correo capturado en el formulario.
  /// - [password]: Contraseña en texto plano.
  /// - [role]: Requerido. Define el flujo ('proveedor' o 'cliente').
  ///
  /// Lanza una [Exception] limpiada si las credenciales fallan, la cual
  /// debe ser capturada por la UI para mostrar un SnackBar.
  Future<void> login(String email, String password, String role) async {
    state = state.copyWith(isLoading: true); // Encendemos la ruedita de carga

    try {
      final repository = ref.read(authRepositoryProvider);
      final resultStatus = await repository.login(email, password, role);

      // TODO: (BACKEND) - Guardar el token JWT en almacenamiento local

      // Actualizamos el estado.
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        role: role,
        profileStatus: resultStatus, // 'aceptado', 'pendiente' o 'rechazado'
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  /// Cierra la sesión activa del usuario.
  ///
  /// Reemplaza el estado actual por un [AuthState] vacío. Esto provoca
  /// inmediatamente que GoRouter redirija al usuario a la pantalla de Roles.
  void logout() {
    // TODO: (BACKEND) - Eliminar tokens JWT del almacenamiento local
    state =
        AuthState(); // Esto resetea todo a falso y nulo, pateándolo al login
  }

  /// Registra que el proveedor ha otorgado los permisos del sistema operativo.
  ///
  /// Al actualizarse a true, cumple con la última restricción del Router
  /// para permitir el acceso a `/prof-home`.
  void grantLocation() {
    // TODO: (BACKEND) - Sincronizar en base de datos que el proveedor aceptó términos/permisos
    state = state.copyWith(hasLocationPermission: true);
  }
}
