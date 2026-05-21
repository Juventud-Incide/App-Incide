import 'package:dio/dio.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implementación REAL del [AuthRepository] que se conecta al backend C#.
///
/// Usa [Dio] (inyectado desde [ApiClient]) para hacer las peticiones HTTP.
/// La baseUrl ya incluye `/api`, por lo que las rutas aquí son relativas:
/// `/auth/login`, `/auth/register`.
class NetworkAuthRepository implements AuthRepository {
  final Dio _dio;

  NetworkAuthRepository(this._dio);

  // ── LOGIN ─────────────────────────────────────────────────────────────────

  /// Llama a POST /api/auth/login
  ///
  /// El backend recibe solo { email, password }.
  /// El rol NO se envía — el backend lo lee del usuario en base de datos.
  ///
  /// Respuesta exitosa (200 OK):
  /// ```json
  /// { "user": { "id":1, "fullName":"Ana", "email":"...", "userRole":"Client" }, "token":"..." }
  /// ```
  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          // ⚠️ NO enviar 'role' — el backend C# no lo espera en LoginDTO
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final data = e.response?.data;
      final errorMessage = data is String
          ? data
          : (data?['message'] ?? 'Error de conexión con el servidor');
      throw Exception(errorMessage);
    }
  }

  // ── REGISTER ──────────────────────────────────────────────────────────────

  /// Llama a POST /api/auth/register
  ///
  /// El backend recibe el RegisterDTO de C# con los siguientes campos.
  /// [userRole]: 2 = Client, 3 = Provider.
  ///
  /// Respuesta exitosa (200 OK):
  /// ```json
  /// { "user": { "id":42, "fullName":"Ana García", "email":"...", "userRole":"Client" }, "token":"..." }
  /// ```
  @override
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    String? phoneNumber,
    required int userRole,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
          // Solo incluimos phoneNumber si el usuario lo escribió
          if (phoneNumber != null && phoneNumber.trim().isNotEmpty)
            'phoneNumber': phoneNumber.trim(),
          'userRole': userRole, // 2 = Client, 3 = Provider
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final data = e.response?.data;
      final errorMessage = data is String
          ? data
          : (data?['message'] ?? 'Error al registrarse. Intenta de nuevo.');
      throw Exception(errorMessage);
    }
  }
}
