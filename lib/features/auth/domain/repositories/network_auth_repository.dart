import 'package:dio/dio.dart';
import '../../domain/repositories/auth_repository.dart';

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

      // Si el backend responde con éxito, devolvemos el cuerpo de la respuesta
      return response.data;
    } on DioException catch (e) {
      // Manejo de errores específicos de red o del servidor (400, 401, 500)
      final errorMessage =
          e.response?.data['message'] ?? 'Error de conexión con el servidor';
      throw Exception(errorMessage);
    }
  }
}
