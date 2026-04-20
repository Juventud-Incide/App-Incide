import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_incide/core/constants/app_keys.dart';

/// Interceptor que actúa como un Observer pasivo del tráfico de red.
class AuthInterceptor extends Interceptor {
  // Nota: Si usas flutter_secure_storage, lo cambiarías aquí

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 1. Buscamos el token guardado en el dispositivo
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppKeys.token);

    // 2. Si existe, lo inyectamos en la cabecera de la petición
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // 3. Dejamos que la petición continúe su viaje hacia el servidor
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 1. Observamos si el servidor nos rechazó por falta de permisos o caducidad
    if (err.response?.statusCode == 401) {
      print('🔒 ALERTA DE SEGURIDAD: Token expirado o inválido (Error 401).');

      // TODO: (Próximo paso) Aquí conectaremos un trigger para forzar el cierre
      // de sesión y mandar al usuario a la pantalla de Login.
    }

    // 2. Dejamos que el error siga su curso para que la pantalla que hizo
    // la petición pueda mostrar un mensaje al usuario.
    super.onError(err, handler);
  }
}
