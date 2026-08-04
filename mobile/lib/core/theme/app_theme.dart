// ====================================================================
// GEOSYNC - ENTERPRISE MODERN THEME & DESIGN TOKENS
// ====================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette - Clean Corporate Light Mode (Navy Blue & Soft Mint)
  static const Color primaryColor = Color(0xFF142F55); // Deep Corporate Navy Blue
  static const Color secondaryColor = Color(0xFF106066); // Deep Teal Accent
  static const Color backgroundColor = Color(0xFFF7F9FC); // Soft Clean White/Blue-Gray
  static const Color surfaceColor = Colors.white;
  static const Color cardColor = Colors.white;
  static const Color errorColor = Color(0xFFE11D48); // Rose Red
  static const Color textPrimary = Color(0xFF1E293B); // Charcoal Slate
  static const Color textSecondary = Color(0xFF64748B); // Muted Slate Gray
  static const Color borderLight = Color(0xFFE2E8F0); // Subtle Border Color

  // Alert Badge Colors (Mint / Teal tint for Location Info)
  static const Color mintAlertBg = Color(0xFFE4F3EF);
  static const Color mintAlertText = Color(0xFF0F6058);

  // Active Bottom Nav Pill & HRD Accent Tokens
  static const Color mintNavPill = Color(0xFF80ECD6); // Bright Cyan-Mint Pill for active tab
  static const Color tealButton = Color(0xFF006C62); // Deep Teal Primary Button
  static const Color darkNavyHeader = Color(0xFF0A2540); // Rich Corporate Navy

  // Status Badges (Hadir/Aktif/Terlambat/Sakit)
  static const Color badgeMintBg = Color(0xFFE2F9F4);
  static const Color badgeMintText = Color(0xFF0D7B6D);
  static const Color badgeRedBg = Color(0xFFFDEDED);
  static const Color badgeRedText = Color(0xFFD32F2F);
  static const Color badgeGreyBg = Color(0xFFF1F5F9);
  static const Color badgeGreyText = Color(0xFF64748B);

  // Card Box Shadow for Modern Corporate elevation
  static List<BoxShadow> softCardShadow = [
    BoxShadow(
      color: const Color(0xFF1E293B).withValues(alpha: 0.05),
      blurRadius: 24,
      spreadRadius: 2,
      offset: const Offset(0, 8),
    ),
  ];

  // Modern Card Decoration (Backward compatible replacement for glassDecoration)
  static BoxDecoration glassDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: borderLight, width: 1.2),
    boxShadow: softCardShadow,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderLight, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
        labelStyle: const TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
        hintStyle: const TextStyle(color: textSecondary, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: primaryColor.withValues(alpha: 0.25),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  // Legacy Dark Theme (Available as backup)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0B0F19),
      primaryColor: const Color(0xFF00E5FF),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00E5FF),
        secondary: Color(0xFF00E676),
        surface: Color(0xFF161C2C),
        error: errorColor,
      ),
    );
  }
}

// ====================================================================
// DOT MATRIX BACKGROUND PAINTER (CUSTOM MODERN BACKGROUND)
// ====================================================================
class DotPatternPainter extends CustomPainter {
  final Color dotColor;
  final double spacing;
  final double radius;

  const DotPatternPainter({
    this.dotColor = const Color(0xFFCBD5E1),
    this.spacing = 24.0,
    this.radius = 1.3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DotPatternPainter oldDelegate) =>
      oldDelegate.dotColor != dotColor ||
      oldDelegate.spacing != spacing ||
      oldDelegate.radius != radius;
}
