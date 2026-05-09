/// Contrato abstracto que define las operaciones de autenticación.
/// No contiene lógica, solo la firma de los métodos.
abstract class AuthRepository {
  Future<Map<String, dynamic>> login(
    String email,
    String password,
    String role,
  );

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    required String phoneNumber,
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

  Future<bool> verifyOtp(String phoneNumber, String code);

  // Aquí puedes agregar más métodos en el futuro:
  // Future<void> logout();
}
