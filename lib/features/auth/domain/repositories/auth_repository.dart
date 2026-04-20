/// Contrato abstracto que define las operaciones de autenticación.
/// No contiene lógica, solo la firma de los métodos.
abstract class AuthRepository {
  Future<Map<String, dynamic>> login(
    String email,
    String password,
    String role,
  );

  // Aquí puedes agregar más métodos en el futuro:
  // Future<void> logout();
  // Future<void> register(User user);
}
