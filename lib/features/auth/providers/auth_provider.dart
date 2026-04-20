import 'package:app_incide/core/network/api_client.dart';
import 'package:app_incide/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:app_incide/features/auth/domain/repositories/auth_repository.dart';
import 'package:app_incide/features/auth/domain/repositories/network_auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_incide/core/constants/app_keys.dart';

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
  final bool isInitialized; // INDICA SI YA TERMINÓ EL SPLASH
  final bool isAuthenticated;
  final String? role; // 'cliente' o 'proveedor'
  final String? profileStatus; // 'aceptado', 'pendiente', 'rechazado' o null
  final bool hasLocationPermission;

  AuthState({
    this.isLoading = false,
    this.isInitialized = false,
    this.isAuthenticated = false,
    this.role,
    this.profileStatus,
    this.hasLocationPermission = false,
  });

  /// Crea una nueva copia del estado modificando solo las variables indicadas.
  /// Requerido por Riverpod para garantizar la inmutabilidad.
  AuthState copyWith({
    bool? isLoading,
    bool? isInitialized,
    bool? isAuthenticated,
    String? role,
    String? profileStatus,
    bool? hasLocationPermission,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
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
// 1. Un simple booleano para controlar el modo de desarrollo
// Cambia esto a 'false' cuando el backend de C# esté listo para probar
final useMocksProvider = Provider<bool>((ref) => true);
// 2. El proveedor del repositorio que consumirá el resto de la app
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final useMocks = ref.watch(useMocksProvider);

  if (useMocks) {
    // Aquí devuelves tu MockAuthRepository actual que ya tenías
    return MockAuthRepository();
  } else {
    // Inyectamos el ApiClient único (Singleton) que configuramos con Dio
    return NetworkAuthRepository(ApiClient().dio);
  }
});

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
    return AuthState();
  }

  /// Carga inicial del estado desde almacenamiento local
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppKeys.token);
      final role = prefs.getString(AppKeys.role);
      final status = prefs.getString(AppKeys.profileStatus) ?? 'pendiente';

      if (token != null && token.isNotEmpty) {
        final PermissionStatus locationStatus =
            await Permission.locationWhenInUse.status;
        final bool hasLocation = locationStatus.isGranted;

        state = state.copyWith(
          isInitialized: true,
          isAuthenticated: true,
          role: role,
          profileStatus: status,
          hasLocationPermission: hasLocation,
        );
      } else {
        // DESPIERTA AL ENRUTADOR INCLUSO SI NO HAY SESIÓN
        state = state.copyWith(isInitialized: true);
      }
    } catch (e) {
      // Salida de emergencia para que la app no se quede congelada en el Splash
      state = state.copyWith(isInitialized: true, isAuthenticated: false);
    }
  }

  /// Procesa el inicio de sesión y actualiza el estado global de la aplicación.
  Future<void> login(String email, String password, String role) async {
    state = state.copyWith(isLoading: true); // Encendemos la ruedita de carga

    try {
      final repository = ref.read(authRepositoryProvider);

      final responseData = await repository.login(email, password, role);

      final String realToken = responseData['token'];
      final String serverRole = responseData['role'];
      final String userStatus = responseData['status'];

      // --- INTEGRACIÓN LOCAL SHAREDPREFERENCES ---
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppKeys.token, realToken);
      await prefs.setString(AppKeys.role, serverRole);
      await prefs.setString(AppKeys.profileStatus, userStatus);

      // Actualizamos el estado de memoria global (Riverpod)
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        role: serverRole,
        profileStatus: userStatus,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  /// Cierra la sesión activa del usuario limpiando disco y RAM simultáneamente.
  Future<void> logout() async {
    // 1. Limpiamos disco (SharedPreferences)
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppKeys.token);
    await prefs.remove(AppKeys.role);
    await prefs.remove(AppKeys.profileStatus);

    // 2. Limpiamos RAM (Riverpod). Resetea todo a falso y nulo, pateándolo al login
    state = AuthState();
  }

  /// Registra que el proveedor ha otorgado los permisos del sistema operativo.
  void grantLocation() {
    state = state.copyWith(hasLocationPermission: true);
  }
}
