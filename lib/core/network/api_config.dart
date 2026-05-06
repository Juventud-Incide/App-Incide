/// Define los posibles entornos de ejecución.
enum Environment { development, production }

/// Clase de configuración que implementa el Patrón Strategy para
/// determinar las URLs y variables de entorno a utilizar.
class ApiConfig {
  // Por defecto, lo iniciamos en desarrollo.
  // Antes de compilar para producción, cambiaríamos esto a Environment.production
  static Environment currentEnvironment = Environment.production;

  /// Retorna la URL base dependiendo de la estrategia (entorno) actual.
  static String get baseUrl {
    switch (currentEnvironment) {
      case Environment.production:
        // TODO: Reemplazar con la URL real de tu servidor en la nube
        return 'https://incide-dev.ddns.net/api';

      case Environment.development:
        // IMPORTANTE PARA PRUEBAS:
        // Si pruebas en el emulador de Android nativo, tu PC local es 10.0.2.2
        // Si pruebas en un celular físico o iOS, debes poner la IP de tu computadora (ej. 192.168.1.XX)
        return 'http://10.0.2.2:3000/api/v1';
    }
  }
}
