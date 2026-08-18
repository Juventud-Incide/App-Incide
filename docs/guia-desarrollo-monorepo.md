# Guía de Desarrollo: Arquitectura Monorepo (INCIDE)

Este documento explica en detalle el funcionamiento de la nueva estructura del proyecto, las responsabilidades de cada aplicación y las directrices técnicas para que **dos desarrolladores trabajen en paralelo** (uno en el flujo de Cliente y otro en el de Proveedor) sin colisionar en código ni duplicar esfuerzos, maximizando la reutilización mediante el núcleo compartido.

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
Es el motor central del monorepo. Se encarga de la lógica de negocio profunda, persistencia base, modelos de dominio comunes, servicios compartidos y componentes UI reutilizables.

*   **Red, HTTP y Sockets:** Contiene el `ApiClient` de Dio, interceptores globales (`AuthInterceptor` para inyección automática de JWT) y configuraciones de endpoints. A futuro, la lógica de conexión para WebSockets o Firebase (notificaciones/chat en vivo) vivirá aquí.
*   **Autenticación y Sesión:** Controlador global de sesión (`authControllerProvider`), persistencia de tokens con `FlutterSecureStorage` y flujos comunes como registro base, recuperación de contraseñas y envío/validación de OTP.
*   **Servicio de Geolocalización:** Lógica común para obtener coordenadas GPS, calcular distancias y gestionar los diálogos de permisos a nivel sistema.
*   **Modelos de Dominio Unificados:** Estructuras del negocio consumidas por ambas apps (Usuario, Cotización, Oportunidad, Mensajes de Chat).
*   **Componentes UI Compartidos:** Elementos visuales reutilizables que no dependen de flujos específicos de una sola app (ej. avatares, visores de imágenes, botones genéricos de acción).
*   **Conectividad y Utilidades:** Monitoreo en vivo de la red (`networkStreamProvider`), formateadores (moneda, fechas relativas del chat) y validadores regex comunes.

### 📱 `app_cliente` (Desarrollador A)
Contiene la aplicación compilable para el usuario final que solicita servicios.
*   **Vistas de Negocio Cliente:** Pantallas de Login de cliente, Registro, Catálogo de Categorías, Creación de Solicitudes (Públicas/Especiales), Visualización y Aceptación/Rechazo de Cotizaciones.
*   **UI Local de Chat:** Pantalla del chat de cara al cliente y barra de entrada de texto adaptada a su flujo.
*   **Enrutamiento (`client_router.dart`):** Rutas exclusivas del cliente final con redireccionamientos automáticos basados en el estado de autenticación.
*   **Assets:** Recursos visuales e imágenes de marca orientadas al usuario final.

### 📱 `app_proveedor` (Desarrollador B)
Contiene la aplicación compilable para los prestadores de servicios y profesionales afiliados.
*   **Vistas de Negocio Proveedor:** Login profesional, onboarding OTP, carga y validación de documentos (revisión de estatus), listado de Oportunidades en mapa/lista, Billetera (`WalletScreen`) y gestión de transferencias/retiros.
*   **UI Local de Chat:** Pantalla del chat desde la perspectiva del proveedor con opciones de marcar completado.
*   **Enrutamiento (`provider_router.dart`):** Rutas y redirecciones basadas en el túnel de afiliación del proveedor (`pendiente`, `rechazado`, `aceptado`, `subir documentos`).
*   **Assets:** Gráficos e identidad visual dirigidos al profesional del servicio.

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

## 4. Unificación de Lógica Compartida (Chat y Negocio)

Para evitar duplicaciones masivas y asegurar que ambas aplicaciones reaccionen exactamente igual ante los mismos eventos del backend, se deben centralizar los siguientes módulos en `incide_core`:

### 💬 4.1. Módulo de Chat Unificado
Actualmente, ambas aplicaciones tienen implementaciones de chat similares pero con modelos duplicados (`ChatMessageModel` y `ChatMessage`). La unificación bajo `incide_core` debe seguir estas pautas:

1.  **Modelo de Datos Único (`ChatMessage`):**
    *   **Identificación del Emisor:** Reemplazar el booleano `isMine` por un enum `SenderType { client, provider, system }`.
    *   *Ventaja:* Permite que el mismo modelo se compile en ambas apps. Para el cliente, `client` es local y `provider` es remoto; para el proveedor es al revés.
    *   **Estructura del Mensaje:**
        ```dart
        class ChatMessage {
          final String id;
          final String? text;
          final String? imageUrl;
          final Attachment? attachment; // Para documentos/imágenes locales
          final SenderType sender;
          final DateTime timestamp;
          final MessageStatus status; // sent, delivered, read
          final SystemEventType? systemEvent; // Eventos de finalización de servicio
        }
        ```
2.  **Manejo de Adjuntos (`Attachment`):**
    *   Unificar el soporte para imágenes y documentos (PDFs, etc.), incluyendo su metainformación (nombre, ruta, bytes locales) para subida asíncrona.
3.  **Lógica de Notificación y Presencia:**
    *   `typingProvider` (para rastrear si el otro usuario está escribiendo) y `activeChatProvider` (para determinar si el usuario tiene la pantalla de chat abierta y marcar los mensajes entrantes como leídos de inmediato) deben residir en `incide_core`.

### 🤝 4.2. Ciclo de Vida del Servicio (Cotización & Oportunidad)
La interacción principal de la plataforma ocurre entre una solicitud del cliente y la respuesta del proveedor. Esta lógica debe centralizarse mediante:
1.  **Modelos Unificados:**
    *   **Solicitud/Oportunidad:** Estructura que describe la necesidad (Categoría, descripción del problema, presupuesto estimado, ubicación GPS, fotos).
    *   **Cotización/Propuesta:** Propuesta económica del proveedor (Monto, descripción técnica, horas estimadas, fecha sugerida, estatus: *Submitted, Accepted, Rejected, Withdrawn*).
2.  **Flujo de Finalización Compartido:**
    *   El protocolo de cierre de servicio debe vivir en `incide_core/lib/features/shared/utils/quote_dialogs.dart` (o equivalente):
        *   **Fase 1:** El proveedor propone marcar el servicio como completado (`providerMarkedCompleted = true`).
        *   **Fase 2:** Se inserta un mensaje de sistema en el chat común alertando al cliente.
        *   **Fase 3:** El cliente acepta la finalización (`clientConfirmedCompleted = true`), cerrando el chat en modo solo lectura (`readOnlyLock`).

### 🎨 4.3. UI & Sistema de Diseño Compartido
Varios widgets y utilidades visuales se encuentran duplicados en las carpetas `lib/features/shared/` de ambas apps. Estos componentes deben migrarse a `incide_core/lib/features/shared/widgets/`:
*   `CachedAvatar`: Carga adaptativa del avatar del usuario final o profesional con soporte de iniciales y fallback offline.
*   `CachedGalleryImage`: Renderizado optimizado para imágenes enviadas en el chat con cargadores progresivos.
*   `FullScreenImageViewer`: Vista de zoom táctil para las imágenes del chat.
*   `CustomLogoutButton`: Botón centralizado que limpia las credenciales en `FlutterSecureStorage` y redirige a la selección de roles en la pantalla `/roles`.

---

## 5. Reglas de Convivencia y Modificaciones en `incide_core`

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

## 6. Comandos y Operativa Diaria

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
