import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:incide_core/features/auth/providers/auth_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ARCHIVO EXCLUSIVO DEL CLIENTE
//
// Este archivo separa la lógica de registro del cliente de la del proveedor.
//
// ¿Cómo funciona?
//  1. La pantalla ClienteRegisterScreen solo importa ESTE archivo.
//  2. ClientAuthNotifier llama internamente al AuthController global.
//  3. El AuthController actualiza el AuthState global → GoRouter navega solo.
//
// La pantalla del proveedor (ProfRegisterScreen / ProfExperienceScreen)
// NO toca este archivo — tiene su propio flujo independiente.
// ─────────────────────────────────────────────────────────────────────────────

// ── 1. ESTADO DE UI EXCLUSIVO DEL CLIENTE ────────────────────────────────────
/// Controla el estado de carga y errores de la pantalla de registro del cliente.
/// Es independiente del [AuthState] global — solo afecta a esta pantalla.
class ClientRegisterState {
  final bool isLoading;
  final String? errorMessage;

  const ClientRegisterState({this.isLoading = false, this.errorMessage});

  ClientRegisterState copyWith({bool? isLoading, String? errorMessage}) {
    return ClientRegisterState(
      isLoading: isLoading ?? this.isLoading,
      // Si se pasa null explícitamente, limpiamos el error
      errorMessage: errorMessage,
    );
  }
}

// ── 2. PROVIDER EXPUESTO A LA UI ─────────────────────────────────────────────
/// Proveedor que la pantalla [ClienteRegisterScreen] consume para
/// manejar el estado de carga y errores durante el registro.
final clientAuthProvider =
    NotifierProvider<ClientAuthNotifier, ClientRegisterState>(
      ClientAuthNotifier.new,
    );

// ── 3. NOTIFIER — LÓGICA DE REGISTRO DEL CLIENTE ─────────────────────────────
class ClientAuthNotifier extends Notifier<ClientRegisterState> {
  @override
  ClientRegisterState build() => const ClientRegisterState();

  /// Registra al cliente llamando al [AuthController] global.
  ///
  /// Si el registro es exitoso, el [AuthController] actualiza el [AuthState]
  /// (isAuthenticated = true, role = 'cliente') y GoRouter navega
  /// automáticamente al home del cliente — sin necesidad de navegación manual.
  ///
  /// Si falla, guarda el mensaje de error en [ClientRegisterState.errorMessage]
  /// y lo relanza para que la pantalla pueda mostrarlo en un SnackBar.
  Future<void> registerCliente({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
    String? phoneNumber,
  }) async {
    // Activamos el loader en la pantalla del cliente
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Delegamos al AuthController global, fijando userRole = 0 (Client)
      await ref
          .read(authControllerProvider.notifier)
          .register(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
            confirmPassword: confirmPassword,
            phoneNumber: phoneNumber,
            userRole: 2, // 2 = Client — siempre fijo para el flujo del cliente
          );

      // Si llega aquí sin lanzar excepción, el registro fue exitoso.
      // GoRouter ya navegó al home — solo apagamos el loader por limpieza.
      state = state.copyWith(isLoading: false);
    } catch (e) {
      final mensaje = e.toString().replaceAll('Exception: ', '');
      state = state.copyWith(isLoading: false, errorMessage: mensaje);
      // Relanzamos para que la pantalla pueda mostrar el SnackBar
      rethrow;
    }
  }
}
