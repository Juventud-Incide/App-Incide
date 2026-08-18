import 'package:incide_core/core/network/api_client.dart';
import 'package:incide_core/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:incide_core/features/auth/domain/repositories/auth_repository.dart';
import 'package:incide_core/features/auth/domain/repositories/network_auth_repository.dart';
import 'package:incide_core/features/auth/domain/models/application_status.dart';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:incide_core/core/constants/app_keys.dart';

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
  final ApplicationStatus? applicationStatus;

  AuthState({
    this.isLoading = false,
    this.isInitialized = false,
    this.isAuthenticated = false,
    this.role,
    this.profileStatus,
    this.hasLocationPermission = false,
    this.applicationStatus,
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
    ApplicationStatus? applicationStatus,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      role: role ?? this.role,
      profileStatus: profileStatus ?? this.profileStatus,
      hasLocationPermission:
          hasLocationPermission ?? this.hasLocationPermission,
      applicationStatus: applicationStatus ?? this.applicationStatus,
    );
  }
}

// ==========================================
// 2. EL REPOSITORIO (Simulador de Backend)
// ==========================================
// false = backend real (https://incide-dev.ddns.net/api)
// true  = datos mock locales (para desarrollo sin servidor)
final useMocksProvider = Provider<bool>((ref) => false);

// El proveedor del repositorio que consumirá el resto de la app
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final useMocks = ref.watch(useMocksProvider);

  if (useMocks) {
    return MockAuthRepository();
  } else {
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
  static const _storage = FlutterSecureStorage();

  @override
  AuthState build() {
    return AuthState();
  }

  // ── INITIALIZE ────────────────────────────────────────────────────────────

  /// Carga inicial del estado desde almacenamiento local.
  Future<void> initialize() async {
    try {
      ApiClient().onTokenExpired = () => logout();

      final token = await _storage.read(key: AppKeys.token);
      final role = await _storage.read(key: AppKeys.role);
      final status = await _storage.read(key: AppKeys.profileStatus) ?? 'pendiente';
      final appStatusStr = await _storage.read(key: AppKeys.applicationStatus);

      if (token != null && token.isNotEmpty) {
        // En web, permission_handler no está implementado para locationWhenInUse.
        // Usamos kIsWeb para saltarnos la verificación y asumir permiso concedido.
        final bool hasLocation;
        if (kIsWeb) {
          hasLocation = true; // Web usa el permiso del navegador nativo
        } else {
          final PermissionStatus locationStatus =
              await Permission.locationWhenInUse.status;
          hasLocation = locationStatus.isGranted;
        }

        state = state.copyWith(
          isInitialized: true,
          isAuthenticated: true,
          role: role,
          profileStatus: status,
          applicationStatus: parseAppStatus(appStatusStr),
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

  // ── LOGIN ─────────────────────────────────────────────────────────────────

  /// Procesa el inicio de sesión y actualiza el estado global de la aplicación.
  ///
  /// Compatible con el backend real (devuelve {user, token}) y el mock.
  /// El mock devuelve {token, role, status} directamente — lo manejamos en ambos casos.
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(authRepositoryProvider);
      final responseData = await repository.login(email, password);

      final String realToken = responseData['token'];

      // El backend real devuelve { user: { userRole: "Client" }, token: "..." }
      // El mock devuelve { token, role, status, pending_step } directamente
      String serverRole;
      String userStatus;
      String? pendingStep;

      if (responseData.containsKey('user')) {
        // ── Respuesta del backend real ───────────────────────────────────────
        final Map<String, dynamic> user = responseData['user'];
        serverRole = _parseUserRole(user['userRole']);
        // Los proveedores recién creados tienen Status = Registered (pendiente).
        // Leemos el status del backend si viene, sino inferimos por rol.
        final rawStatus = user['status'] as String?;
        if (rawStatus != null) {
          userStatus = _parseUserStatus(rawStatus);
        } else {
          // Fallback: clientes → aceptado, proveedores → pendiente
          userStatus = serverRole == 'proveedor' ? 'pendiente' : 'aceptado';
        }
        pendingStep = null;
      } else {
        // ── Respuesta del mock (formato antiguo) ───────────────────────────
        serverRole = responseData['role'] as String;
        userStatus = responseData['status'] as String;
        pendingStep = responseData['pending_step'] as String?;
      }

      // Guardamos la sesión en disco (persiste al cerrar la app)
      await _storage.write(key: AppKeys.token, value: realToken);
      await _storage.write(key: AppKeys.role, value: serverRole);
      await _storage.write(key: AppKeys.profileStatus, value: userStatus);
      if (pendingStep != null) {
        await _storage.write(key: AppKeys.applicationStatus, value: pendingStep);
      }

      // Actualizamos el estado en memoria (Riverpod → GoRouter reacciona)
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        role: serverRole,
        profileStatus: userStatus,
        applicationStatus: parseAppStatus(pendingStep),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  // ── REGISTER ──────────────────────────────────────────────────────────────

  /// Registra un nuevo usuario y lo deja autenticado automáticamente.
  ///
  /// Llamado desde [ClientAuthNotifier] (cliente) o desde la pantalla
  /// de experiencia del proveedor cuando se integre en el futuro.
  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    String? phoneNumber,
    required int userRole, // 2 = Client, 3 = Provider
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(authRepositoryProvider);
      final responseData = await repository.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        phoneNumber: phoneNumber,
        userRole: userRole,
      );

      final String token = responseData['token'];

      // El backend devuelve { user: { userRole: "Client", status: "Registered" }, token: "..." }
      final Map<String, dynamic> user = responseData['user'];
      final String roleMapped = _parseUserRole(user['userRole']);
      // Leemos el status del backend si viene; proveedores inician como 'pendiente'.
      final rawStatus = user['status'] as String?;
      final String statusMapped = rawStatus != null
          ? _parseUserStatus(rawStatus)
          : (roleMapped == 'proveedor' ? 'pendiente' : 'aceptado');

      // Guardamos la sesión en disco
      await _storage.write(key: AppKeys.token, value: token);
      await _storage.write(key: AppKeys.role, value: roleMapped);
      await _storage.write(key: AppKeys.profileStatus, value: statusMapped);

      // Actualizamos el estado en memoria (GoRouter navega al home automáticamente)
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        role: roleMapped,
        profileStatus: statusMapped,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      throw e.toString().replaceAll('Exception: ', '');
    }
  }

  // ── OTROS MÉTODOS ─────────────────────────────────────────────────────────

  /// Actualiza la fase de la aplicación del proveedor (Simula el cambio en backend)
  Future<void> updateApplicationStatus(ApplicationStatus newStatus) async {
    await _storage.write(key: AppKeys.applicationStatus, value: newStatus.name);
    state = state.copyWith(applicationStatus: newStatus);
  }

  /// Se ejecuta cuando el usuario presiona "Comenzar" en la pantalla de éxito.
  /// Cambia el estatus global del perfil, sacándolo del flujo "pendiente".
  Future<void> completeActivation() async {
    await _storage.write(key: AppKeys.profileStatus, value: 'aceptado');
    state = state.copyWith(profileStatus: 'aceptado');
  }

  /// Cierra la sesión activa del usuario limpiando disco y RAM simultáneamente.
  Future<void> logout() async {
    await _storage.delete(key: AppKeys.token);
    await _storage.delete(key: AppKeys.role);
    await _storage.delete(key: AppKeys.profileStatus);
    await _storage.delete(key: AppKeys.applicationStatus);
    state = AuthState();
  }

  /// Registra que el proveedor ha otorgado los permisos del sistema operativo.
  void grantLocation() {
    state = state.copyWith(hasLocationPermission: true);
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────

  /// Convierte el userRole del backend a la representación interna de la app.
  ///
  /// El backend puede devolver el rol como:
  /// - String: "Client" / "Provider" (usando enum.ToString() en C#)
  /// - Integer: 0 (None) / 1 (Admin) / 2 (Client) / 3 (Provider)
  ///
  /// Solo los roles de cliente y proveedor se traducen a la representación
  /// interna de la app. Valores desconocidos, `None` o `Admin` deben
  /// omitirse por defecto al flujo de proveedor.
  String _parseUserRole(dynamic rawRole) {
    if (rawRole == null) return '';

    if (rawRole is int) {
      switch (rawRole) {
        case 2:
          return 'cliente';
        case 3:
          return 'proveedor';
        default:
          return '';
      }
    }

    final String normalized = rawRole.toString().trim().toLowerCase();
    switch (normalized) {
      case '2':
      case 'client':
        return 'cliente';
      case '3':
      case 'provider':
        return 'proveedor';
      default:
        return '';
    }
  }

  /// Convierte el status del proveedor del backend al valor interno de la app.
  ///
  /// El backend C# puede devolver:
  /// - `"Registered"` → recién registrado, en espera de revisión → `'pendiente'`
  /// - `"Accepted"`   → aprobado por el admin                    → `'aceptado'`
  /// - `"Rejected"`   → rechazado por el admin                   → `'rechazado'`
  ///
  /// Para clientes, el backend no incluye este campo (devuelve null),
  /// por lo que el caller debe usar `'aceptado'` como fallback.
  String _parseUserStatus(String rawStatus) {
    switch (rawStatus.trim().toLowerCase()) {
      case 'accepted':
        return 'aceptado';
      case 'rejected':
        return 'rechazado';
      case 'registered':
      default:
        return 'pendiente';
    }
  }
}
