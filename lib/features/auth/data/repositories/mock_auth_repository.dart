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

    // --- CREDENCIALES GENERALES / PROFESIONISTAS ---
    if (requestedRole == 'proveedor') {
      // 1. Recién registrado
      if (email == 'revision@incide.com' && password == '12345678') {
        return {
          'token': 'tk_123',
          'role': 'proveedor',
          'status': 'pendiente',
          'pending_step': 'pendingReview',
        };
      }
      // 2. Ya le agendaron entrevista
      if (email == 'entrevista@incide.com' && password == '12345678') {
        return {
          'token': 'tk_124',
          'role': 'proveedor',
          'status': 'pendiente',
          'pending_step': 'interviewScheduled',
        };
      }
      // 3. Pasó la entrevista, debe subir documentos
      if (email == 'subirdocs@incide.com' && password == '12345678') {
        return {
          'token': 'tk_125',
          'role': 'proveedor',
          'status': 'pendiente',
          'pending_step': 'uploadingDocs',
        };
      }
      // 4. Subió documentos, esperando a que backoffice los valide
      if (email == 'validando@incide.com' && password == '12345678') {
        return {
          'token': 'tk_126',
          'role': 'proveedor',
          'status': 'pendiente',
          'pending_step': 'validatingDocs',
        };
      }
      // 5. Backoffice lo activó (Transición final)
      if (email == 'activado@incide.com' && password == '12345678') {
        return {
          'token': 'tk_127',
          'role': 'proveedor',
          'status': 'pendiente',
          'pending_step': 'activated',
        };
      }
      // 6. Cuenta 100% libre y aceptada (El usuario normal)
      if (email == 'aceptado@incide.com' && password == '12345678') {
        return {'token': 'tk_128', 'role': 'proveedor', 'status': 'aceptado'};
      }
      // 7. Cuenta rechazada
      if (email == 'rechazado@incide.com' && password == '12345678') {
        return {'token': 'tk_129', 'role': 'proveedor', 'status': 'rechazado'};
      }
    }

    // --- CREDENCIAL EXCLUSIVA PARA CLIENTES ---
    if (email == 'cliente@correo.com' && password == 'cliente123') {
      return {
        'token': 'mock_token_cliente_123',
        'role': 'cliente',
        'status': 'aceptado',
      };
    } else {
      throw Exception('Correo o contraseña incorrectos');
    }
  }
}
