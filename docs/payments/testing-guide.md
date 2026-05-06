# Guía de pruebas — Módulo Pagos

## Credenciales seed

| Rol      | Email                | Password     |
|----------|----------------------|--------------|
| Admin    | admin@incide.com     | Admin123!    |
| Provider | proveedor@incide.com | Provider123! |
| Client   | cliente@incide.com   | Client123!   |

---

## Prerequisitos

1. Backend corriendo: `cd backend/backend && dotnet run`
2. Stripe CLI corriendo en otra terminal: `stripe listen --forward-to https://localhost:7001/api/payments/webhook`
3. Variables de entorno seteadas (ver [setup.md](setup.md))

---

## Flujo completo (orden obligatorio)

```
1. Login como proveedor     → obtener JWT proveedor
2. Login como cliente       → obtener JWT cliente
3. Crear solicitud pública  → obtener serviceRequestId
4. Proveedor cotiza         → obtener cotizacionId
5. Cliente acepta cotización
6. Cliente inicia pago      → obtener clientSecret
7. Stripe CLI simula pago exitoso
8. Verificar Payment = Succeeded en BD
9. Cliente libera fondos    → Payment = Released
```

---

## 1. Login

**POST** `/api/auth/login`

```json
{ "email": "cliente@incide.com", "password": "Client123!" }
{ "email": "proveedor@incide.com", "password": "Provider123!" }
```

> Guardar el `token` de cada respuesta. Usarlo en el header:
> `Authorization: Bearer <token>`

---

## 2. Crear solicitud pública (como cliente)

**POST** `/api/cotizaciones/solicitudes`  
**Rol:** Client

```json
{
  "serviceItemId": 1,
  "description": "Prueba de integración de pagos.",
  "estimatedBudget": 1000,
  "preferredDate": "2026-06-01T10:00:00Z",
  "lat": 19.4326,
  "lng": -99.1332,
  "type": 0
}
```

> Guardar el `id` de la respuesta como `{requestId}`.

---

## 3. Proveedor cotiza

**POST** `/api/cotizaciones/solicitudes/{requestId}/cotizar`  
**Rol:** Provider

```json
{
  "amount": 950.00,
  "currency": "MXN",
  "description": "Mano de obra + materiales.",
  "estimatedHours": 3
}
```

> Guardar el `id` de la respuesta como `{cotizacionId}`.

---

## 4. Cliente acepta la cotización

**POST** `/api/cotizaciones/{cotizacionId}/accept`  
**Rol:** Client — sin body.

**Respuesta esperada `200`:** `status: "Accepted"`.

---

## 5. Iniciar pago

**POST** `/api/payments/initiate`  
**Rol:** Client

```json
{
  "cotizacionId": {cotizacionId}
}
```

**Respuesta esperada `200`:**
```json
{
  "id": 1,
  "folio": "PAY-000001",
  "clientSecret": "pi_3abc..._secret_xyz...",
  "publishableKey": "pk_test_...",
  "amount": 950.00,
  "currency": "MXN"
}
```

> Verificar en BD: `SELECT * FROM "Payments"` → `Status = 0` (Pending).

---

## 6. Simular pago exitoso con Stripe CLI

```bash
stripe trigger payment_intent.succeeded
```

> La CLI dispara el evento usando el último PaymentIntent creado.  
> Para especificar uno en concreto:
> ```bash
> stripe trigger payment_intent.succeeded --override payment_intent:id=pi_3abc...
> ```

**Logs del backend esperados:**
```
[PAYMENT-EMAIL → CLIENTE] Para: cliente@incide.com ...
[PAYMENT-EMAIL → PROVEEDOR] Para: proveedor@incide.com ...
```

> Verificar en BD: `SELECT Status, PaidAt FROM "Payments"` → `Status = 1` (Succeeded) + `PaidAt` poblado.

---

## 7. Ver historial de pagos

**GET** `/api/payments/mios`  
**Rol:** Client

**Respuesta esperada `200`:** lista con el pago en `status: "Succeeded"`.

---

## 8. Liberar fondos

**POST** `/api/payments/{id}/release`  
**Rol:** Client — sin body.

**Respuesta esperada `200`:** `status: "Released"`, `releasedAt` poblado.

> Verificar en BD: `SELECT Status, ReleasedAt FROM "Payments"` → `Status = 3` (Released).

---

## 9. Probar idempotencia del webhook

Reenviar el mismo evento desde el Dashboard de Stripe o con la CLI:
```bash
stripe events resend {event_id}
```

> El backend debe responder `200` pero **no** debe crear un registro duplicado ni cambiar el estado.  
> Verificar: `SELECT StripeLastEventId FROM "Payments"` — debe coincidir con el `event.Id` ya procesado.

---

## Errores posibles

| Escenario | Error esperado |
|-----------|----------------|
| Cotización no aceptada | `400 "Only accepted cotizaciones can be paid."` |
| Firma de webhook inválida | `400 "Invalid Stripe webhook signature."` |
| Liberar un pago Pending | `400 "Only succeeded payments can be released."` |
| Pago de otro cliente | `400 "This payment does not belong to you."` |
