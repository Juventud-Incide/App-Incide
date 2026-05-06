import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../models/saved_card_model.dart';

// ─────────────────────────────────────────────────────────
// Tile de tarjeta guardada
// ─────────────────────────────────────────────────────────
class SavedCardTile extends StatefulWidget {
  final SavedCardModel card;
  final double monto;
  final VoidCallback onDelete;

  const SavedCardTile({
    super.key,
    required this.card,
    required this.monto,
    required this.onDelete,
  });

  @override
  State<SavedCardTile> createState() => _SavedCardTileState();
}

class _SavedCardTileState extends State<SavedCardTile> {
  String _cvv = '';

  // ── Gradiente por marca ───────────────────────────────────
  LinearGradient get _gradient {
    final colors = switch (widget.card.brand) {
      CardBrand.visa => (AppColors.primaryBlue, const Color(0xFF2D55C8)),
      CardBrand.mastercard => (
        const Color(0xFF1C1C2E),
        const Color(0xFF2D2D44),
      ),
      CardBrand.amex => (const Color(0xFF006FCF), const Color(0xFF0050A0)),
    };
    return LinearGradient(
      colors: [colors.$1, colors.$2],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // ── Mini vista previa de tarjeta ──────────────────────────
  Widget _buildMiniCard() => Container(
    width: double.infinity,
    height: 100,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: _gradient,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(
              Icons.contactless_rounded,
              color: Colors.white54,
              size: 18,
            ),
            Text(
              widget.card.brandLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        Text(
          widget.card.maskedNumber,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ],
    ),
  );

  // ── Campo de CVV ──────────────────────────────────────────
  Widget _buildCvvField() => TextFormField(
    keyboardType: TextInputType.number,
    obscureText: true,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(3),
    ],
    onChanged: (v) => setState(() => _cvv = v),
    decoration: InputDecoration(
      hintText: 'CVV (3 dígitos)',
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
      filled: true,
      fillColor: AppColors.inputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      prefixIcon: const Icon(
        Icons.lock_outline_rounded,
        color: AppColors.textGray,
        size: 18,
      ),
      border: _border(AppColors.borderLight),
      enabledBorder: _border(AppColors.borderLight),
      focusedBorder: _border(AppColors.primaryBlue, width: 1.5),
    ),
  );

  OutlineInputBorder _border(Color color, {double width = 1.0}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );

  // ── Botones de acción ─────────────────────────────────────
  Widget _buildActionButtons(BuildContext dialogCtx, BuildContext sheetCtx) =>
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(dialogCtx),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: AppColors.borderDark),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: AppColors.textGray,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: _cvv.length >= 3
                  ? () {
                      Navigator.pop(dialogCtx);
                      _showSuccess(sheetCtx);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primaryBlue.withValues(
                  alpha: 0.4,
                ),
                disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Pagar',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      );

  // ── Diálogo: Confirmar CVV ────────────────────────────────
  void _confirmAndPay(BuildContext context) {
    setState(() => _cvv = '');
    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: StatefulBuilder(
            builder: (_, __) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMiniCard(),
                const SizedBox(height: 16),
                const Text(
                  'Confirmar pago',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '¿Pagar \$${widget.monto.toStringAsFixed(2)} MXN con ${widget.card.brandLabel} •••• ${widget.card.lastFour}?',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textGray,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                _buildCvvField(),
                const SizedBox(height: 20),
                _buildActionButtons(dialogCtx, context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Diálogo: Pago exitoso ─────────────────────────────────
  void _showSuccess(BuildContext context) {
    showDialog(
      context: context,
      builder: (successCtx) => Dialog(
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
                  color: AppColors.successGreen.withValues(alpha: 0.1),
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
                    Navigator.pop(successCtx);
                    Navigator.pop(context);
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

  // ── Build principal ───────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.card.id),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: AppColors.errorRed.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete_rounded,
          color: AppColors.errorRed,
          size: 22,
        ),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Eliminar tarjeta',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Text(
            '¿Eliminar tarjeta ${widget.card.brandLabel} •••• ${widget.card.lastFour}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Eliminar',
                style: TextStyle(color: AppColors.errorRed),
              ),
            ),
          ],
        ),
      ),
      onDismissed: (_) => widget.onDelete(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _confirmAndPay(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: _gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _gradient.colors.first.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.contactless_rounded,
                  color: Colors.white54,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.card.maskedNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${widget.card.holderName}  ·  ${widget.card.expiry}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.card.brandLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
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
}
