import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ObsidianColors {
  static const Color background = Color(0xFF0A0A0C);
  static const Color surface = Color(0xFF131315);
  static const Color surfaceContainerLowest = Color(0xFF0E0E10);
  static const Color surfaceContainerLow = Color(0xFF1C1B1D);
  static const Color surfaceContainer = Color(0xFF201F21);
  static const Color surfaceContainerHigh = Color(0xFF2A2A2C);
  static const Color surfaceContainerHighest = Color(0xFF353437);
  static const Color surfaceVariant = Color(0xFF353437);
  
  static const Color primary = Color(0xFFFFFFFF);
  static const Color onPrimary = Color(0xFF1A1C1C);
  
  static const Color accent = Color(0xFF1D4ED8); // Technical Blue
  static const Color onSurface = Color(0xFFE5E1E4);
  static const Color onSurfaceVariant = Color(0xFFC6C6C6);
  
  static const Color border = Color(0x26919191); // 15% opacity ghost border
  static const Color highlight = Color(0x33FFFFFF);
}

class ObsidianTypography {
  static TextStyle displayLarge = GoogleFonts.spaceGrotesk(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: ObsidianColors.primary,
    letterSpacing: -1.5,
  );

  static TextStyle displayMedium = GoogleFonts.spaceGrotesk(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: ObsidianColors.primary,
    letterSpacing: -1.0,
  );

  static TextStyle headlineSmall = GoogleFonts.spaceGrotesk(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: ObsidianColors.primary,
  );

  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: ObsidianColors.onSurface,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: ObsidianColors.onSurface,
  );

  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: ObsidianColors.onSurfaceVariant,
    letterSpacing: 0.5,
    height: 1.0,
  );
  
  static TextStyle technicalLabel = GoogleFonts.spaceGrotesk(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: ObsidianColors.primary,
    letterSpacing: 1.2,
  );
}

class ObsidianShapes {
  static const double radiusNone = 0;
  static const double radiusXS = 2;
  static const double radiusSM = 4;
  static const double radiusMD = 8;
  static const double radiusLG = 12;
  static const double radiusXL = 24;
}
