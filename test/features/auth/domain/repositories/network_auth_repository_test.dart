import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_incide/features/auth/domain/repositories/network_auth_repository.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late NetworkAuthRepository networkRepository;

  setUp(() {
    // Configuramos Dio y el adaptador que interceptará las peticiones para no usar internet
    dio = Dio(BaseOptions(baseUrl: 'https://api.incide.com'));
    dioAdapter = DioAdapter(dio: dio);

    // Inyectamos el Dio "falso" a nuestro repositorio real
    networkRepository = NetworkAuthRepository(dio);
  });

  test(
    'PI-03: NetworkAuthRepository.login() mapea JSON a modelo de dominio',
    () async {
      final loginPayload = {
        'email': 'profesionista@incide.com',
        'password': 'Password123!',
        'role': 'proveedor',
      };

      final mockResponse = {
        'token': 'jwt_test',
        'role': 'proveedor',
        'status': 'aceptado',
        'pending_step': null,
      };

      // Le decimos a DioAdapter: "Cuando recibas un POST a /auth/login con este payload, responde 200 y el JSON"
      dioAdapter.onPost(
        '/auth/login',
        (server) => server.reply(200, mockResponse),
        data: loginPayload,
      );

      // 2. EJECUCIÓN [cite: 104]
      final result = await networkRepository.login(
        'profesionista@incide.com',
        'Password123!',
        'proveedor',
      );

      // 3. RESULTADO ESPERADO [cite: 104]
      expect(
        result['token'],
        'jwt_test',
        reason: 'Debe extraer el token del JSON',
      );
      expect(
        result['role'],
        'proveedor',
        reason: 'Debe mapear el rol correctamente',
      );
      expect(
        result['status'],
        'aceptado',
        reason: 'Debe mapear el estatus de afiliación',
      );
    },
  );
}
