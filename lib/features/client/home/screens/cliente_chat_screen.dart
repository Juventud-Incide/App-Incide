import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/cotizacion_model.dart';

class ClienteChatScreen extends StatelessWidget {
  final CotizacionModel cotizacion;

  const ClienteChatScreen({super.key, required this.cotizacion});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        title: Text(
          'Chat: ${cotizacion.titulo}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 1,
        shadowColor: Colors.black12,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(height: 16),
            Text(
              'Chat exclusivo para:\n${cotizacion.titulo}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Chat en proceso de desarrollo. ${cotizacion.id}',
              style: const TextStyle(fontSize: 14, color: AppColors.textGray),
            ),
          ],
        ),
      ),
    );
  }
}
