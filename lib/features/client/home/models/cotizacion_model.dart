// ─────────────────────────────────────────────────────────
// Modelo de Cotización — Task #116
// ─────────────────────────────────────────────────────────
//
// TODO (Backend): Este modelo debe reflejar el JSON de tu endpoint:
// GET /api/client/quotes
// Respuesta esperada por ítem:
// {
//   "id": "q1",
//   "titulo": "Fuga de agua en cocina",
//   "descripcion": "Reparación urgente de tubería...",
//   "precioEstimado": 850.0,
//   "estado": "en_espera"  // "en_espera" | "aceptada" | "terminada"
// }

enum EstadoCotizacion { enEspera, aceptada, terminada }

class CotizacionModel {
  final String id;
  final String titulo;
  final String descripcion;
  final double precioEstimado;
  final EstadoCotizacion estado;

  const CotizacionModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.precioEstimado,
    required this.estado,
  });

  // TODO (Backend): Descomentar al conectar la API real.
  // factory CotizacionModel.fromJson(Map<String, dynamic> json) {
  //   return CotizacionModel(
  //     id: json['id'] as String,
  //     titulo: json['titulo'] as String,
  //     descripcion: json['descripcion'] as String,
  //     precioEstimado: (json['precioEstimado'] as num).toDouble(),
  //     estado: _estadoFromString(json['estado'] as String),
  //   );
  // }
  //
  // static EstadoCotizacion _estadoFromString(String value) {
  //   switch (value) {
  //     case 'aceptada':  return EstadoCotizacion.aceptada;
  //     case 'terminada': return EstadoCotizacion.terminada;
  //     default:          return EstadoCotizacion.enEspera;
  //   }
  // }
}
