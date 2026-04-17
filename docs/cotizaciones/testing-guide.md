# Guía de pruebas — Módulo Cotizaciones

## Credenciales seed

| Rol      | Email                  | Password      |
|----------|------------------------|---------------|
| Admin    | admin@incide.com       | Admin123!     |
| Provider | proveedor@incide.com   | Provider123!  |
| Client   | cliente@incide.com     | Client123!    |

---

## Flujo completo (orden obligatorio)

```
1. Login proveedor       → obtener JWT
2. Activar disponibilidad
3. Login cliente         → obtener JWT
4. Crear solicitud pública
5. Crear solicitud especial (dirigida al proveedor)
6. Login proveedor       → ver mapa
7. Proveedor cotiza la solicitud pública
8. Login cliente         → aceptar o rechazar cotización
```

---

## 1. Login

**POST** `/api/auth/login`

```json
{
  "email": "proveedor@incide.com",
  "password": "Provider123!"
}

{
  "email": "admin@incide.com",
  "password": "Admin123!"
}

{
  "email": "cliente@incide.com",
  "password": "Client123!"
}
```

> Guardar el `token` de la respuesta. Usarlo en el header:
> `Authorization: Bearer <token>`

---

## 2. Activar disponibilidad del proveedor

**PATCH** `/api/provider/availability`
**Rol:** Provider

```json
{
  "available": true
}
```

**Respuesta esperada `200`:**
```json
{
  "available": true
}
```

Para desactivar:
```json
{
  "available": false
}
```

---

## 3. Crear solicitud pública (como cliente)

**POST** `/api/cotizaciones/solicitudes`
**Rol:** Client

```json
{
  "serviceItemId": 1,
  "description": "Se rompió una tubería debajo del fregadero.",
  "estimatedBudget": 800,
  "preferredDate": "2026-04-20T10:00:00Z",
  "lat": 19.4370,
  "lng": -99.1350,
  "type": 0
}
```

> `type: 0` = Public. Cualquier proveedor afiliado la ve en el mapa.

**Respuesta esperada `201`:** objeto `ServiceRequestOutputDTO` con `id`.

---

## 4. Crear solicitud especial (dirigida al proveedor seed)

**POST** `/api/cotizaciones/solicitudes`
**Rol:** Client

```json
{
  "serviceItemId": 3,
  "description": "Necesito instalar 4 contactos en sala.",
  "estimatedBudget": 1500,
  "preferredDate": "2026-04-22T09:00:00Z",
  "lat": 19.4300,
  "lng": -99.1310,
  "type": 1,
  "targetProviderId": 1
}
```

> `type: 1` = Targeted. Solo el proveedor con `id: 1` la ve en su mapa.

---

## 5. Ver mapa de cotizaciones (como proveedor)

**GET** `/api/cotizaciones/mapa`
**Rol:** Provider

```
/api/cotizaciones/mapa?lat=19.4326&lng=-99.1332&maxDistanceKm=10
```

Con filtro de categoría opcional:
```
/api/cotizaciones/mapa?lat=19.4326&lng=-99.1332&maxDistanceKm=10&categoryId=1
```

**Respuesta esperada `200`:** lista de `ServiceRequestMapOutputDTO` ordenada por distancia, cada una con `distanceKm`.

---

## 6. Enviar cotización sobre una solicitud (como proveedor)

**POST** `/api/cotizaciones/solicitudes/{id}/cotizar`
**Rol:** Provider

```json
{
  "amount": 950.00,
  "currency": "MXN",
  "description": "Incluye mano de obra y refacciones básicas.",
  "estimatedHours": 3,
  "proposedDate": "2026-04-21T11:00:00Z"
}
```

**Respuesta esperada `201`:** objeto `CotizacionOutputDTO` con `status: "Submitted"`.

> Si el proveedor vuelve a llamar este endpoint sobre la misma solicitud, **actualiza** la cotización existente (upsert).

---

## 7. Ver mis solicitudes (como cliente)

**GET** `/api/cotizaciones/solicitudes/mias`
**Rol:** Client

> Devuelve todas las solicitudes del cliente con las cotizaciones recibidas anidadas.

Filtro opcional por status:

| Query param | Resultado |
|---|---|
| _(sin parámetro)_ | Todas (historial completo) |
| `?status=0` | Solo **Active** — esperando cotizaciones |
| `?status=1` | Solo **Assigned** — proveedor aceptado |
| `?status=2` | Solo **Completed** |
| `?status=3` | Solo **Cancelled** |

Ejemplo para ver solo las activas:
```
GET /api/cotizaciones/solicitudes/mias?status=0
```

---

## 8. Aceptar una cotización (como cliente)

**POST** `/api/cotizaciones/{cotizacionId}/accept`
**Rol:** Client — sin body.

**Respuesta esperada `200`:** cotización con `status: "Accepted"`.

> El sistema automáticamente:
> - Marca las demás cotizaciones de esa solicitud como `Rejected`.
> - Cambia el `status` de la solicitud a `Assigned`.

---

## 9. Rechazar una cotización individual (como cliente)

**POST** `/api/cotizaciones/{cotizacionId}/reject`
**Rol:** Client

```json
{
  "rejectReason": "El precio está fuera de mi presupuesto."
}
```

---

## 10. Ver mis cotizaciones enviadas (como proveedor)

**GET** `/api/cotizaciones/mias`
**Rol:** Provider

---

## 11. Retirar una cotización (como proveedor)

**DELETE** `/api/cotizaciones/{cotizacionId}`
**Rol:** Provider — sin body.

> ⚠️ `{cotizacionId}` es el `id` de la **cotización**, NO el `id` de la solicitud.
> El `id` lo obtienes de la respuesta del paso 6 (`POST .../cotizar`) o consultando:
>
> **GET** `/api/cotizaciones/mias` — devuelve todas tus cotizaciones enviadas con su `id`.

**Respuesta esperada `204 No Content`.**

---

## Errores posibles por endpoint

### PATCH `/api/provider/availability`

| Error | Causa |
|-------|-------|
| `401 Unauthorized` | Token ausente o expirado |
| `403 Forbidden` | El usuario no tiene rol `Provider` |
| `400 Bad Request` | El proveedor no está en estado `Affiliated` (ej. aún en `Registered` o `Rejected`) |

---

### POST `/api/cotizaciones/solicitudes`

| Error | Causa |
|-------|-------|
| `401 Unauthorized` | Token ausente o expirado |
| `403 Forbidden` | El usuario no tiene rol `Client` |
| `400` `"No client profile found for this user."` | El usuario autenticado no tiene perfil de cliente |
| `400` `"Service item X not found."` | El `serviceItemId` no existe o está eliminado |
| `400` `"TargetProviderId is required when Type is Targeted."` | Se envió `type: 1` sin `targetProviderId` |
| `400` `"Target provider not found or not affiliated."` | El proveedor destino no existe o no está afiliado |
| `422 Unprocessable` | `lat` fuera de rango `[-90, 90]` o `lng` fuera de `[-180, 180]` |

---

### GET `/api/cotizaciones/mapa`

| Error | Causa |
|-------|-------|
| `401 Unauthorized` | Token ausente o expirado |
| `403 Forbidden` | El usuario no tiene rol `Provider` |
| `400` `"No provider profile found for this user."` | El usuario no tiene perfil de proveedor |
| `400` `"Only affiliated providers can access the map."` | El proveedor no está en estado `Affiliated` |
| `400` `"You must be available to access the cotizaciones map."` | El proveedor tiene `available: false` |
| `400` (validación) | `lat`, `lng` o `maxDistanceKm` fuera de rango |

---

### POST `/api/cotizaciones/solicitudes/{id}/cotizar`

| Error | Causa |
|-------|-------|
| `401 / 403` | Sin token o rol incorrecto |
| `400` `"Only affiliated providers can submit cotizaciones."` | Proveedor no afiliado |
| `400` `"Service request X not found."` | ID de solicitud inexistente |
| `400` `"This service request is no longer active."` | La solicitud ya fue `Assigned`, `Completed` o `Cancelled` |
| `400` `"This service request is targeted to a different provider."` | Solicitud especial y este proveedor no es el destino |
| `400` `"Cannot update a cotizacion that is no longer submitted."` | Intento de actualizar una cotización ya aceptada, rechazada o retirada |

---

### POST `/api/cotizaciones/{id}/accept`

| Error | Causa |
|-------|-------|
| `401 / 403` | Sin token o rol incorrecto |
| `400` `"Cotizacion not found."` | ID inexistente o eliminado |
| `400` `"You are not the owner of this service request."` | La cotización pertenece a la solicitud de otro cliente |
| `400` `"This service request is no longer active."` | Ya fue asignada o cancelada |
| `400` `"Only submitted cotizaciones can be accepted."` | La cotización ya fue aceptada, rechazada o retirada |

---

### DELETE `/api/cotizaciones/{id}` (withdraw)

| Error | Causa |
|-------|-------|
| `401 / 403` | Sin token o rol incorrecto |
| `404` `"Cotizacion not found."` | ID inexistente o no pertenece al proveedor |
| `400` `"Only submitted cotizaciones can be withdrawn."` | La cotización ya fue aceptada o rechazada |
