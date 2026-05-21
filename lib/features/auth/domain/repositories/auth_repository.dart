/// Contrato abstracto que define las operaciones de autenticación.
/// No contiene lógica, solo la firma de los métodos.
///
/// Tanto [NetworkAuthRepository] (producción) como [MockAuthRepository]
/// (desarrollo) implementan este contrato. El provider inyecta la
/// implementación correcta según [useMocksProvider].
abstract class AuthRepository {
  /// Inicio de sesión.
  ///
  /// El backend solo recibe [email] y [password].
  /// El rol del usuario viene de vuelta en la respuesta (user.userRole).
  ///
  /// Respuesta esperada del backend real:
  /// ```json
  /// { "user": { "id":1, "fullName":"Ana", "email":"...", "userRole":"Client" }, "token":"..." }
  /// ```
  Future<Map<String, dynamic>> login(
    String email,
    String password,
  );

  /// Registro de un nuevo usuario (cliente o proveedor).
  ///
  /// [userRole] → 2 = Client, 3 = Provider (enum del backend C#).
  ///
  /// Respuesta esperada del backend real:
  /// ```json
  /// { "user": { "id":42, "fullName":"Ana García", "email":"...", "userRole":"Client" }, "token":"..." }
  /// ```
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    String? phoneNumber,
    required String role,
  });

  Future<void> registerProvider({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
    required String curp,
    required String rfc,
    required int categoryId,
    required List<int> serviceIds,
    required int yearsOfExperience,
    required String professionalLicense,
    required String description,
  });

  Future<void> sendOtp(String phoneNumber);

  Future<bool> verifyOtp(String phoneNumber, String code);

  Future<void> resendOtp(String phoneNumber);

  Future<List<Map<String, dynamic>>> getServicesCatalog();

  Future<List<Map<String, dynamic>>> getCategoriesCatalog();

  // Aquí puedes agregar más métodos en el futuro:
  // Future<void> logout();
}
