# Referencia de endpoints — Módulo Pagos

Base URL: `/api/payments`

---

## POST `/api/payments/initiate`

**Rol:** Client  
**Descripción:** Crea un `PaymentIntent` en Stripe y registra el pago en BD con estado `Pending`. Idempotente: si ya existe un pago `Pending` para la misma cotización, devuelve el existente.

**Prerequisito:** la cotización debe estar en estado `Accepted` (el cliente la aceptó previamente con `POST /api/cotizaciones/{id}/accept`).

**Body:**
```json
{
  "cotizacionId": 5
}
```

**Respuesta `200`:**
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

| Error | Causa |
|-------|-------|
| `401 / 403` | Sin token o rol incorrecto |
| `404` | `cotizacionId` no existe |
| `400` `"This cotizacion does not belong to you."` | La cotización es de otro cliente |
| `400` `"Only accepted cotizaciones can be paid."` | La cotización no fue aceptada aún |

---

## POST `/api/payments/webhook`

**Rol:** Anónimo (Stripe llama a este endpoint)  
**Descripción:** Recibe eventos de Stripe. Valida la firma con `Stripe-Signature`. Procesa:

| Evento Stripe | Acción |
|---|---|
| `payment_intent.succeeded` | `Payment.Status = Succeeded`, guarda `PaidAt`, dispara correos stub |
| `payment_intent.payment_failed` | `Payment.Status = Failed`, guarda `FailureReason` |
| `charge.refunded` | `Payment.Status = Refunded` |

Idempotente por `event.Id` (campo `StripeLastEventId` en BD).

**Header requerido:** `Stripe-Signature: t=...,v1=...`  
**Body:** payload crudo de Stripe (no JSON parseado).

**Respuesta `200`:** evento procesado correctamente.  
**Respuesta `400`:** firma inválida.

---

## GET `/api/payments/mios`

**Rol:** Client  
**Descripción:** Lista todos los pagos del cliente autenticado, ordenados por fecha descendente.

**Respuesta `200`:**
```json
[
  {
    "id": 1,
    "folio": "PAY-000001",
    "cotizacionId": 5,
    "status": "Succeeded",
    "amount": 950.00,
    "currency": "MXN",
    "providerName": "Juan Pérez",
    "failureReason": null,
    "creationDate": "2026-05-05T18:00:00Z",
    "paidAt": "2026-05-05T18:02:30Z",
    "releasedAt": null
  }
]
```

---

## GET `/api/payments/{id}`

**Rol:** Client, Provider o Admin  
**Descripción:** Detalle de un pago. Solo accesible para el cliente o proveedor involucrado, o un Admin.

**Respuesta `200`:** mismo shape que el item de `GET /mios`.  
**Respuesta `404`:** el pago no existe o no tienes acceso.

---

## POST `/api/payments/{id}/release`

**Rol:** Client  
**Descripción:** El cliente confirma que el trabajo fue completado y libera los fondos (marcado lógico en BD). Solo aplica a pagos en estado `Succeeded`.

**Body:** vacío (sin body).

**Respuesta `200`:**
```json
{
  "id": 1,
  "folio": "PAY-000001",
  "status": "Released",
  "releasedAt": "2026-05-06T10:00:00Z",
  ...
}
```

| Error | Causa |
|-------|-------|
| `404` | Pago no encontrado |
| `400` `"This payment does not belong to you."` | El pago es de otro cliente |
| `400` `"Only succeeded payments can be released."` | El pago aún está `Pending` o `Failed` |

---

## Estados del pago (`PaymentStatus`)

| Valor | Descripción |
|-------|-------------|
| `Pending` | PaymentIntent creado, esperando confirmación del cliente |
| `Succeeded` | Stripe confirmó el pago |
| `Failed` | El pago falló (ver `failureReason`) |
| `Released` | Cliente confirmó trabajo terminado — fondos listos para transferir |
| `Refunded` | Stripe procesó un reembolso |
| `Cancelled` | Reservado para cancelaciones futuras |
