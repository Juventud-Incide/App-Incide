import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';

void main() {
  runApp(const ProviderScope(child: IncideApp()));
}

class IncideApp extends StatelessWidget {
  const IncideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'INCIDE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const PlaceholderScreen(),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.handyman, size: 80, color: AppColors.accentYellow),
            const SizedBox(height: 24),
            const Text(
              'INCIDE App\nInicializada Correctamente',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
