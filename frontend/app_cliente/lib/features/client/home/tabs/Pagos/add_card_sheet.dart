import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:incide_core/core/theme/app_colors.dart';
import '../../models/saved_card_model.dart';
import '../../providers/saved_cards_provider.dart';

// ─────────────────────────────────────────────────────────
// Bottom Sheet: Agregar Tarjeta (estilo Mercado Libre)
// ─────────────────────────────────────────────────────────
class AddCardSheet extends ConsumerStatefulWidget {
  final double monto;
  final String titulo;

  const AddCardSheet({super.key, required this.monto, required this.titulo});

  static Future<void> show(
    BuildContext context, {
    required double monto,
    required String titulo,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddCardSheet(monto: monto, titulo: titulo),
    );
  }

  @override
  ConsumerState<AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends ConsumerState<AddCardSheet> {
  final _formKey = GlobalKey<FormState>();
  final _numCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  bool _showCvv = false;
  String _cardBrand = '';
  bool _isProcessing = false;

  // ── Detectar marca de tarjeta ────────────────────────────────────────────
  String _detectBrand(String num) {
    final n = num.replaceAll(' ', '');
    if (n.startsWith('4')) return 'visa';
    if (RegExp(r'^5[1-5]').hasMatch(n)) return 'mastercard';
    if (RegExp(r'^3[47]').hasMatch(n)) return 'amex';
    return '';
  }

  IconData _brandIcon() {
    switch (_cardBrand) {
      case 'visa':
        return Icons.credit_card_rounded;
      case 'mastercard':
        return Icons.credit_card_rounded;
      case 'amex':
        return Icons.credit_card_rounded;
      default:
        return Icons.credit_card_outlined;
    }
  }

  Color _brandColor() {
    switch (_cardBrand) {
      case 'visa':
        return const Color(0xFF1A1F71);
      case 'mastercard':
        return const Color(0xFFEB001B);
      case 'amex':
        return const Color(0xFF006FCF);
      default:
        return AppColors.textGray;
    }
  }

  String _brandLabel() {
    switch (_cardBrand) {
      case 'visa':
        return 'VISA';
      case 'mastercard':
        return 'Mastercard';
      case 'amex':
        return 'Amex';
      default:
        return '';
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isProcessing = false);

    // Guardar la tarjeta en el provider de tarjetas guardadas
    final digits = _numCtrl.text.replaceAll(' ', '');
    final lastFour = digits.length >= 4
        ? digits.substring(digits.length - 4)
        : digits;
    CardBrand brand;
    switch (_cardBrand) {
      case 'mastercard':
        brand = CardBrand.mastercard;
        break;
      case 'amex':
        brand = CardBrand.amex;
        break;
      default:
        brand = CardBrand.visa;
    }
    final newCard = SavedCardModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      lastFour: lastFour,
      holderName: _nameCtrl.text.toUpperCase().trim(),
      expiry: _expCtrl.text,
      brand: brand,
    );
    ref.read(savedCardsProvider.notifier).addCard(newCard);

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.successGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.successGreen,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '¡Pago exitoso!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tu pago por \$${widget.monto.toStringAsFixed(2)} MXN\nfue procesado correctamente.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textGray,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext); // Cierra el dialog
                    Navigator.pop(context); // Cierra el bottom sheet
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Entendido',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _numCtrl.dispose();
    _nameCtrl.dispose();
    _expCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: AppColors.borderDark,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

                // ── Header ──────────────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.credit_card_rounded,
                        color: AppColors.primaryBlue,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Agregar tarjeta',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            'Ingresa los datos de tu tarjeta',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textGray,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Brand badge
                    if (_cardBrand.isNotEmpty)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _brandColor().withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _brandColor().withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(_brandIcon(), color: _brandColor(), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              _brandLabel(),
                              style: TextStyle(
                                color: _brandColor(),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Tarjeta visual preview ───────────────────────────────────
                _CardPreview(
                  number: _numCtrl.text,
                  name: _nameCtrl.text,
                  expiry: _expCtrl.text,
                  brand: _cardBrand,
                ),

                const SizedBox(height: 24),

                // ── Número de tarjeta ────────────────────────────────────────
                _buildLabel('Número de tarjeta'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _numCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                    _CardNumberFormatter(),
                  ],
                  onChanged: (v) => setState(() {
                    _cardBrand = _detectBrand(v);
                  }),
                  decoration: _inputDec(
                    hint: '0000 0000 0000 0000',
                    suffixIcon: Icon(
                      _brandIcon(),
                      color: _cardBrand.isNotEmpty
                          ? _brandColor()
                          : AppColors.textHint,
                      size: 22,
                    ),
                  ),
                  validator: (v) {
                    final digits = (v ?? '').replaceAll(' ', '');
                    if (digits.length < 13) return 'Número inválido';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ── Nombre en la tarjeta ─────────────────────────────────────
                _buildLabel('Nombre del titular'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (_) => setState(() {}),
                  decoration: _inputDec(
                    hint: 'Como aparece en la tarjeta',
                    suffixIcon: const Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.textHint,
                      size: 20,
                    ),
                  ),
                  validator: (v) {
                    if ((v ?? '').trim().isEmpty) return 'Ingresa el nombre';
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ── Vencimiento + CVV ────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Vencimiento'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _expCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                              _ExpiryFormatter(),
                            ],
                            onChanged: (_) => setState(() {}),
                            decoration: _inputDec(
                              hint: 'MM/AA',
                              suffixIcon: const Icon(
                                Icons.calendar_today_rounded,
                                color: AppColors.textHint,
                                size: 18,
                              ),
                            ),
                            validator: (v) {
                              final parts = (v ?? '').split('/');
                              if (parts.length != 2) return 'Inválido';
                              final month = int.tryParse(parts[0]) ?? 0;
                              if (month < 1 || month > 12)
                                return 'Mes inválido';
                              if ((parts[1]).length < 2) return 'Año inválido';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('CVV / CVC'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _cvvCtrl,
                            keyboardType: TextInputType.number,
                            obscureText: !_showCvv,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(3),
                            ],
                            decoration: _inputDec(
                              hint: '•••',
                              suffixIcon: GestureDetector(
                                onTap: () =>
                                    setState(() => _showCvv = !_showCvv),
                                child: Icon(
                                  _showCvv
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  color: AppColors.textHint,
                                  size: 20,
                                ),
                              ),
                            ),
                            validator: (v) {
                              if ((v ?? '').length < 3) return 'CVV inválido';
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Nota seguridad
                Row(
                  children: const [
                    Icon(
                      Icons.lock_rounded,
                      size: 13,
                      color: AppColors.successGreen,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Tus datos están encriptados y protegidos',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Botón Pagar ───────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Pagar \$${widget.monto.toStringAsFixed(2)} MXN',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.textMedium,
        letterSpacing: 0.2,
      ),
    );
  }

  InputDecoration _inputDec({required String hint, Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.inputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.errorRed, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.errorRed, width: 1.8),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Preview visual de la tarjeta
// ─────────────────────────────────────────────────────────
class _CardPreview extends StatelessWidget {
  final String number;
  final String name;
  final String expiry;
  final String brand;

  const _CardPreview({
    required this.number,
    required this.name,
    required this.expiry,
    required this.brand,
  });

  @override
  Widget build(BuildContext context) {
    final displayNum = number.isEmpty
        ? '•••• •••• •••• ••••'
        : number.padRight(19, '•');
    final displayName = name.isEmpty ? 'NOMBRE TITULAR' : name.toUpperCase();
    final displayExp = expiry.isEmpty ? 'MM/AA' : expiry;

    Color cardStart;
    Color cardEnd;
    switch (brand) {
      case 'mastercard':
        cardStart = const Color(0xFF1C1C2E);
        cardEnd = const Color(0xFF2D2D44);
        break;
      case 'amex':
        cardStart = const Color(0xFF006FCF);
        cardEnd = const Color(0xFF0050A0);
        break;
      default:
        cardStart = AppColors.primaryBlue;
        cardEnd = const Color(0xFF2D55C8);
    }

    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cardStart, cardEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: cardStart.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Círculos decorativos
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: 20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(
                      Icons.contactless_rounded,
                      color: Colors.white54,
                      size: 22,
                    ),
                    if (brand.isNotEmpty)
                      Text(
                        brand.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  displayNum,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.5,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TITULAR',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 9,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'VENCE',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 9,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          displayExp,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Formatters
// ─────────────────────────────────────────────────────────
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 16; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final str = buffer.toString();
    return newValue.copyWith(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    String result = digits;
    if (digits.length >= 3) {
      result = '${digits.substring(0, 2)}/${digits.substring(2)}';
    } else if (digits.length == 2 &&
        oldValue.text.length < newValue.text.length) {
      result = '$digits/';
    }
    return newValue.copyWith(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}
