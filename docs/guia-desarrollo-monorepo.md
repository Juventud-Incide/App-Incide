# Guía de Desarrollo: Arquitectura Monorepo (INCIDE)

Este documento explica en detalle el funcionamiento de la nueva estructura del proyecto, las responsabilidades de cada aplicación y las directrices técnicas para que **dos desarrolladores trabajen en paralelo** (uno en el flujo de Cliente y otro en el de Proveedor) sin colisionar en código ni duplicar esfuerzos.

---

## 1. Arquitectura General y Directorios

El repositorio se ha dividido en un ecosistema móvil estructurado bajo la carpeta `/frontend`:

```text
/ (Raíz del Repositorio Git)
├── backend/ (API en C# .NET 8)
├── docs/ (Documentación técnica y guías)
└── frontend/
    ├── packages/
    │   └── incide_core/ (El núcleo de lógica compartida - Paquete de Dart/Flutter)
    │
    ├── app_cliente/ (Aplicación móvil independiente para el Cliente final)
    └── app_proveedor/ (Aplicación móvil independiente para el Proveedor/Profesional)
```

---

## 2. Responsabilidad de cada Proyecto

### 📦 `incide_core` (El Núcleo Compartido)
Es el paquete encargado de la lógica de negocio, datos y configuración general que consumen ambas aplicaciones.
*   **Red y HTTP:** Contiene el `ApiClient` de Dio, configuraciones de endpoints y los interceptores (`AuthInterceptor`) para inyectar cabeceras JWT de forma transparente.
*   **Autenticación y Sesión:** Maneja el estado global de la sesión (`authControllerProvider`) y utiliza `FlutterSecureStorage` de forma unificada para persistir las credenciales.
*   **Geolocalización:** Contiene los flujos lógicos y servicios de geolocalización comunes a ambas partes.
*   **Modelos de Datos de Auth:** Estructuras como el usuario, roles y estados de afiliación compartidos.

### 📱 `app_cliente` (Desarrollador A)
Es el ejecutable destinado al cliente final. No tiene código relacionado con el panel de administración del proveedor ni con la carga de documentos de profesionales.
*   **Vistas:** Pantallas de Login del cliente, Registro, Home de cliente, Cotizaciones (`ClientQuotingScreen`, `ClienteQuoteDetailScreen`), y Chat del cliente.
*   **Enrutamiento (`client_router.dart`):** Solo reconoce rutas de cliente. Si no hay sesión, fuerza el login del cliente.
*   **Assets:** Iconos de la aplicación e imágenes orientados al cliente final.

### 📱 `app_proveedor` (Desarrollador B)
Es el ejecutable destinado a los profesionales y prestadores de servicios. No conoce pantallas de cotización de clientes ni pasarelas de pago de cara al usuario final.
*   **Vistas:** Pantallas de Login profesional, Flujo de incorporación/Registro OTP, Billetera (`WalletScreen`), Dashboard del profesional y Oportunidades.
*   **Enrutamiento (`provider_router.dart`):** Gestiona la navegación según el túnel de afiliación del proveedor (si es `pendiente`, redirige a subir documentos, revisión, o entrevista; si es `aceptado`, va al Home).
*   **Assets:** Recursos gráficos orientados al prestador del servicio.

---

## 3. Flujo de Trabajo para 2 Desarrolladores en Paralelo

### 🧑‍💻 Desarrollador A: Flujo de Cliente
*   **Espacio de Trabajo:** Debe abrir e interactuar principalmente con la carpeta `frontend/app_cliente/`.
*   **Desarrollo de Vistas:** Crea pantallas, componentes UI y lógica local de presentación dentro de `lib/features/client/`.
*   **Routing:** Modifica [`lib/client_router.dart`](file:///d:/repos/App-Incide/frontend/app_cliente/lib/client_router.dart) para registrar nuevas vistas exclusivas de clientes.

### 🧑‍💻 Desarrollador B: Flujo de Proveedor
*   **Espacio de Trabajo:** Debe abrir e interactuar principalmente con la carpeta `frontend/app_proveedor/`.
*   **Desarrollo de Vistas:** Crea pantallas, componentes UI y lógica local de presentación dentro de `lib/features/provider/`.
*   **Routing:** Modifica [`lib/provider_router.dart`](file:///d:/repos/App-Incide/frontend/app_proveedor/lib/provider_router.dart) para expandir el dashboard o ajustar los pasos del onboarding.

---

## 4. Reglas de Convivencia y Modificaciones en `incide_core`

Dado que `incide_core` es consumido por ambos proyectos, es el único punto de contacto donde los desarrolladores pueden colisionar. Sigan estas directrices estrictamente:

### ⚠️ Regla de Oro: No duplicarás código
Si vas a crear una utilidad de red, un validador genérico, un interceptor de logs o un modelo común, **no lo crees dentro de tu aplicación**. Créalo en `incide_core` para que ambos puedan usarlo de inmediato.

### 📝 Cómo importar elementos de `incide_core`
Cualquier archivo de tu app (`app_cliente` o `app_proveedor`) que necesite utilidades del núcleo (como `AppColors`, `AppKeys`, `authControllerProvider`, etc.) debe importarlo mediante el prefijo del paquete:
```dart
import 'package:incide_core/core/constants/app_keys.dart';
import 'package:incide_core/features/auth/providers/auth_provider.dart';
```

### 🔀 Coordinación de cambios en `incide_core`
Si necesitas añadir un endpoint a la API o modificar el DTO de respuesta de autenticación en `incide_core`:
1.  **Comunícalo:** Avisa a tu compañero de que vas a cambiar la estructura de `incide_core`.
2.  **Mantén compatibilidad:** Intenta que tus cambios no rompan la compilación del otro. Por ejemplo, no elimines parámetros requeridos en firmas de métodos que tu compañero ya esté usando.
3.  **Gestión de Dependencias:** Si agregas una biblioteca de terceros a `incide_core/pubspec.yaml`, recuerda que ambos desarrolladores deberán ejecutar `flutter pub get` en `incide_core` y en sus respectivas aplicaciones.

---

## 5. Comandos y Operativa Diaria

### 🚀 Primeros pasos (Instalación)
Cada vez que clones el repositorio o se hagan cambios en el archivo `pubspec.yaml` de `incide_core`:
```bash
# 1. Obtener dependencias en el núcleo compartido
cd frontend/packages/incide_core
flutter pub get

# 2. Obtener dependencias en la app de cliente
cd ../../app_cliente
flutter pub get

# 3. Obtener dependencias en la app de proveedor
cd ../app_proveedor
flutter pub get
```

### 📱 Ejecución de Aplicaciones
Los proyectos son completamente independientes para el motor de Flutter. Puedes correrlos en paralelo en distintos dispositivos o emuladores:

*   **Para correr Cliente:**
    ```bash
    cd frontend/app_cliente
    flutter run
    ```
*   **Para correr Proveedor:**
    ```bash
    cd frontend/app_proveedor
    flutter run
    ```

Si utilizas VS Code, Cursor o Android Studio, es sumamente recomendable **abrir cada carpeta por separado** (`frontend/app_cliente` o `frontend/app_proveedor`) en ventanas distintas del editor. De esta forma, las extensiones de Flutter detectarán correctamente el proyecto raíz de la aplicación para autocompletado y depuración en caliente (Hot Reload).
