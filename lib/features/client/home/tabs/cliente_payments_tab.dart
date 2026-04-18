import 'package:flutter/material.dart';

class PaymentsTab extends StatelessWidget {
  const PaymentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Mis Pagos en construcción',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }
}
