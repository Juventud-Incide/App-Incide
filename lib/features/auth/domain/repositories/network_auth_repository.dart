import 'package:dio/dio.dart';
import 'auth_repository.dart';

/// Implementación real que se conecta al servidor de C# mediante Dio.
class NetworkAuthRepository implements AuthRepository {
  final Dio _dio;

  NetworkAuthRepository(this._dio);

  @override
  Future<Map<String, dynamic>> login(
    String email,
    String password,
    String role,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password, 'role': role},
      );

      // Extrae la data del backend
      final data = response.data;
      final user = data['user'];

      // Traduce el rol de C# al de Flutter
      // C# envía "Provider", Flutter espera "proveedor"
      String serverRole = 'proveedor';
      if (user != null && user['userRole'] != null) {
        serverRole = user['userRole'].toString().toLowerCase() == 'provider'
            ? 'proveedor'
            : 'cliente';
      }

      // Manejo de variables faltantes
      // Como el backend aún no envía 'status' ni 'pendingStep',
      // inyectamos valores por defecto seguros para que el GoRouter no explote.
      // TODO: (BACKEND) - Solicitar al equipo que incluyan el estatus de la cuenta en el DTO de Login.
      String mainStatus = user?['status'] ?? 'pendiente';
      String pendingStep = 'pendingReview';

      // Extraemos el estatus del proveedor que viene de C# (Puede ser Int o String)
      final dynamic rawProviderStatus = user?['providerStatus'];

      if (rawProviderStatus != null) {
        String statusStr = rawProviderStatus.toString();

        switch (statusStr) {
          case '0':
          case 'Registered':
            mainStatus = 'pendiente';
            pendingStep = 'pendingReview';
            break;
          case '1':
          case 'InterviewPending':
            mainStatus = 'pendiente';
            pendingStep = 'interviewScheduled';
            break;
          case '2':
          case 'InterviewApproved':
            mainStatus = 'pendiente';
            pendingStep = 'uploadingDocs';
            break;
          case '3':
          case 'AffiliationPending':
            mainStatus = 'pendiente';
            pendingStep = 'validatingDocs';
            break;
          case '4':
          case 'Affiliated':
            mainStatus = 'aceptado';
            pendingStep = 'activated';
            break;
          case '5':
          case 'Rejected':
            mainStatus = 'rechazado';
            break;
        }
      }

      // Retornamos el contrato
      return {
        'token': data['token'],
        'role': serverRole,
        'status': mainStatus,
        'pending_step': pendingStep,
      };
    } on DioException catch (e) {
      // 1. Verificamos si el servidor respondió con un error 401, 400, etc.
      if (e.response != null) {
        final data = e.response!.data;

        // 2. Si el backend mandó un String crudo (tu caso actual)
        if (data is String) {
          throw data; // Lanza "Credenciales Invalidas." directo a la UI
        }

        // 3. Si el backend mandó un JSON estructurado
        if (data is Map<String, dynamic>) {
          throw data['message'] ?? data['error'] ?? 'Error de autenticación';
        }
      }

      throw 'Error de conexión con el servidor. Verifica tu red.';
    }
  }

  @override
  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    required String phoneNumber,
    required String role,
  }) async {
    try {
      // Mapeo de Rol: Flutter (String) -> C# (int)
      // TODO: Confirmar con el equipo si 0 es Provider o Client.
      // Si el ejemplo de Swagger dice 0, probablemente sea el rol por defecto.
      final int roleValue = (role == 'proveedor') ? 3 : 2;

      await _dio.post(
        '/auth/register',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
          'phoneNumber': phoneNumber,
          'userRole': roleValue,
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
