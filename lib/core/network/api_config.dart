/// Define los posibles entornos de ejecución.
enum Environment { development, production }

/// Clase de configuración que implementa el Patrón Strategy para
/// determinar las URLs y variables de entorno a utilizar.
class ApiConfig {
  // Por defecto, lo iniciamos en desarrollo.
  // Antes de compilar para producción, cambiaríamos esto a Environment.production
  static Environment currentEnvironment = Environment.development;

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
        // iOS Simulator / Web: cambia a 'http://localhost:5000/api'
        // Celular físico en la misma red: usa la IP de tu PC (ej. 192.168.1.X)
        return 'http://10.0.2.2:5000/api';
    }
  }
}
