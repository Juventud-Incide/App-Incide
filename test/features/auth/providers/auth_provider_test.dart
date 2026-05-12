import 'package:app_incide/features/auth/domain/models/application_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_incide/core/constants/app_keys.dart';
import 'package:app_incide/features/auth/providers/auth_provider.dart';
import '../../../mocks.mocks.dart';
import 'package:mockito/mockito.dart';

void main() {
  // Asegura que los bindings de Flutter estén listos antes de correr los tests
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter.baseflow.com/permissions/methods'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'checkPermissionStatus') {
              return 1; // Equivale a PermissionStatus.granted
            }
            return null;
          },
        );
  });

  test(
    'PU-02: AuthController.initialize() restaura la sesión leyendo SharedPreferences',
    () async {
      // 1. PRECONDICIÓN: Inyectamos los valores falsos
      SharedPreferences.setMockInitialValues({
        AppKeys.token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
        AppKeys.role: 'proveedor',
        AppKeys.profileStatus: 'aceptado',
      });

      // 2. CONFIGURACIÓN RIVERPOD
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final authController = container.read(authControllerProvider.notifier);

      // 3. EJECUCIÓN
      await authController.initialize();

      // 4. VERIFICACIÓN
      final finalState = container.read(authControllerProvider);

      expect(
        finalState.isInitialized,
        isTrue,
        reason: 'El splash debería haber terminado',
      );
      expect(
        finalState.isAuthenticated,
        isTrue,
        reason: 'Debería estar autenticado al encontrar el token',
      );
      expect(
        finalState.role,
        'proveedor',
        reason: 'El rol no se restauró correctamente',
      );
      expect(
        finalState.profileStatus,
        'aceptado',
        reason: 'El estatus no coincide con el almacenado',
      );
      expect(
        finalState.hasLocationPermission,
        isTrue,
        reason: 'El permiso de ubicación debería estar concedido por el mock',
      );
    },
  );

  test(
    'PU-03: AuthController.login() exitoso actualiza estado y guarda en SharedPreferences',
    () async {
      // 1. ARRANGE (PREPARACIÓN)
      // Limpiamos el "disco duro" para que esté vacío al iniciar
      SharedPreferences.setMockInitialValues({});

      // Instanciamos el Repositorio Falso que generó build_runner
      final mockRepository = MockAuthRepository();

      // Programamos el comportamiento del Mock:
      // Le decimos: "Cuando llamen a la función login con CUALQUIER texto, responde este JSON"
      when(mockRepository.login(any, any, any)).thenAnswer(
        (_) async => {
          'token': 'super_token_secreto_123',
          'role': 'proveedor',
          'status': 'pendiente',
          'pending_step': null,
        },
      );

      // Creamos la burbuja de Riverpod, pero esta vez INYECTAMOS nuestro Mock
      // Esto es el equivalente a "desconectar el cable de red y conectar nuestro simulador"
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(mockRepository)],
      );
      addTearDown(container.dispose);

      final authController = container.read(authControllerProvider.notifier);

      // 2. ACT (ACTUACIÓN)
      // Disparamos la función con datos de prueba
      await authController.login(
        'correo@prueba.com',
        'password123',
        'proveedor',
      );

      // 3. ASSERT (VERIFICACIÓN)
      final finalState = container.read(authControllerProvider);

      // A. Verificamos la Memoria RAM (Estado de Riverpod)
      expect(
        finalState.isLoading,
        isFalse,
        reason: 'El loader debió apagarse al terminar',
      );
      expect(
        finalState.isAuthenticated,
        isTrue,
        reason: 'El usuario debe estar autenticado',
      );
      expect(
        finalState.role,
        'proveedor',
        reason: 'El rol asignado debe ser proveedor',
      );

      // B. Verificamos el Disco Duro (SharedPreferences)
      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString(AppKeys.token),
        'super_token_secreto_123',
        reason: 'El token debió guardarse en disco',
      );
    },
  );

  test(
    'PU-04: AuthController.login() apaga el loading y lanza excepción al fallar',
    () async {
      // 1. PRECONDICIÓN: Repositorio falso lanza error
      final mockRepository = MockAuthRepository();
      when(
        mockRepository.login(any, any, any),
      ).thenThrow(Exception('Correo o contraseña incorrectos'));

      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(mockRepository)],
      );
      addTearDown(container.dispose);

      final authController = container.read(authControllerProvider.notifier);

      // 2. EJECUCIÓN Y VERIFICACIÓN: Comprobamos que el controlador relanza el error limpio
      // Usamos una función anónima asíncrona dentro del expect
      await expectLater(
        () async => await authController.login(
          'mal@correo.com',
          'claveMala',
          'proveedor',
        ),
        throwsA(isA<String>()), // Lanza un String por tu .replaceAll()
      );

      // Verificamos que se apagó la ruedita de carga a pesar del error
      final finalState = container.read(authControllerProvider);
      expect(
        finalState.isLoading,
        isFalse,
        reason: 'El loader debe apagarse al fallar',
      );
    },
  );

  test(
    'PU-05: AuthController.logout() limpia memoria RAM y almacenamiento en disco',
    () async {
      // 1. PRECONDICIÓN: Llenamos el disco duro con datos simulados
      SharedPreferences.setMockInitialValues({
        AppKeys.token: 'token_valido',
        AppKeys.role: 'proveedor',
        AppKeys.profileStatus: 'aceptado',
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final authController = container.read(authControllerProvider.notifier);

      // Forzamos al controlador a leer el disco duro para cargar el estado
      await authController.initialize();
      expect(container.read(authControllerProvider).isAuthenticated, isTrue);

      // 2. EJECUCIÓN
      await authController.logout();

      // 3. VERIFICACIÓN DE RAM (Riverpod vuelve a los valores por defecto)
      final finalState = container.read(authControllerProvider);
      expect(finalState.isAuthenticated, isFalse);
      expect(finalState.role, isNull);
      expect(finalState.profileStatus, isNull);

      // 4. VERIFICACIÓN DE DISCO (SharedPreferences está vacío)
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(AppKeys.token), isFalse);
      expect(prefs.containsKey(AppKeys.role), isFalse);
    },
  );

  test(
    'PU-06: Métodos de transición de estatus actualizan Riverpod y disco',
    () async {
      // 1. PRECONDICIÓN: Entorno limpio
      SharedPreferences.setMockInitialValues({});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final authController = container.read(authControllerProvider.notifier);
      final prefs = await SharedPreferences.getInstance();

      // --- PRUEBA A: grantLocation ---
      authController.grantLocation();
      expect(
        container.read(authControllerProvider).hasLocationPermission,
        isTrue,
      );

      // --- PRUEBA B: updateApplicationStatus ---
      final fakeStatus = ApplicationStatus.pendingReview;
      await authController.updateApplicationStatus(fakeStatus);

      expect(
        container.read(authControllerProvider).applicationStatus,
        fakeStatus,
      );
      expect(prefs.getString(AppKeys.applicationStatus), fakeStatus.name);

      // --- PRUEBA C: completeActivation ---
      await authController.completeActivation();

      expect(container.read(authControllerProvider).profileStatus, 'aceptado');
      expect(prefs.getString(AppKeys.profileStatus), 'aceptado');
    },
  );
}
