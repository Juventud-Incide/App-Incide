import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_incide/core/constants/app_keys.dart';

/// Interceptor que actúa como un Observer pasivo del tráfico de red.
class AuthInterceptor extends Interceptor {
  final void Function() onUnauthenticated;

  AuthInterceptor({required this.onUnauthenticated});

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 1. Definimos las rutas que NUNCA deben llevar token
    final List<String> publicRoutes = [
      '/auth/login',
      '/auth/register',
      '/auth/registerProvider',
      '/auth/verify-otp',
      '/api/categorias',
      '/api/servicios',
    ];

    // 2. Buscamos el token guardado en el dispositivo
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppKeys.token);

    // 3. Inyectamos el token SOLO si existe y la ruta NO es pública
    if (token != null &&
        token.isNotEmpty &&
        !publicRoutes.contains(options.path)) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // 4. Dejamos que la petición continúe su viaje hacia el servidor
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 1. Observamos si el servidor nos rechazó por falta de permisos o caducidad
    if (err.response?.statusCode == 401) {
      print('🔒 ALERTA DE SEGURIDAD: Token expirado o inválido (Error 401).');
      onUnauthenticated();
    }

    // 2. Dejamos que el error siga su curso para que la pantalla que hizo
    // la petición pueda mostrar un mensaje al usuario.
    super.onError(err, handler);
  }
}
