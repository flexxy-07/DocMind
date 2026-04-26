import 'package:flutter/material.dart';
import 'design_system.dart';

class AppColors {
  // We mirror ObsidianColors for backward compatibility where needed, 
  // but aim to use ObsidianColors directly in new components.
  static const Color bg = ObsidianColors.background;
  static const Color bgCard = ObsidianColors.surface;
  static const Color bgElevated = ObsidianColors.surfaceContainerHigh;

  static const Color primary = ObsidianColors.primary;
  static const Color accent = ObsidianColors.accent;

  static const Color textPrimary = ObsidianColors.primary;
  static const Color textSecond = ObsidianColors.onSurface;
  static const Color textHint = ObsidianColors.onSurfaceVariant;

  static const Color border = ObsidianColors.border;

  // Semantic (Professional/Technical versions)
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Category Colors (Technical Palette)
  static const Map<String, int> categoryColors = {
    'legal': 0xFF3B82F6, // Technical Blue
    'health': 0xFF10B981, // Emerald
    'finance': 0xFFF59E0B, // Amber
    'education': 0xFF8B5CF6, // Violet
    'research': 0xFFEC4899, // Pink
    'hobbies': 0xFFF97316, // Orange
    'technology': 0xFF06B6D4, // Cyan
    'general': 0xFF71717A, // Zinc
  };
}

class AppTheme {
  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ObsidianColors.background,
      
      colorScheme: ColorScheme.fromSeed(
        seedColor: ObsidianColors.primary,
        brightness: Brightness.dark,
        surface: ObsidianColors.surface,
        onSurface: ObsidianColors.onSurface,
        primary: ObsidianColors.primary,
        onPrimary: ObsidianColors.onPrimary,
      ),

      textTheme: TextTheme(
        displayLarge: ObsidianTypography.displayLarge,
        displayMedium: ObsidianTypography.displayMedium,
        headlineSmall: ObsidianTypography.headlineSmall,
        bodyLarge: ObsidianTypography.bodyLarge,
        bodyMedium: ObsidianTypography.bodyMedium,
        labelSmall: ObsidianTypography.labelSmall,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: ObsidianTypography.displayMedium.copyWith(fontSize: 20),
        iconTheme: const IconThemeData(color: ObsidianColors.primary),
      ),

      cardTheme: CardThemeData(
        color: ObsidianColors.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ObsidianShapes.radiusMD),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ObsidianColors.surfaceContainerLowest,
        indicatorColor: ObsidianColors.highlight,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final color = states.contains(WidgetState.selected) 
              ? ObsidianColors.primary 
              : ObsidianColors.onSurfaceVariant;
          return ObsidianTypography.labelSmall.copyWith(color: color);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected) 
                ? ObsidianColors.primary 
                : ObsidianColors.onSurfaceVariant,
            size: 24,
          );
        }),
      ),
      
      dividerTheme: const DividerThemeData(
        color: ObsidianColors.border,
        thickness: 1,
      ),
    );
  }
}
