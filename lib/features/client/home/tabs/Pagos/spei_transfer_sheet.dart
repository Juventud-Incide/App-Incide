import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────
// Bottom Sheet: Transferencia SPEI
// ─────────────────────────────────────────────────────────
class SpeiTransferSheet extends StatefulWidget {
  final double monto;
  final String titulo;
  final VoidCallback onPaymentSuccess;

  const SpeiTransferSheet({
    super.key,
    required this.monto,
    required this.titulo,
    required this.onPaymentSuccess,
  });

  static Future<void> show(
    BuildContext context, {
    required double monto,
    required String titulo,
    required VoidCallback onPaymentSuccess,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SpeiTransferSheet(monto: monto, titulo: titulo, onPaymentSuccess: onPaymentSuccess),
    );
  }

  @override
  State<SpeiTransferSheet> createState() => _SpeiTransferSheetState();
}

class _SpeiTransferSheetState extends State<SpeiTransferSheet> {
  // Datos bancarios de ejemplo (reemplazar con datos reales del backend)
  static const _clabe = '646180157000000004';
  static const _banco = 'STP (Sistema de Transferencias y Pagos)';
  static const _beneficiario = 'INCIDE Servicios S.A. de C.V.';
  static const _concepto = 'PAGO-SERV-INCIDE';

  bool _copiedClabe = false;
  bool _copiedConcepto = false;

  Future<void> _copy(String text, bool isClabe) async {
    await Clipboard.setData(ClipboardData(text: text));
    setState(() {
      if (isClabe) {
        _copiedClabe = true;
      } else {
        _copiedConcepto = true;
      }
    });
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        if (isClabe) _copiedClabe = false;
        if (!isClabe) _copiedConcepto = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final montoFmt =
        '\$${widget.monto.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\.)'), (m) => '${m[1]},')} MXN';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        left: 24,
        right: 24,
        top: 8,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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

            // ── Header ──────────────────────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.account_balance_rounded,
                      color: Color(0xFF7C3AED), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Transferencia SPEI',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark)),
                      Text(
                        widget.titulo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textGray,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.successGreen.withOpacity(0.3)),
                  ),
                  child: Text(
                    montoFmt,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.successGreen),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Banner instrucción ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFF7C3AED).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: Color(0xFF7C3AED), size: 18),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Realiza la transferencia desde tu banco con los siguientes datos. El pago se confirmará en minutos.',
                      style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5B21B6),
                          fontWeight: FontWeight.w500,
                          height: 1.5),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Datos bancarios ──────────────────────────────────────────────
            _buildDataRow(
              label: 'Banco destino',
              value: _banco,
              icon: Icons.account_balance_outlined,
            ),
            const SizedBox(height: 12),
            _buildDataRow(
              label: 'Beneficiario',
              value: _beneficiario,
              icon: Icons.business_outlined,
            ),
            const SizedBox(height: 12),
            _buildCopyRow(
              label: 'CLABE interbancaria',
              value: _clabe,
              copied: _copiedClabe,
              onCopy: () => _copy(_clabe, true),
            ),
            const SizedBox(height: 12),
            _buildDataRow(
              label: 'Monto exacto a transferir',
              value: montoFmt,
              icon: Icons.attach_money_rounded,
              valueColor: AppColors.successGreen,
              bold: true,
            ),
            const SizedBox(height: 12),
            _buildCopyRow(
              label: 'Concepto de pago',
              value: _concepto,
              copied: _copiedConcepto,
              onCopy: () => _copy(_concepto, false),
            ),

            const SizedBox(height: 20),

            // ── Aviso ────────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFF59E0B).withOpacity(0.3)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.warning_amber_rounded,
                      color: Color(0xFFF59E0B), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Transfiere el monto exacto indicado. Pagos incorrectos pueden tardar más en procesarse.',
                      style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF92400E),
                          fontWeight: FontWeight.w500,
                          height: 1.5),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Botón Confirmar ──────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onPaymentSuccess();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  'Ya realicé la transferencia',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow({
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
    bool bold = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textGray),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textHint,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(
                        fontSize: 13,
                        color: valueColor ?? AppColors.textDark,
                        fontWeight:
                            bold ? FontWeight.w800 : FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyRow({
    required String label,
    required String value,
    required bool copied,
    required VoidCallback onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: copied
              ? AppColors.successGreen.withOpacity(0.4)
              : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textHint,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5)),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              key: ValueKey(copied),
              onTap: copied ? null : onCopy,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: copied
                      ? AppColors.successGreen.withOpacity(0.1)
                      : AppColors.primaryBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      copied
                          ? Icons.check_rounded
                          : Icons.copy_rounded,
                      size: 14,
                      color: copied
                          ? AppColors.successGreen
                          : AppColors.primaryBlue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      copied ? 'Copiado' : 'Copiar',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: copied
                            ? AppColors.successGreen
                            : AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
