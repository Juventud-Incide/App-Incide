import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_incide/core/constants/app_keys.dart';

/// Interceptor que adjunta el JWT a cada petición autenticada.
///
/// Las rutas públicas (/auth/login y /auth/register) quedan exentas —
/// enviarles un token causaría un 401 si el token está vencido.
class AuthInterceptor extends Interceptor {
  final Future<void> Function() onUnauthenticated;

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
      '/auth/send-otp',
      '/auth/resend-otp',
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
    if (err.response?.statusCode == 401) {
      debugPrint(
        '🔒 ALERTA DE SEGURIDAD: Token expirado o inválido (Error 401).',
      );
      onUnauthenticated();
    }

    // Dejamos que el error siga para que la pantalla muestre el mensaje.
    super.onError(err, handler);
  }
}
