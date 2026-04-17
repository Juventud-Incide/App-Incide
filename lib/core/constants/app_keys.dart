/// Única fuente de la verdad para las llaves de almacenamiento local (SharedPreferences).
/// Usar estas constantes evita errores ortográficos (Magic Strings) en la aplicación.
class AppKeys {
  // Evitamos que alguien pueda instanciar esta clase por error
  AppKeys._();

  static const String token = 'jwt_token';
  static const String role = 'user_role';
  static const String profileStatus = 'profile_status';
}
