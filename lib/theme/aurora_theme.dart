import 'package:flutter/material.dart';
import '../utils/color_contrast_utils.dart';

class AuroraTheme {
  // Цвета космоса
  static const Color inkBlue = Color(0xFF0A1628);
  static const Color spaceBlue = Color(0xFF1A2B4A);
  static const Color neonYellow = Color(0xFFFFD700);
  static const Color neonBlue = Color(0xFF00D4FF);
  static const Color neonPurple = Color(0xFFB794F6);
  static const Color neonMint = Color(0xFF4FD1C7);

  // Градиенты
  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A2B4A), Color(0xFF0A1628), Color(0xFF1A3B5A)],
  );

  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2D1B4A), Color(0xFF1A0A28), Color(0xFF3B1B5A)],
  );

  static const LinearGradient mintGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B4A3D), Color(0xFF0A281A), Color(0xFF1B5A4D)],
  );

  static ThemeData getTheme({
    String themeColor = 'blue',
    bool useDynamicColors = false,
    Color? seedColor,
  }) {
    Color primaryColor;
    Color accentColor;
    Color seed;

    switch (themeColor) {
      case 'purple':
        primaryColor = neonPurple;
        accentColor = neonPurple;
        seed = neonPurple;
        break;
      case 'mint':
        primaryColor = neonMint;
        accentColor = neonMint;
        seed = neonMint;
        break;
      default: // blue
        primaryColor = neonBlue;
        accentColor = neonBlue;
        seed = neonBlue;
        break;
    }

    // Используем seedColor если передан, иначе используем выбранную тему
    final effectiveSeed = seedColor ?? seed;

    // Material 3 динамические цвета
    final colorScheme = useDynamicColors
        ? ColorScheme.fromSeed(
            seedColor: effectiveSeed,
            brightness: Brightness.dark,
          )
        : ColorScheme.dark(
            primary: primaryColor,
            secondary: accentColor,
            tertiary: accentColor,
            surface: spaceBlue.withValues(alpha: 0.3),
            surfaceContainerHighest: inkBlue,
            surfaceContainerHigh: spaceBlue.withValues(alpha: 0.6),
            surfaceContainer: spaceBlue.withValues(alpha: 0.4),
            surfaceContainerLow: spaceBlue.withValues(alpha: 0.2),
            surfaceContainerLowest: inkBlue,
            error: Colors.redAccent,
            errorContainer: Colors.redAccent.withValues(alpha: 0.2),
            onTertiary: Colors.black,
            onError: Colors.white,
            outline: primaryColor.withValues(alpha: 0.5),
            outlineVariant: primaryColor.withValues(alpha: 0.2),
          );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: inkBlue,
      cardTheme: CardThemeData(
        color: spaceBlue.withValues(alpha: 0.4),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: spaceBlue.withValues(alpha: 0.5),
        selectedItemColor: neonYellow,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ColorContrastUtils.ensureContrast(
            primaryColor,
            inkBlue,
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: spaceBlue.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white54),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: spaceBlue.withValues(alpha: 0.4),
        selectedColor: primaryColor,
        labelStyle: const TextStyle(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: spaceBlue.withValues(alpha: 0.5),
        indicatorColor: primaryColor.withValues(alpha: 0.3),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            );
          }
          return const TextStyle(color: Colors.white70);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primaryColor, size: 24);
          }
          return const IconThemeData(color: Colors.white70, size: 24);
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: spaceBlue.withValues(alpha: 0.5),
        selectedIconTheme: IconThemeData(color: primaryColor, size: 28),
        unselectedIconTheme: const IconThemeData(color: Colors.white70, size: 24),
        selectedLabelTextStyle: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
        indicatorColor: primaryColor.withValues(alpha: 0.3),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return primaryColor;
            }
            return spaceBlue.withValues(alpha: 0.4);
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return Colors.black;
            }
            return Colors.white;
          }),
        ),
      ),
      badgeTheme: const BadgeThemeData(
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
      ),
    );
  }

  // Glassmorphism эффект
  static Widget glassCard({
    required Widget child,
    double opacity = 0.3,
    double blur = 10.0,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: spaceBlue.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: blur,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: child,
      ),
    );
  }
}

