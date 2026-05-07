import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF2ECC71);
  static const Color secondary = Color(0xFF27AE60);
  static const Color background = Color(0xFFF7FFF9);
  static const Color accent = Color(0xFFFFC857);
  static const Color text = Color(0xFF1E1E1E);
  static const Color card = Colors.white;

  // Extended Colors for Modern UI
  static const Color primaryLight = Color(0xFF7BE7A8);
  static const Color primaryDark = Color(0xFF1FA853);
  static const Color secondaryLight = Color(0xFF5AC89F);
  static const Color accentLight = Color(0xFFFFD97D);

  // Semantic Colors
  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  // Gradient Definitions
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7BE7A8), primary, secondary],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary, secondary],
  );

  // Modern Shadow Definition
  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 18,
      offset: Offset(0, 8),
      spreadRadius: -2,
    ),
  ];

  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Color(0x1E000000),
      blurRadius: 24,
      offset: Offset(0, 12),
      spreadRadius: -4,
    ),
  ];

  static const List<BoxShadow> compactShadow = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 12,
      offset: Offset(0, 4),
      spreadRadius: -2,
    ),
  ];
}
