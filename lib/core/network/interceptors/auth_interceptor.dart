import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_incide/core/constants/app_keys.dart';

/// Interceptor que adjunta el JWT a cada petición autenticada.
///
/// Las rutas públicas (/auth/login y /auth/register) quedan exentas —
/// enviarles un token causaría un 401 si el token está vencido.
class AuthInterceptor extends Interceptor {
  /// Rutas que NO necesitan token (son las que dan el token).
  static const _publicPaths = ['/auth/login', '/auth/register'];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Verificamos si la ruta actual es pública (no requiere token)
    final isPublic = _publicPaths.any((path) => options.path.contains(path));

    if (!isPublic) {
      // Solo para rutas protegidas: inyectamos el token en el header
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppKeys.token);

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    // Dejamos que la petición continúe hacia el servidor
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // El token expiró o es inválido en una ruta protegida.
      // TODO: Aquí se puede forzar logout y redirigir al login.
      print('🔒 ALERTA DE SEGURIDAD: Token expirado o inválido (Error 401).');
    }

    // Dejamos que el error siga para que la pantalla muestre el mensaje.
    super.onError(err, handler);
  }
}
