import 'package:flutter/material.dart';

class Palette {
  const Palette._();

  // Primary Red Shades
  static const Color primary = Color(0xFFE74C3C);
  static const Color primaryStrong = Color(0xFFC0392B);
  static const Color primarySoft = Color(0xFFF5B7B1);
  static const Color primaryExtraLight = Color(0xFFFADBD8);

  // Secondary Red Shades
  static const Color secondary = Color(0xFFD32F2F);
  static const Color secondarySoft = Color(0xFFEF9A9A);
  static const Color secondaryLight = Color(0xFFFCE4EC);
  static const Color secondaryExtraLight = Color(0xFFFCE4EC);

  // Tertiary Red Shade
  static const Color tertiaryGreen = Color(0xFFC62828);
  static const Color tertiaryGreenLight = Color(0xFFFFCDD2);

  // Accent & Complementary
  static const Color accent = Color(0xFFFFFFFF);
  static const Color accentSoft = Color(0xFFFAFAFA);

  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceTint = Color(0xFFFADBD8);
  static const Color card = surface;

  static const Color text = Color(0xFF1E1E1E);
  static const Color textMuted = Color(0xFF5D5D5D);
  static const Color outline = Color(0xFFF5B7B1);
  static const Color outlineSoft = Color(0xFFFADBD8);

  static const Color success = Color(0xFF27AE60);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primarySoft, primary, secondary],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primarySoft, primary, secondary],
  );

  // New Red Gradients
  static const LinearGradient premiumGreenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryLight, primary, primaryStrong],
  );

  static const LinearGradient softGreenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryExtraLight, primarySoft, secondaryLight],
  );

  static const LinearGradient vibrantGreenGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [tertiaryGreen, primary, secondaryLight],
  );

  static const LinearGradient warmGreenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent, secondaryLight],
  );

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
