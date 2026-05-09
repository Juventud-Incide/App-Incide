import 'package:app_incide/features/auth/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegistrationState {
  // --- Datos del Paso 1 (Personal) ---
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String confirmPassword;
  final String phoneNumber;
  final String curp;
  final String rfc;

  // --- Datos del Paso 3 (Profesional) ---
  final int categoryId;
  final List<int> serviceIds;
  final int yearsOfExperience;
  final String professionalLicense;
  final String description;

  // --- Estado de la petición ---
  final bool isLoading;
  final String error;

  RegistrationState({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.phoneNumber = '',
    this.curp = '',
    this.rfc = '',
    this.categoryId = 0,
    this.serviceIds = const [],
    this.yearsOfExperience = 0,
    this.professionalLicense = '',
    this.description = '',
    this.isLoading = false,
    this.error = '',
  });

  // El método copyWith es obligatorio en Riverpod para inmutabilidad
  RegistrationState copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? confirmPassword,
    String? phoneNumber,
    String? curp,
    String? rfc,
    int? categoryId,
    List<int>? serviceIds,
    int? yearsOfExperience,
    String? professionalLicense,
    String? description,
    bool? isLoading,
    String? error,
  }) {
    return RegistrationState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      curp: curp ?? this.curp,
      rfc: rfc ?? this.rfc,
      categoryId: categoryId ?? this.categoryId,
      serviceIds: serviceIds ?? this.serviceIds,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      professionalLicense: professionalLicense ?? this.professionalLicense,
      description: description ?? this.description,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class RegistrationNotifier extends Notifier<RegistrationState> {
  @override
  RegistrationState build() {
    // Al iniciar, devolvemos un estado completamente en blanco
    return RegistrationState();
  }

  /// Método para la Pantalla 1: Guarda los datos personales
  void saveStepOne({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phoneNumber,
    required String curp,
    required String rfc,
  }) {
    state = state.copyWith(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
      curp: curp,
      rfc: rfc,
    );
  }

  /// Método temporal para modificar los servicios antes de enviar (Para la Pantalla 3)
  void updateServices(int categoryId, List<int> serviceIds) {
    state = state.copyWith(categoryId: categoryId, serviceIds: serviceIds);
  }

  /// Método para la Pantalla 3 que dispara el envío
  Future<bool> submitRegistration({
    required int yearsOfExperience,
    required String professionalLicense,
    required String description,
  }) async {
    // 1. Ponemos el estado en "Cargando"
    state = state.copyWith(
      isLoading: true,
      error: '',
      yearsOfExperience: yearsOfExperience,
      professionalLicense: professionalLicense,
      description: description,
    );

    try {
      // 2. Leemos el repositorio inyectado
      final repository = ref.read(authRepositoryProvider);

      // 3. Enviamos ABSOLUTAMENTE TODO el estado acumulado
      await repository.registerProvider(
        firstName: state.firstName,
        lastName: state.lastName,
        email: state.email,
        password: state.password,
        phoneNumber: state.phoneNumber,
        curp: state.curp,
        rfc: state.rfc,
        categoryId: state.categoryId,
        serviceIds: state.serviceIds,
        yearsOfExperience: state.yearsOfExperience,
        professionalLicense: state.professionalLicense,
        description: state.description,
      );

      state = state.copyWith(isLoading: false);
      return true; // Éxito
    } catch (e) {
      // Si falla (ej. Correo ya existe), atrapamos el error
      state = state.copyWith(isLoading: false, error: e.toString());
      return false; // Falló
    }
  }

  /// Limpia la memoria si el usuario cancela el registro y regresa al Login
  void clear() {
    state = RegistrationState();
  }
}

// 3. El Provider global para que toda la app lo escuche
final registrationProvider =
    NotifierProvider<RegistrationNotifier, RegistrationState>(() {
      return RegistrationNotifier();
    });
