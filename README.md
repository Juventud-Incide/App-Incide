# 📱 App-Incide (Core Mobile)

Bienvenido al repositorio central de la aplicación móvil de **Juventud Incide**. Este proyecto integra las funcionalidades para **Clientes** y **Proveedores** en una sola plataforma.

---

## 🛠️ Flujo de Trabajo (Git Flow)

Para mantener la estabilidad del proyecto y cumplir con los estándares de seguridad, utilizaremos el siguiente flujo:

1. **Rama Default (`develop`):** Toda la integración y pruebas ocurren aquí. Es la rama base para iniciar cualquier tarea.
2. **Rama de Producción (`main`):** Reservada exclusivamente para versiones estables y probadas. **No se permiten commits directos.**
3. **Ramas de Tarea (`feature/`):** Cada nueva funcionalidad debe desarrollarse en su propia rama.

### Ciclo de desarrollo:
* `git checkout develop` (Asegúrate de estar en develop).
* `git pull origin develop` (Baja lo más reciente).
* `git checkout -b feature/nombre-de-tu-tarea` (Crea tu rama de trabajo).
* **Trabaja y haz tus commits.**
* `git push origin feature/nombre-de-tu-tarea` (Sube tu rama a GitHub).
* **Abre un Pull Request (PR)** hacia la rama `develop`.

---

## 📋 Reglas de Oro

* **✅ Revisión Obligatoria:** Ningún PR se fusiona a `develop` sin la revisión y aprobación de al menos otro miembro del equipo.
* **🚫 No tocar `main`:** Solo el equipo de **Ops-Admin** o el **Tech Lead** gestionan los pasos de `develop` a `main`.
* **✨ Clean Code:** Asegúrate de que tu código esté comentado y siga la estructura de carpetas definida.
* **🔒 Seguridad:** Nunca subas credenciales, API Keys o archivos `.env` al repositorio.

---

## 👥 Equipo (Mobile Core)

* **Front-end (Clientes):** Alan
* **Front-end (Proveedores):** Angel Apaez
* **Back-end:** German
* **DevOps / Admin:** AlanGuevara / Ops-Admin

---

> [!IMPORTANT]
> **Antes de iniciar:** Si tienes dudas sobre el flujo de ramas o conflictos al hacer merge, contacta con el equipo de **Ops-Admin**.
