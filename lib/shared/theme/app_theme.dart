import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Sistema de Tema Moderno AURA 2025
/// Inspirado en Material Design 3 con personalidad única para relaciones a distancia
class AuraTheme {
  // ===== PALETA DE COLORES MODERNA =====

  // Colores primarios - Inspirados en conexiones emocionales
  static const Color _primaryPurple = Color(0xFF7C3AED);    // Violeta profundo
  static const Color _primaryRose = Color(0xFFEC4899);      // Rosa passion
  static const Color _primaryTeal = Color(0xFF06B6D4);      // Teal serenidad
  static const Color _accentAmber = Color(0xFFF59E0B);      // Ámbar calidez

  // Superficie y backgrounds con glassmorphism
  static const Color _surfaceDark = Color(0xFF0F0F23);      // Casi negro profundo
  static const Color _surfaceLight = Color(0xFFFAFAFC);     // Blanco puro suave
  static const Color _surfaceCard = Color(0xFF1A1B3E);      // Card oscura
  static const Color _surfaceGlass = Color(0x1AFFFFFF);     // Efecto glass

  // Semantic colors modernos
  static const Color _success = Color(0xFF10B981);
  static const Color _warning = Color(0xFFF59E0B);
  static const Color _error = Color(0xFFEF4444);
  static const Color _info = Color(0xFF3B82F6);

  // ===== GRADIENTES EMOCIONALES =====

  static const List<Color> connectionGradient = [
    Color(0xFF667EEA),
    Color(0xFF764BA2),
  ];

  static const List<Color> intimacyGradient = [
    Color(0xFFFF6B9D),
    Color(0xFFC44569),
  ];

  static const List<Color> serenityGradient = [
    Color(0xFF4FACFE),
    Color(0xFF00F2FE),
  ];

  static const List<Color> energyGradient = [
    Color(0xFFFA709A),
    Color(0xFFFEE140),
  ];

  // ===== TEMA CLARO =====

  static ThemeData get lightTheme {
    const ColorScheme lightColorScheme = ColorScheme.light(
      primary: _primaryPurple,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFE4D4F4),
      onPrimaryContainer: Color(0xFF2A0845),

      secondary: _primaryRose,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFFFD9E2),
      onSecondaryContainer: Color(0xFF3E0A16),

      tertiary: _primaryTeal,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFB8F5FF),
      onTertiaryContainer: Color(0xFF002023),

      surface: _surfaceLight,
      onSurface: Color(0xFF1A1B23),
      surfaceContainerHighest: Color(0xFFF1F1F9),

      background: _surfaceLight,
      onBackground: Color(0xFF1A1B23),

      error: _error,
      onError: Colors.white,

      outline: Color(0xFFCAC4D0),
      shadow: Colors.black26,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      fontFamily: 'SF Pro Display',

      // App Bar moderno
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF1A1B23),
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1B23),
          letterSpacing: -0.5,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // Cards con glassmorphism
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white.withOpacity(0.8),
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Botones modernos
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: _primaryPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // Input fields modernos
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: _primaryPurple,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),

      // Bottom Navigation moderno
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: _primaryPurple,
        unselectedItemColor: Color(0xFF9CA3AF),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: false,
      ),
    );
  }

  // ===== TEMA OSCURO =====

  static ThemeData get darkTheme {
    const ColorScheme darkColorScheme = ColorScheme.dark(
      primary: Color(0xFF9A7CFA),
      onPrimary: Color(0xFF2A0845),
      primaryContainer: Color(0xFF3F1A78),
      onPrimaryContainer: Color(0xFFE4D4F4),

      secondary: Color(0xFFFF8FB3),
      onSecondary: Color(0xFF3E0A16),
      secondaryContainer: Color(0xFF5C1429),
      onSecondaryContainer: Color(0xFFFFD9E2),

      tertiary: Color(0xFF54D1DB),
      onTertiary: Color(0xFF002023),
      tertiaryContainer: Color(0xFF003137),
      onTertiaryContainer: Color(0xFFB8F5FF),

      surface: _surfaceDark,
      onSurface: Color(0xFFE5E1E6),
      surfaceContainerHighest: _surfaceCard,

      background: _surfaceDark,
      onBackground: Color(0xFFE5E1E6),

      error: Color(0xFFFFB4A9),
      onError: Color(0xFF680003),

      outline: Color(0xFF948F99),
      shadow: Colors.black54,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      fontFamily: 'SF Pro Display',

      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFFE5E1E6),
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Color(0xFFE5E1E6),
          letterSpacing: -0.5,
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: _surfaceCard.withOpacity(0.6),
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: Color(0xFF9A7CFA),
          foregroundColor: Color(0xFF2A0845),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceCard.withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF9A7CFA),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _surfaceCard,
        selectedItemColor: Color(0xFF9A7CFA),
        unselectedItemColor: Color(0xFF6B7280),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showSelectedLabels: true,
        showUnselectedLabels: false,
      ),
    );
  }
}

/// Extensiones para gradientes y efectos especiales
extension AuraGradients on ThemeData {
  LinearGradient get connectionGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AuraTheme.connectionGradient,
  );

  LinearGradient get intimacyGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AuraTheme.intimacyGradient,
  );

  LinearGradient get serenityGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AuraTheme.serenityGradient,
  );

  LinearGradient get energyGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: AuraTheme.energyGradient,
  );
}

/// Tipografía moderna para AURA
class AuraTypography {
  static const String _fontFamily = 'SF Pro Display';

  // Headings modernos
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
  );

  // Headlines
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );

  // Body text
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );
}

/// Espaciado consistente y moderno
class AuraSpacing {
  static const double xs = 4.0;
  static const double s = 8.0;
  static const double m = 16.0;
  static const double l = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

/// Animaciones con timing perfecto
class AuraAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration extraSlow = Duration(milliseconds: 800);

  static const Curve easeInOut = Curves.easeInOutCubic;
  static const Curve elastic = Curves.elasticOut;
  static const Curve bounce = Curves.bounceOut;
}
