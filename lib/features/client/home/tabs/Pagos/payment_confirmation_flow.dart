import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../models/saved_card_model.dart';
import 'payment_receipt_widgets.dart';
import 'payment_result_dialogs.dart';

// ─────────────────────────────────────────────────────────
// Punto de entrada: muestra el diálogo de confirmación
// ─────────────────────────────────────────────────────────
void showPaymentConfirmationFlow(
  BuildContext context, {
  required SavedCardModel card,
  required double monto,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => _CvvDialog(card: card, monto: monto, sheetCtx: context),
  );
}

// ─────────────────────────────────────────────────────────
// Diálogo 1: Confirmar CVV
// ─────────────────────────────────────────────────────────
class _CvvDialog extends StatefulWidget {
  final SavedCardModel card;
  final double monto;
  final BuildContext sheetCtx;

  const _CvvDialog({
    required this.card,
    required this.monto,
    required this.sheetCtx,
  });

  @override
  State<_CvvDialog> createState() => _CvvDialogState();
}

class _CvvDialogState extends State<_CvvDialog> {
  String _cvv = '';

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

  void _startPayment() {
    Navigator.pop(context); // Cierra el diálogo CVV
    _showProcessing(widget.sheetCtx, card: widget.card, monto: widget.monto);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mini tarjeta
            MiniCardPreview(card: widget.card, gradient: _gradient),
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
            // Campo CVV
            TextFormField(
              keyboardType: TextInputType.number,
              obscureText: true,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              onChanged: (v) => setState(() => _cvv = v),
              decoration: InputDecoration(
                hintText: 'CVV (3 dígitos)',
                hintStyle: const TextStyle(
                  color: AppColors.textHint,
                  fontSize: 13,
                ),
                filled: true,
                fillColor: AppColors.inputFill,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                prefixIcon: const Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.textGray,
                  size: 18,
                ),
                border: _border(AppColors.borderLight),
                enabledBorder: _border(AppColors.borderLight),
                focusedBorder: _border(AppColors.primaryBlue, width: 1.5),
              ),
            ),
            const SizedBox(height: 20),
            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
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
                    onPressed: _cvv.length >= 3 ? _startPayment : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.primaryBlue.withValues(
                        alpha: 0.4,
                      ),
                      disabledForegroundColor: Colors.white.withValues(
                        alpha: 0.7,
                      ),
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
            ),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1.0}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
}

// ─────────────────────────────────────────────────────────
// Diálogo 2: Procesando (indicador de carga)
// ─────────────────────────────────────────────────────────
void _showProcessing(
  BuildContext sheetCtx, {
  required SavedCardModel card,
  required double monto,
}) {
  showDialog(
    context: sheetCtx,
    barrierDismissible: false,
    builder: (processingCtx) {
      _procesarPago().then((exito) {
        if (!processingCtx.mounted) return;
        Navigator.pop(processingCtx);
        if (exito) {
          _showSuccess(sheetCtx, card: card, monto: monto);
        } else {
          _showError(sheetCtx, card: card, monto: monto);
        }
      });

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  strokeWidth: 3.5,
                  color: AppColors.primaryBlue,
                  backgroundColor: AppColors.primaryBlue.withValues(
                    alpha: 0.12,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Procesando pago…',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Por favor no cierres esta ventana.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textGray),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// ─────────────────────────────────────────────────────────
// Diálogo 3a: Pago exitoso con comprobante
// ─────────────────────────────────────────────────────────
void _showSuccess(
  BuildContext sheetCtx, {
  required SavedCardModel card,
  required double monto,
}) {
  showDialog(
    context: sheetCtx,
    builder: (ctx) => PaymentSuccessDialog(
      folio: _generateFolio(),
      fecha: _formatFecha(DateTime.now()),
      metodoPago: '${card.brandLabel} •••• ${card.lastFour}',
      monto: monto,
      onDismiss: () {
        Navigator.pop(ctx);
        Navigator.pop(sheetCtx);
      },
    ),
  );
}

// ─────────────────────────────────────────────────────────
// Diálogo 3b: Error con reintentar
// ─────────────────────────────────────────────────────────
void _showError(
  BuildContext sheetCtx, {
  required SavedCardModel card,
  required double monto,
}) {
  showDialog(
    context: sheetCtx,
    builder: (ctx) => PaymentErrorDialog(
      onCancel: () {
        Navigator.pop(ctx);
        Navigator.pop(sheetCtx);
      },
      onRetry: () {
        Navigator.pop(ctx);
        _showProcessing(sheetCtx, card: card, monto: monto);
      },
    ),
  );
}


// Simula llamada al backend — reemplazar con HTTP real
Future<bool> _procesarPago() async {
  await Future.delayed(const Duration(seconds: 2));
  // Simulación: 80% éxito, 20% fallo
  return Random().nextDouble() > 0.2;
}

String _generateFolio() {
  final rnd = Random();
  final letters = String.fromCharCodes(
    List.generate(3, (_) => rnd.nextInt(26) + 65),
  );
  final numbers = rnd.nextInt(900000) + 100000;
  return '$letters-$numbers';
}

String _formatFecha(DateTime dt) {
  const meses = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '${dt.day} ${meses[dt.month - 1]} ${dt.year}, $h:$m';
}
