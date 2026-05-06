# Configuración — Módulo Pagos (Stripe)

## Cuenta de Stripe

1. Crear cuenta en [https://stripe.com](https://stripe.com) (modo test activado por defecto).
2. Ir a **Developers → API keys** y copiar:
   - `Publishable key` → `pk_test_...`
   - `Secret key` → `sk_test_...`

---

## Variables de entorno

Las keys **nunca** van en archivos committeados. Cargarlas como variables de entorno (ASP.NET Core las lee automáticamente con prefijo `Stripe__`):

### Windows (PowerShell — sesión actual)

```powershell
$env:Stripe__SecretKey      = "sk_test_..."
$env:Stripe__PublishableKey = "pk_test_..."
$env:Stripe__WebhookSecret  = "whsec_..."   # se obtiene en el paso de Stripe CLI
```

### Linux / macOS

```bash
export Stripe__SecretKey="sk_test_..."
export Stripe__PublishableKey="pk_test_..."
export Stripe__WebhookSecret="whsec_..."
```

### Docker Compose

```yaml
environment:
  - Stripe__SecretKey=sk_test_...
  - Stripe__PublishableKey=pk_test_...
  - Stripe__WebhookSecret=whsec_...
```

---

## Stripe CLI (pruebas locales de webhook)

### Instalación

```powershell
# Windows con Scoop
scoop install stripe

# O descargar el binario desde https://stripe.com/docs/stripe-cli
```

### Uso

```bash
# 1. Autenticarse
stripe login

# 2. Redirigir eventos al backend local (ajustar puerto según el que use dotnet run)
stripe listen --forward-to https://localhost:7001/api/payments/webhook

# La CLI imprime algo como:
# > Ready! Your webhook signing secret is whsec_abc123...
# Copiar ese valor y setearlo en Stripe__WebhookSecret
```

---

## Reiniciar backend con las variables seteadas

```bash
cd backend/backend
dotnet run
```

La migración `AddPayments` se aplica automáticamente al iniciar en Development.
