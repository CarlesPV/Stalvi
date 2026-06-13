import 'package:flutter/material.dart';

/// Custom theme extension for financial colors (positive/income and negative/expenses).
/// This allows us to access these colors cleanly using Theme.of(context).extension<FinancialColors>()!
@immutable
class FinancialColors extends ThemeExtension<FinancialColors> {
  final Color positive;
  final Color negative;

  const FinancialColors({
    required this.positive,
    required this.negative,
  });

  @override
  FinancialColors copyWith({Color? positive, Color? negative}) {
    return FinancialColors(
      positive: positive ?? this.positive,
      negative: negative ?? this.negative,
    );
  }

  @override
  FinancialColors lerp(ThemeExtension<FinancialColors>? other, double t) {
    if (other is! FinancialColors) {
      return this;
    }
    return FinancialColors(
      positive: Color.lerp(positive, other.positive, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
    );
  }
}

/// AppTheme defines the visual design system for Konta.
/// It uses a financial-trust aesthetic with Deep Navy Blue as primary,
/// pastel Mint Green for positive/income values, and pastel Coral Red for negative/expenses.
class AppTheme {
  AppTheme._();

  // Color Constants - Core Brand (Financial Trust)
  static const Color navyDark = Color(0xFF0F172A); // Deep Navy (Slate 900)
  static const Color navyPrimary =
      Color(0xFF1E293B); // Navy Primary (Slate 800)
  static const Color navyLight = Color(0xFF334155); // Light Navy (Slate 700)

  // Color Constants - Financial Status
  static const Color mintGreenLight =
      Color(0xFF10B981); // Mint Green (Emerald 500)
  static const Color mintGreenDark =
      Color(0xFF34D399); // Pastel Mint Green for Dark Mode (Emerald 400)

  static const Color coralRedLight = Color(0xFFF43F5E); // Coral Red (Rose 500)
  static const Color coralRedDark =
      Color(0xFFFB7185); // Pastel Coral Red for Dark Mode (Rose 400)

  // Color Constants - Backgrounds & Surfaces
  static const Color bgLight = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color bgDark = Color(0xFF121212); // Soft Charcoal
  static const Color surfaceDark =
      Color(0xFF1E1E1E); // Slightly lighter Charcoal for cards/dialogs

  /// Light Theme Definition
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: navyDark,
        onPrimary: Colors.white,
        secondary: Color(0xFF0EA5E9), // Sky Blue accent
        onSecondary: Colors.white,
        error: coralRedLight,
        onError: Colors.white,
        surface: bgLight,
        onSurface: navyDark,
        surfaceContainerHighest: Color(0xFFF1F5F9), // Slate 100
        onSurfaceVariant: navyLight,
      ),
      scaffoldBackgroundColor: bgLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceLight,
        foregroundColor: navyDark,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 2,
        shadowColor: const Color(0x0D000000), // ~5% opacity black
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E8F0), // Slate 200
        thickness: 1,
      ),
      extensions: const [
        FinancialColors(
          positive: mintGreenLight,
          negative: coralRedLight,
        ),
      ],
    );
  }

  /// Dark Theme Definition
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(
            0xFF60A5FA,), // Light Blue/Indigo accent for dark theme visibility
        onPrimary: navyDark,
        secondary: Color(0xFF38BDF8),
        onSecondary: navyDark,
        error: coralRedDark,
        onError: navyDark,
        surface: bgDark,
        onSurface: Color(0xFFF1F5F9), // Slate 100
        surfaceContainerHighest: Color(0xFF2D2D2D),
        onSurfaceVariant: Color(0xFFCBD5E1), // Slate 300
      ),
      scaffoldBackgroundColor: bgDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: bgDark,
        foregroundColor: Color(0xFFF1F5F9),
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF2D2D2D), width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2D2D2D),
        thickness: 1,
      ),
      extensions: const [
        FinancialColors(
          positive: mintGreenDark,
          negative: coralRedDark,
        ),
      ],
    );
  }
}

/// Extension helper on BuildContext to quickly access financial colors
extension FinancialColorsExtension on BuildContext {
  FinancialColors get financialColors {
    final extension = Theme.of(this).extension<FinancialColors>();
    assert(extension != null,
        'FinancialColors extension is not registered in the current theme.',);
    return extension!;
  }
}
