import 'package:flutter/material.dart';

class ClientQuotingScreen extends StatelessWidget {
  final String categoryId;

  const ClientQuotingScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Cotizaciones'),
      ),
      body: Center(
        child: Text(
          'fljuo de Cotizacionesen proceso',
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
