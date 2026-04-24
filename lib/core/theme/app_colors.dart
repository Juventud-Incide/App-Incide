import 'package:flutter/material.dart';

class AppColors {
  // ==========================================
  // 1. COLORES DE MARCA (Brand)
  // ==========================================
  static const Color primaryBlue = Color(0xFF1E3A8A);
  static const Color accentYellow = Color(0xFFFACC15);

  // ==========================================
  // 2. FONDOS Y SUPERFICIES (Backgrounds)
  // ==========================================
  static const Color backgroundWhite = Color(0xFFF9FAFB); // Fondo de pantallas
  static const Color inputFill = Color(
    0xFFF8F9FA,
  ); // Gris ultraclaro para rellenar TextFields

  // ==========================================
  // 3. TIPOGRAFÍA (Textos)
  // ==========================================
  static const Color textDark = Color(0xFF1F2937); // Títulos principales
  static const Color textMedium = Color(0xFF4B5563); // Etiquetas (Labels)
  static const Color textGray = Color(0xFF6B7280); // Párrafos y subtítulos
  static const Color textHint = Color(
    0xFF9CA3AF,
  ); // Textos fantasma (Ej. ejemplo@correo.com)

  // ==========================================
  // 4. BORDES Y SEPARADORES (Borders)
  // ==========================================
  static const Color borderLight = Color(0xFFE5E7EB); // Divisores suaves
  static const Color borderDark = Color(
    0xFFD1D5DB,
  ); // Bordes de TextFields apagados

  // ==========================================
  // 5. ESTADOS DEL SISTEMA (Status)
  // ==========================================
  static const Color successGreen = Color(0xFF10B981);
  static const Color errorRed = Color(0xFFEF4444); // Estandarizado para errores
}
