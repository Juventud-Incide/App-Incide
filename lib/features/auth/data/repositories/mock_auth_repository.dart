import 'package:app_incide/features/auth/domain/repositories/auth_repository.dart';

/// Capa de acceso a datos para la autenticación (Patrón Repositorio).
///
/// Aísla la lógica de red (API/Firebase) del manejador de estado.
/// Actualmente utiliza datos en duro para simular respuestas del servidor
/// y permitir el desarrollo Frontend sin bloqueos.
class MockAuthRepository implements AuthRepository {
  // Ahora pedimos el rol intentado para simular la separación de apps
  /// Ejecuta la petición HTTP de inicio de sesión.
  @override
  Future<Map<String, dynamic>> login(
    String email,
    String password,
    String requestedRole,
  ) async {
    // TODO: (BACKEND) - Reemplazar la simulación con el SDK de Firebase Auth o API PaaS.
    await Future.delayed(const Duration(seconds: 2));

    // Casos de prueba:

    // --- CREDENCIAL EXCLUSIVA PARA CLIENTES ---
    if (email == 'cliente@correo.com' && password == 'cliente123') {
      return {
        'token': 'mock_token_cliente_123',
        'role': 'cliente',
        'status': 'aceptado',
      };
    }
    // --- CREDENCIALES GENERALES / PROFESIONISTAS ---
    else if (email == 'admin@correo.com' && password == '12345678') {
      return {
        'token': 'mock_token_admin_999',
        'role': 'proveedor',
        'status': 'aceptado',
      };
    } else if (email == 'espera@correo.com') {
      return {
        'token': 'mock_token_espera_777',
        'role': requestedRole,
        'status': 'pendiente',
      };
    } else if (email == 'rechazado@correo.com') {
      return {
        'token': 'mock_token_rechazado_000',
        'role': requestedRole,
        'status': 'rechazado',
      };
    } else {
      throw Exception('Correo o contraseña incorrectos');
    }
  }
}
