import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pago_model.dart';

// ─────────────────────────────────────────────────────────
//  PROVEEDORES DE PAGOS — Pestaña "Mis Pagos"
// ─────────────────────────────────────────────────────────

// ── Fuente única de datos mock ────────────────────────────────────────────
// TODO (Backend): Reemplazar con AsyncNotifierProvider que llame a
//   GET /api/client/payments  y mapee la respuesta con PagoModel.fromJson
final allPagosProvider = NotifierProvider<AllPagosNotifier, List<PagoModel>>(
  () {
    return AllPagosNotifier();
  },
);

class AllPagosNotifier extends Notifier<List<PagoModel>> {
  @override
  List<PagoModel> build() {
    return [
      PagoModel(
        id: 'p1',
        titulo: 'Instalación de AC',
        descripcion:
            'Pago por instalación de mini-split en recámara principal.',
        monto: 3200.0,
        estado: EstadoPago.pagado,
        fecha: DateTime(2026, 4, 20),
        metodoPago: 'Tarjeta •••• 4242',
        referencia: 'TXN-20260420-001',
      ),
      PagoModel(
        id: 'p2',
        titulo: 'Fuga de agua en cocina',
        descripcion: 'Reparación urgente de tubería bajo el fregadero.',
        monto: 850.0,
        estado: EstadoPago.pendiente,
        fecha: DateTime(2026, 4, 25),
        metodoPago: 'Transferencia SPEI',
      ),
      PagoModel(
        id: 'p3',
        titulo: 'Limpieza de Alfombras',
        descripcion: 'Limpieza profunda de 3 alfombras en sala y recámaras.',
        monto: 600.0,
        estado: EstadoPago.pagado,
        fecha: DateTime(2026, 4, 10),
        metodoPago: 'Tarjeta •••• 1234',
        referencia: 'TXN-20260410-003',
      ),

      PagoModel(
        id: 'p5',
        titulo: 'Instalación de regadera',
        descripcion:
            'Cambio completo de la regadera eléctrica en baño principal.',
        monto: 750.0,
        estado: EstadoPago.pagado,
        fecha: DateTime(2026, 3, 30),
        metodoPago: 'PayPal',
        referencia: 'TXN-20260330-005',
      ),
    ];
  }

  void marcarComoPagado(String pagoId, String metodoPago) {
    state = state.map((p) {
      if (p.id == pagoId) {
        return PagoModel(
          id: p.id,
          titulo: p.titulo,
          descripcion: p.descripcion,
          monto: p.monto,
          estado: EstadoPago.pagado,
          fecha: DateTime.now(),
          metodoPago: metodoPago,
          referencia: 'TXN-${DateTime.now().millisecondsSinceEpoch}',
        );
      }
      return p;
    }).toList();
  }
}

// ── Filtro activo de la pestaña de pagos ──────────────────────────────────
final selectedPagoFilterProvider =
    NotifierProvider<SelectedPagoFilterNotifier, EstadoPago?>(() {
      return SelectedPagoFilterNotifier();
    });

class SelectedPagoFilterNotifier extends Notifier<EstadoPago?> {
  @override
  EstadoPago? build() => null; // null = TODOS
  void update(EstadoPago? value) => state = value;
}

// ── Lista derivada ya filtrada por estado ─────────────────────────────────
final filteredPagosProvider = Provider<List<PagoModel>>((ref) {
  final filtroActivo = ref.watch(selectedPagoFilterProvider);
  final todos = ref.watch(allPagosProvider);
  if (filtroActivo == null) return todos;
  return todos.where((p) => p.estado == filtroActivo).toList();
});



final resumenPagosProvider = Provider<ResumenPagos>((ref) {
  final todos = ref.watch(allPagosProvider);
  final pagados = todos.where((p) => p.estado == EstadoPago.pagado).length;
  final pendientes = todos
      .where((p) => p.estado == EstadoPago.pendiente)
      .length;
  return ResumenPagos(
    pagosCompletados: pagados,
    pagosPendientes: pendientes,
    cantidadPagos: pagados + pendientes,
  );
});
