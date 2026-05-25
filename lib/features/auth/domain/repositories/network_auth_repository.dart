import 'package:dio/dio.dart';
import 'auth_repository.dart';

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
        data: {'email': email, 'password': password},
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

  @override
  Future<void> registerProvider({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
    required String curp,
    required String rfc,
    required int categoryId,
    required List<int> serviceIds,
    required int yearsOfExperience,
    required String professionalLicense,
    required String description,
  }) async {
    try {
      await _dio.post(
        '/auth/registerProvider',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'phoneNumber': phoneNumber,
          'curp': curp,
          'rfc': rfc,
          'categoryId': categoryId,
          'serviceIds': serviceIds,
          'yearsOfExperience': yearsOfExperience,
          'professionalLicense': professionalLicense,
          'description': description,
        },
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response!.data;
        if (errorData is String) throw errorData;
        if (errorData is Map<String, dynamic>) {
          throw errorData['message'] ?? 'Error al registrar la cuenta.';
        }
      }
      throw 'Error de conexión con el servidor.';
    }
  }

  @override
  Future<void> sendOtp(String phoneNumber) async {
    try {
      await _dio.post(
        '/auth/send-otp', // Ajusta esta ruta según tu Swagger/Backend
        data: {'phoneNumber': phoneNumber},
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response!.data;
        if (data is String) throw data;
        if (data is Map<String, dynamic>) {
          throw data['message'] ?? 'Error al enviar el código SMS.';
        }
      }
      throw 'Error de conexión. No se pudo solicitar el SMS.';
    }
  }

  @override
  Future<bool> verifyOtp(String phoneNumber, String otpCode) async {
    try {
      final response = await _dio.post(
        '/auth/verify-otp',
        data: {'phoneNumber': phoneNumber, 'otpCode': otpCode},
      );
      return response.data['success'];
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response!.data;
        if (data is String) throw data;
        if (data is Map<String, dynamic>) {
          throw data['message'] ?? 'Error al verificar el OTP.';
        }
      }
      throw 'Error de conexión con el servidor.';
    }
  }

  @override
  Future<void> resendOtp(String phoneNumber) async {
    try {
      await _dio.post('/auth/resend-otp', data: {'phoneNumber': phoneNumber});
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response!.data;
        if (data is String) throw data;
        if (data is Map<String, dynamic>) {
          throw data['message'] ?? 'Error al reenviar el código.';
        }
      }
      throw 'Error de conexión. No se pudo reenviar el SMS.';
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getServicesCatalog() async {
    try {
      final response = await _dio.get('/api/servicios');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      // Manejo de errores de Dio
      throw 'Error de conexión al cargar catálogo: ${e.message}';
    } catch (e) {
      throw 'Error inesperado al leer los servicios.';
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCategoriesCatalog() async {
    try {
      final response = await _dio.get('/api/categorias');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      // Manejo de errores de Dio
      throw 'Error de conexión al cargar categorías: ${e.message}';
    } catch (e) {
      throw 'Error inesperado al leer las categorías.';
    }
  }
}
