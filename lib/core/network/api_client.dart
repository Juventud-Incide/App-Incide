import 'package:app_incide/core/network/interceptors/auth_interceptor.dart';
import 'package:dio/dio.dart';
import 'api_config.dart';

/// Cliente HTTP centralizado de la aplicación.
/// Implementa el Patrón Singleton para mantener una única instancia
/// del pool de conexiones en todo el ciclo de vida de la app.
class ApiClient {
  // La instancia estática y privada
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;

  // Variable para almacenar la función de cierre de sesión
  void Function()? onTokenExpired;

  // Siempre que alguien haga `ApiClient()`, se le devolverá la `_instance` ya existente.
  factory ApiClient() {
    return _instance;
  }

  // El constructor interno privado. Solo se ejecuta una vez en toda la app.
  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        // Consumimos la URL inyectada desde ApiConfig, que se adapta según el entorno (desarrollo o producción).
        baseUrl: ApiConfig.baseUrl,

        // Tiempos máximos de espera para evitar que la app se congele
        // si el backend en desarrollo está apagado o lento.
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),

        // Cabeceras estándar para comunicarse con un backend REST
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // TODO: Aquí añadiremos el Interceptor (Observer)
    dio.interceptors.add(
      AuthInterceptor(
        onUnauthenticated: () {
          if (onTokenExpired != null) {
            onTokenExpired!();
          }
        },
      ),
    );

    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }
}
