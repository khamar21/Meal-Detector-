import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/api_service.dart';
import 'app/app_shell.dart';
import 'core/ui/app_colors.dart';
import 'core/ui/palette.dart';

void main() {
  debugPrint('API_BASE_URL resolved to: ${ApiService.baseUrl}');
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData _buildTheme() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      error: Color(0xFFC0392B),
      onError: Colors.white,
      surface: AppColors.background,
      onSurface: AppColors.text,
      surfaceContainerHighest: Color(0xFFFADBD8),
      onSurfaceVariant: Color(0xFF5D5D5D),
      outline: Color(0xFFF5B7B1),
      outlineVariant: Palette.primaryExtraLight,
      tertiary: AppColors.accent,
      onTertiary: Color(0xFF1E1E1E),
    );

    final textTheme = GoogleFonts.poppinsTextTheme().copyWith(
      headlineLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w800,
        color: AppColors.text,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.w800,
        color: AppColors.text,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      titleLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      titleMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        height: 1.35,
        color: AppColors.text,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        height: 1.35,
        color: AppColors.text,
      ),
      bodySmall: GoogleFonts.poppins(color: const Color(0xFF53635A)),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.text,
      ),
      iconTheme: const IconThemeData(color: AppColors.text),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 2,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondary,
          side: const BorderSide(color: AppColors.secondary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        shadowColor: Colors.black.withValues(alpha: 0.08),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Palette.primaryExtraLight.withValues(alpha: 0.6),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Palette.secondaryLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Palette.secondaryLight,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        floatingLabelStyle: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const AppShell(),
    );
  }
}
