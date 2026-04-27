// ─────────────────────────────────────────────────────────
// Modelo de Pago — Pestaña "Mis Pagos"
// ─────────────────────────────────────────────────────────
//
// TODO (Backend): Este modelo debe reflejar el JSON de tu endpoint:
// GET /api/client/payments
// Respuesta esperada por ítem:
// {
//   "id": "p1",
//   "titulo": "Fuga de agua en cocina",
//   "descripcion": "Reparación urgente de tubería...",
//   "monto": 850.0,
//   "estado": "pagado"  // "pagado" | "pendiente"
//   "fecha": "2026-04-20T10:30:00Z",
//   "metodoPago": "Tarjeta •••• 4242"
// }

enum EstadoPago { pagado, pendiente }

class PagoModel {
  final String id;
  final String titulo;
  final String descripcion;
  final double monto;
  final EstadoPago estado;
  final DateTime fecha;
  final String metodoPago;
  final String? referencia;

  const PagoModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.monto,
    required this.estado,
    required this.fecha,
    required this.metodoPago,
    this.referencia,
  });

  // TODO (Backend): Descomentar al conectar la API real.
  // factory PagoModel.fromJson(Map<String, dynamic> json) {
  //   return PagoModel(
  //     id: json['id'] as String,
  //     titulo: json['titulo'] as String,
  //     descripcion: json['descripcion'] as String,
  //     monto: (json['monto'] as num).toDouble(),
  //     estado: _estadoFromString(json['estado'] as String),
  //     fecha: DateTime.parse(json['fecha'] as String),
  //     metodoPago: json['metodoPago'] as String,
  //     referencia: json['referencia'] as String?,
  //   );
  // }
  //
  // static EstadoPago _estadoFromString(String value) {
  //   switch (value) {
  //     case 'pendiente': return EstadoPago.pendiente;
  //     default:          return EstadoPago.pagado;
  //   }
  // }
}
