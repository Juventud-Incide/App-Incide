import 'package:incide_core/features/auth/domain/repositories/auth_repository.dart';

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
    await Future.delayed(const Duration(seconds: 2));
  }

  @override
  Future<void> sendOtp(String phoneNumber) async {
    // Simulamos el tiempo de espera de una petición a internet real (1 segundo)
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<bool> verifyOtp(String phoneNumber, String code) async {
    // 1. Simulamos el tiempo de espera de una petición a internet real (1 segundo)
    await Future.delayed(const Duration(seconds: 1));

    // 2. Simulamos la validación del servidor
    if (code == '1234') {
      return true;
    } else {
      // Simulamos que el servidor de C# nos devuelve un error 400
      throw 'El código ingresado es incorrecto o ha expirado.';
    }
  }

  @override
  Future<void> resendOtp(String phoneNumber) async {
    // Simulamos el tiempo de espera de una petición a internet real (1 segundo)
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<List<Map<String, dynamic>>> getServicesCatalog() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulamos red
    return [
      {"id": 2, "name": "Instalación de llaves", "categoryId": 1},
      {"id": 1, "name": "Reparación de tuberías", "categoryId": 1},
      {"id": 3, "name": "Instalación eléctrica", "categoryId": 2},
      {"id": 4, "name": "Reparación de apagadores", "categoryId": 2},
      {"id": 5, "name": "Instalación de muebles", "categoryId": 3},
      {"id": 6, "name": "Limpieza de hogar", "categoryId": 4},
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> getCategoriesCatalog() async {
    return [
      {"id": 1, "name": "Plomería"},
      {"id": 2, "name": "Electricidad"},
      {"id": 3, "name": "Carpintería"},
      {"id": 4, "name": "Limpieza"},
    ];
  }
}
