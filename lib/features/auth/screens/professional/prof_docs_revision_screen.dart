import 'package:app_incide/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_approved_card.dart';
import '../../widgets/custom_correction_card.dart';

class ProfDocsRevisionScreen extends StatefulWidget {
  const ProfDocsRevisionScreen({super.key});

  @override
  State<ProfDocsRevisionScreen> createState() => _ProfDocsRevisionScreenState();
}

class _ProfDocsRevisionScreenState extends State<ProfDocsRevisionScreen> {
  // --- MOCK DATA: Simulamos qué documentos pidió el equipo que se corrijan ---
  bool _ineFixed = false;
  bool _antecedentesFixed = false;

  // El botón final solo se activa si los documentos con error ya fueron actualizados
  bool get _canResubmit => _ineFixed && _antecedentesFixed;

  void _showUploadBottomSheet(String docName, VoidCallback onSuccess) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Re-subir $docName',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.primaryBlue,
                  ),
                  title: const Text('Tomar nueva Fotografía'),
                  onTap: () {
                    Navigator.pop(context);
                    onSuccess();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- HEADER ---
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Text(
                            'Acción Requerida',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Hemos revisado tu documentación y encontramos algunos detalles. Por favor, corrige los archivos marcados en rojo para continuar con tu activación.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textGray,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // --- DOCUMENTOS CON ERROR ---
                    const Text(
                      'ARCHIVOS A CORREGIR:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 10),

                    CustomCorrectionCard(
                      title: 'Identificación Oficial (INE)',
                      adminComment:
                          'La fotografía trasera está borrosa y no se distinguen los datos. Por favor, tómala con mejor iluminación.',
                      isFixed: _ineFixed,
                      onTap: () => _showUploadBottomSheet(
                        'INE',
                        () => setState(() => _ineFixed = true),
                      ),
                    ),

                    CustomCorrectionCard(
                      title: 'Carta de No Antecedentes',
                      adminComment:
                          'El documento que subiste expiró hace 2 meses. Necesitamos uno vigente.',
                      isFixed: _antecedentesFixed,
                      onTap: () => _showUploadBottomSheet(
                        'Antecedentes',
                        () => setState(() => _antecedentesFixed = true),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- DOCUMENTOS APROBADOS ---
                    const Text(
                      'DOCUMENTOS APROBADOS (No requieren acción):',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textGray,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const CustomApprovedCard(title: 'Comprobante de Domicilio'),
                    const CustomApprovedCard(title: 'Cédula Profesional'),
                    const CustomApprovedCard(title: 'Fotografía de Perfil'),
                  ],
                ),
              ),
            ),

            // --- BOTÓN INFERIOR ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _canResubmit
                      ? () {
                          // Lo mandamos a la pantalla de éxito de documentos que ya hicimos
                          context.goNamed('prof_docs_success');
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canResubmit
                        ? AppColors.primaryBlue
                        : Colors.grey[300],
                    foregroundColor: _canResubmit
                        ? Colors.white
                        : Colors.grey[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Volver a Enviar Documentos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
