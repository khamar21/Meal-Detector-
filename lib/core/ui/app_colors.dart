import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFF2ECC71);
  static const Color secondary = Color(0xFF27AE60);
  static const Color background = Color(0xFFF7FFF9);
  static const Color accent = Color(0xFFFFC857);
  static const Color text = Color(0xFF1E1E1E);
  static const Color card = Colors.white;

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7BE7A8), primary, secondary],
  );

  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 18,
      offset: Offset(0, 8),
      spreadRadius: -2,
    ),
  ];
}
