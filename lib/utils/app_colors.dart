import 'package:flutter/material.dart';

class AppColors {
  static const Color bgDark = Color(0xFF0A0F1E);
  static const Color surface = Color(0xFF111827);
  static const Color surface2 = Color(0xFF1A2236);
  static const Color accent = Color(0xFF3B82F6);
  static const Color accent2 = Color(0xFF06B6D4);
  static const Color accent3 = Color(0xFF8B5CF6);
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecond = Color(0xFF94A3B8);
  static const Color textThird = Color(0xFF64748B);
  static const Color border = Color(0xFF1E2D45);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF0A0F1E), Color(0xFF0B1628), Color(0xFF0A0F1E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );
  static const TextStyle heading2 = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static const TextStyle heading3 = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  static const TextStyle bodySecond = TextStyle(
    fontSize: 13,
    color: AppColors.textSecond,
    height: 1.5,
  );
  static const TextStyle label = TextStyle(
    fontSize: 11,
    color: AppColors.textThird,
    letterSpacing: 0.8,
    fontWeight: FontWeight.w500,
  );
}
