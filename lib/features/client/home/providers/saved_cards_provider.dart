import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/saved_card_model.dart';

// ─────────────────────────────────────────────────────────
// Provider de Tarjetas Guardadas
// ─────────────────────────────────────────────────────────
// TODO (Backend): Reemplazar datos mock con llamada a
//   GET /api/client/saved-cards  y POST /api/client/saved-cards

final savedCardsProvider =
    NotifierProvider<SavedCardsNotifier, List<SavedCardModel>>(
  SavedCardsNotifier.new,
);

class SavedCardsNotifier extends Notifier<List<SavedCardModel>> {
  @override
  List<SavedCardModel> build() {
    // Tarjetas de demostración — reemplazar con datos reales del backend
    return [
      const SavedCardModel(
        id: 'c1',
        lastFour: '4242',
        holderName: 'ANA LÓPEZ',
        expiry: '12/27',
        brand: CardBrand.visa,
      ),
      const SavedCardModel(
        id: 'c2',
        lastFour: '1234',
        holderName: 'ANA LÓPEZ',
        expiry: '08/26',
        brand: CardBrand.mastercard,
      ),
    ];
  }

  /// Agrega una nueva tarjeta a la lista
  void addCard(SavedCardModel card) {
    state = [card, ...state];
  }

  /// Elimina una tarjeta por ID
  void removeCard(String id) {
    state = state.where((c) => c.id != id).toList();
  }
}
