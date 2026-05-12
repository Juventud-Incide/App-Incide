// ─────────────────────────────────────────────────────────
// Modelo de Tarjeta Guardada
// ─────────────────────────────────────────────────────────
class SavedCardModel {
  final String id;
  final String lastFour;
  final String holderName;
  final String expiry; // formato MM/AA
  final CardBrand brand;

  const SavedCardModel({
    required this.id,
    required this.lastFour,
    required this.holderName,
    required this.expiry,
    required this.brand,
  });

  String get maskedNumber => '•••• •••• •••• $lastFour';

  String get brandLabel {
    switch (brand) {
      case CardBrand.visa:
        return 'VISA';
      case CardBrand.mastercard:
        return 'Mastercard';
      case CardBrand.amex:
        return 'Amex';
    }
  }
}

enum CardBrand { visa, mastercard, amex }
