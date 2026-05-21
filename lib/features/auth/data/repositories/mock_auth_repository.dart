import 'package:app_incide/features/auth/domain/repositories/auth_repository.dart';

/// Implementación MOCK del [AuthRepository].
///
/// Simula las respuestas del backend de C# con datos en duro.
/// Permite desarrollar y probar el Frontend sin necesitar el servidor activo.
///
/// Activar/desactivar: cambia [useMocksProvider] en auth_provider.dart.
class MockAuthRepository implements AuthRepository {
  // ── LOGIN ─────────────────────────────────────────────────────────────────

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2)); // Simula latencia de red

    // Inferimos el rol por el dominio del email:
    // Los proveedores de prueba usan @incide.com, los clientes usan @correo.com
    final bool esProveedor = email.endsWith('@incide.com');

    // ── CREDENCIALES DE PRUEBA: PROVEEDOR ────────────────────────────────────
    if (esProveedor) {
      if (email == 'revision@incide.com' && password == '12345678') {
        return {
          'token': 'tk_123',
          'role': 'proveedor',
          'status': 'pendiente',
          'pending_step': 'pendingReview',
        };
      }
      if (email == 'entrevista@incide.com' && password == '12345678') {
        return {
          'token': 'tk_124',
          'role': 'proveedor',
          'status': 'pendiente',
          'pending_step': 'interviewScheduled',
        };
      }
      if (email == 'subirdocs@incide.com' && password == '12345678') {
        return {
          'token': 'tk_125',
          'role': 'proveedor',
          'status': 'pendiente',
          'pending_step': 'uploadingDocs',
        };
      }
      if (email == 'validando@incide.com' && password == '12345678') {
        return {
          'token': 'tk_126',
          'role': 'proveedor',
          'status': 'pendiente',
          'pending_step': 'validatingDocs',
        };
      }
      if (email == 'activado@incide.com' && password == '12345678') {
        return {
          'token': 'tk_127',
          'role': 'proveedor',
          'status': 'pendiente',
          'pending_step': 'activated',
        };
      }
      if (email == 'aceptado@incide.com' && password == '12345678') {
        return {'token': 'tk_128', 'role': 'proveedor', 'status': 'aceptado'};
      }
      if (email == 'rechazado@incide.com' && password == '12345678') {
        return {'token': 'tk_129', 'role': 'proveedor', 'status': 'rechazado'};
      }
      throw Exception('Correo o contraseña incorrectos');
    }

    // ── CREDENCIALES DE PRUEBA: CLIENTE ──────────────────────────────────────
    if (email == 'cliente@correo.com' && password == 'cliente123') {
      return {
        'token': 'mock_token_cliente_123',
        'role': 'cliente',
        'status': 'aceptado',
      };
    }

    throw Exception('Correo o contraseña incorrectos');
  }

  // ── REGISTER ──────────────────────────────────────────────────────────────

  /// Simula un registro exitoso devolviendo la misma estructura que el backend real:
  /// { "user": { ... }, "token": "..." }
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
    await Future.delayed(const Duration(seconds: 1)); // Simula latencia de red

    // Simula un correo ya registrado para probar manejo de errores
    if (email == 'existe@correo.com') {
      throw Exception('Este correo ya está registrado.');
    }

    // Respuesta exitosa — misma estructura que el backend real (AuthOutPutDTO)
    return {
      'user': {
        'id': 99,
        'fullName': '$firstName $lastName',
        'email': email,
        'phoneNumber': phoneNumber,
        'userRole': userRole == 2 ? 'Client' : 'Provider',
        // Simulamos el status inicial devuelto por el backend real
        'status': userRole == 3 ? 'Registered' : null,
      },
      'token': 'mock_register_token_${email.hashCode.abs()}',
    };
  }
}
