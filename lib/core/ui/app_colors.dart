import 'package:flutter/material.dart';

import 'palette.dart';

class AppColors {
  const AppColors._();

  static const Color primary = Palette.primary;
  static const Color secondary = Palette.secondary;
  static const Color background = Palette.background;
  static const Color accent = Palette.accent;
  static const Color text = Palette.text;
  static const Color textMuted = Palette.textMuted;
  static const Color card = Palette.card;
  static const Color primaryLight = Palette.primarySoft;
  static const Color primaryDark = Palette.primaryStrong;
  static const Color secondaryLight = Palette.secondaryLight;
  static const Color secondaryExtraLight = Palette.secondaryExtraLight;
  static const Color primaryExtraLight = Palette.primaryExtraLight;
  static const Color tertiaryGreen = Palette.tertiaryGreen;
  static const Color tertiaryGreenLight = Palette.tertiaryGreenLight;
  static const Color accentLight = Palette.accentSoft;
  static const Color success = Palette.success;
  static const Color warning = Palette.warning;
  static const Color error = Palette.error;
  static const Color info = Palette.info;

  // Gradients
  static const LinearGradient headerGradient = Palette.heroGradient;
  static const LinearGradient successGradient = Palette.successGradient;
  static const LinearGradient premiumGreenGradient =
      Palette.premiumGreenGradient;
  static const LinearGradient softGreenGradient = Palette.softGreenGradient;
  static const LinearGradient vibrantGreenGradient =
      Palette.vibrantGreenGradient;
  static const LinearGradient warmGreenGradient = Palette.warmGreenGradient;

  // Shadows
  static const List<BoxShadow> softShadow = Palette.softShadow;
  static const List<BoxShadow> elevatedShadow = Palette.elevatedShadow;
  static const List<BoxShadow> compactShadow = Palette.compactShadow;
}
