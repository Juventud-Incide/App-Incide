import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_incide/features/auth/domain/repositories/auth_repository.dart';

// Aquí agregaremos todas las clases que necesitamos simular en el proyecto.
// Al ejecutar build_runner, generará un archivo mocks.mocks.dart automáticamente.
@GenerateMocks([
  SharedPreferences,
  AuthRepository,
  // En el futuro, si necesitas simular más repositorios, los agregas a esta lista.
])
void main() {}
