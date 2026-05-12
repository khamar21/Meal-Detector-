import 'package:flutter/material.dart';

class Palette {
  const Palette._();

  // Primary Green Shades
  static const Color primary = Color(0xFF2ECC71);
  static const Color primaryStrong = Color(0xFF1FA853);
  static const Color primarySoft = Color(0xFF7BE7A8);
  static const Color primaryExtraLight = Color(0xFFE8F8F0);

  // Secondary Green Shades
  static const Color secondary = Color(0xFF27AE60);
  static const Color secondarySoft = Color(0xFF5AC89F);
  static const Color secondaryLight = Color(0xFF52D4A5);
  static const Color secondaryExtraLight = Color(0xFFD5F4E6);

  // Tertiary Green Shade
  static const Color tertiaryGreen = Color(0xFF16A34A);
  static const Color tertiaryGreenLight = Color(0xFFC6F6D5);

  // Accent & Complementary
  static const Color accent = Color(0xFFFFC857);
  static const Color accentSoft = Color(0xFFFFD97D);

  static const Color background = Color(0xFFF7FFF9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceTint = Color(0xFFE9F9EF);
  static const Color card = surface;

  static const Color text = Color(0xFF1E1E1E);
  static const Color textMuted = Color(0xFF53635A);
  static const Color outline = Color(0xFFD3E7DA);
  static const Color outlineSoft = Color(0xFFE2F1E8);

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

  // New Green Gradients
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
