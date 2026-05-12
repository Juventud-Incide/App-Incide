import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_incide/core/constants/app_keys.dart';
// Importa tu interceptor real
import 'package:app_incide/core/network/interceptors/auth_interceptor.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;

  setUp(() {
    // 1. Configuramos el cliente HTTP base
    dio = Dio(BaseOptions(baseUrl: 'https://api.incide.com'));
    dioAdapter = DioAdapter(dio: dio);

    // 2. Le inyectamos TU interceptor (El guardia de seguridad real)
    dio.interceptors.add(AuthInterceptor());
  });

  test(
    'PI-01: AuthInterceptor inyecta el Bearer Token en petición protegida',
    () async {
      // 1. PRECONDICIÓN: Simulamos el "Disco Duro" con una sesión activa
      SharedPreferences.setMockInitialValues({
        AppKeys.token: 'super_token_simulado_123',
      });

      // Configuramos el servidor falso para que responda OK y no truene la petición
      dioAdapter.onGet(
        '/provider/opportunities',
        (server) => server.reply(200, {}),
      );

      // Variable temporal para capturar el resultado
      Map<String, dynamic>? capturedHeaders;

      // 3. EL TRUCO: Añadimos un interceptor "espía" al final de la fila
      // Este espía tomará una foto de las cabeceras justo antes de enviarlas al MockAdapter
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedHeaders = options.headers;
            return handler.next(options);
          },
        ),
      );

      // 2. EJECUCIÓN: Hacemos una petición GET cualquiera a una ruta protegida
      await dio.get('/provider/opportunities');

      // 3. RESULTADO ESPERADO: Verificar la inyección del Token
      expect(
        capturedHeaders,
        isNotNull,
        reason: 'Las cabeceras no deben estar vacías',
      );

      // Verificamos que la llave 'Authorization' exista
      expect(
        capturedHeaders!.containsKey('Authorization'),
        isTrue,
        reason: 'El interceptor debió inyectar la cabecera Authorization',
      );

      // Verificamos que el formato sea exactamente el requerido por ASP .NET (Bearer <token>)
      expect(
        capturedHeaders!['Authorization'],
        'Bearer super_token_simulado_123',
        reason:
            'El formato debe ser Bearer seguido del token almacenado en disco',
      );
    },
  );

  test(
    'PI-02: AuthInterceptor.onError() permite la propagación del error HTTP 401',
    () async {
      // 1. PRECONDICIÓN: Token expirado o inválido.
      // Simulamos que el servidor está programado para rechazar la petición
      dioAdapter.onGet(
        '/provider/profile',
        (server) => server.reply(401, {'message': 'Token expirado'}),
      );

      // 2. EJECUCIÓN y VERIFICACIÓN:
      // Como esperamos que Dio lance una excepción, usamos el matcher 'throwsA' de flutter_test
      // Esto captura el error en el aire antes de que rompa la prueba.
      expect(
        () async => await dio.get('/provider/profile'),
        throwsA(
          isA<DioException>().having(
            (e) => e.response?.statusCode,
            'statusCode',
            401, // Validamos que el código del error sea exactamente 401
          ),
        ),
        reason:
            'El interceptor debe permitir que el error 401 llegue al Repositorio',
      );
    },
  );
}
