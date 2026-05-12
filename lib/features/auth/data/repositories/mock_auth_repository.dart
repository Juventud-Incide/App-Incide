import 'package:app_incide/features/auth/domain/repositories/auth_repository.dart';

/// Capa de acceso a datos para la autenticación (Patrón Repositorio).
///
/// Aísla la lógica de red (API/Firebase) del manejador de estado.
/// Actualmente utiliza datos en duro para simular respuestas del servidor
/// y permitir el desarrollo Frontend sin bloqueos.
class MockAuthRepository implements AuthRepository {
  static const Map<String, Map<String, dynamic>> _mockProveedorUsers = {
    'revision@incide.com': {
      'token': 'tk_123',
      'role': 'proveedor',
      'status': 'pendiente',
      'pending_step': 'pendingReview',
    },
    'entrevista@incide.com': {
      'token': 'tk_124',
      'role': 'proveedor',
      'status': 'pendiente',
      'pending_step': 'interviewScheduled',
    },
    'subirdocs@incide.com': {
      'token': 'tk_125',
      'role': 'proveedor',
      'status': 'pendiente',
      'pending_step': 'uploadingDocs',
    },
    'validando@incide.com': {
      'token': 'tk_126',
      'role': 'proveedor',
      'status': 'pendiente',
      'pending_step': 'validatingDocs',
    },
    'activado@incide.com': {
      'token': 'tk_127',
      'role': 'proveedor',
      'status': 'pendiente',
      'pending_step': 'activated',
    },
    'aceptado@incide.com': {
      'token': 'tk_128',
      'role': 'proveedor',
      'status': 'aceptado',
    },
    'rechazado@incide.com': {
      'token': 'tk_129',
      'role': 'proveedor',
      'status': 'rechazado',
    },
  };
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

    // --- CREDENCIALES GENERALES / PROFESIONISTAS ---
    // Agrupamos la validación del rol y la contraseña genérica en un solo IF
    if (requestedRole == 'proveedor' && password == '12345678') {
      // Buscamos directamente en el diccionario.
      // Si el correo no existe, devolverá null automáticamente sin usar IFs.
      final userResponse = _mockProveedorUsers[email];

      if (userResponse != null) {
        return userResponse;
      }
    }

    // --- CREDENCIAL EXCLUSIVA PARA CLIENTES ---
    if (requestedRole == 'cliente' &&
        email == 'cliente@correo.com' &&
        password == 'cliente123') {
      return {
        'token': 'mock_token_cliente_123',
        'role': 'cliente',
        'status': 'aceptado',
      };
    }

    // Si nada de lo anterior coincidió, lanzamos el error
    throw Exception('Correo o contraseña incorrectos');
  }
}
