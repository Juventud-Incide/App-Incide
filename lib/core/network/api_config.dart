/// Define los posibles entornos de ejecución.
enum Environment { development, production }

/// Clase de configuración que implementa el Patrón Strategy para
/// determinar las URLs y variables de entorno a utilizar.
class ApiConfig {
  // ── CAMBIAR AQUÍ según dónde estés probando ────────────────────────────────
  // Environment.production → https://incide-dev.ddns.net/api  (servidor desplegado)
  // Environment.development → http://10.0.2.2:5000/api        (backend local)
  static Environment currentEnvironment = Environment.production;

  /// Retorna la URL base dependiendo de la estrategia (entorno) actual.
  ///
  /// Las rutas del backend son /api/auth/login, /api/auth/register, etc.
  /// Por eso la baseUrl termina en /api — sin /v1.
  static String get baseUrl {
    switch (currentEnvironment) {
      case Environment.production:
        // Backend desplegado en el servidor DDNS de producción
        return 'https://incide-dev.ddns.net/api';

      case Environment.development:
        // Android Emulator: usa 10.0.2.2 para referirse a localhost de tu PC
        // iOS Simulator / Web con backend local: 'http://localhost:5000/api'
        // Celular físico en la misma red: usa la IP de tu PC (ej. 192.168.1.X)
        return 'http://10.0.2.2:5000/api';
    }
  }
}
