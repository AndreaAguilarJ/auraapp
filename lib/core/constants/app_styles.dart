import 'package:flutter/material.dart';

/// Sistema de colores moderno de AURA 2024
/// Inspirado en Material 3 con énfasis en la conexión emocional
class AppColors {
  // Colores primarios - Paleta emocional moderna
  static const Color primaryViolet = Color(0xFF6B46C1); // Violeta profundo
  static const Color primaryRose = Color(0xFFEC4899); // Rosa vibrante
  static const Color primaryTeal = Color(0xFF06B6D4); // Teal brillante
  static const Color primaryAmber = Color(0xFFF59E0B); // Ámbar cálido
  
  // Gradientes principales - Más vibrantes y modernos
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryViolet, primaryRose],
  );
  
  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
  );
  
  static const LinearGradient coolGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
  );
  
  static const LinearGradient dreamyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA8EDEA), Color(0xFFFED6E3)],
  );
  
  // Estados emocionales mejorados con colores más expresivos
  static const Color moodJoyful = Color(0xFFFFD93D); // Alegría brillante
  static const Color moodPassionate = Color(0xFFFF6B6B); // Pasión intensa
  static const Color moodCalm = Color(0xFF4ECDC4); // Calma serena
  static const Color moodReflective = Color(0xFF6C5CE7); // Reflexión profunda
  static const Color moodExcited = Color(0xFFFF9FF3); // Emoción vibrante
  static const Color moodTender = Color(0xFFFDCB6E); // Ternura cálida
  static const Color moodMelancholy = Color(0xFF74B9FF); // Melancolía suave
  static const Color moodPeaceful = Color(0xFF55A3FF); // Paz tranquila
  
  // Gradientes emocionales modernos
  static const LinearGradient joyfulGradient = LinearGradient(
    colors: [Color(0xFFFFD93D), Color(0xFFFF9500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient passionateGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient calmGradient = LinearGradient(
    colors: [Color(0xFF4ECDC4), Color(0xFF6BCF7F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient reflectiveGradient = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFF8B7ED8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Estados de disponibilidad con diseño más moderno
  static const Color statusAvailable = Color(0xFF10B981); // Verde esmeralda
  static const Color statusBusy = Color(0xFFF59E0B); // Ámbar
  static const Color statusResting = Color(0xFF8B5CF6); // Violeta suave
  static const Color statusTraveling = Color(0xFFEF4444); // Rojo coral
  static const Color statusOffline = Color(0xFF6B7280); // Gris neutro
  
  // Superficies modernas con glassmorphism
  static const Color surfacePrimary = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF8FAFC);
  static const Color surfaceTertiary = Color(0xFFF1F5F9);
  static const Color surfaceGlass = Color(0x1AFFFFFF); // Para efectos glassmorphism
  static const Color surfaceDark = Color(0xFF0F172A);
  
  // Backgrounds modernos
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF111827);
  
  // Gradiente de fondo principal
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF8FAFC),
      Color(0xFFE2E8F0),
    ],
  );
  
  // Sistema de texto mejorado
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnDark = Color(0xFFF8FAFC);
  static const Color textAccent = Color(0xFF6B46C1);
  
  // Colores de sistema actualizados
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Colores de frescura modernos (para indicadores temporales)
  static const Color freshnessHigh = Color(0xFF10B981);
  static const Color freshnessMedium = Color(0xFF3B82F6);
  static const Color freshnessLow = Color(0xFF9CA3AF);
  
  // Opacidades para glassmorphism y overlays
  static const double opacityUltraLight = 0.05;
  static const double opacityLight = 0.1;
  static const double opacityMedium = 0.2;
  static const double opacityHeavy = 0.6;
  static const double opacityIntense = 0.8;
}

/// Sistema tipográfico moderno inspirado en Material 3
class AppTypography {
  // Usando fuentes del sistema optimizadas
  static const String fontFamily = 'Roboto';
  static const String fontFamilyDisplay = 'Roboto'; // Para headings especiales
  
  // Escala tipográfica moderna
  static const double displayL = 57.0; // Para títulos hero
  static const double displayM = 45.0; // Para títulos grandes
  static const double displayS = 36.0; // Para títulos medianos
  static const double headingL = 32.0; // Encabezados grandes
  static const double headingM = 28.0; // Encabezados medianos
  static const double headingS = 24.0; // Encabezados pequeños
  static const double titleL = 22.0; // Títulos de sección
  static const double titleM = 20.0; // Títulos de subsección
  static const double titleS = 18.0; // Títulos pequeños
  static const double bodyL = 16.0; // Texto principal
  static const double bodyM = 14.0; // Texto secundario
  static const double bodyS = 12.0; // Texto pequeño
  static const double labelL = 14.0; // Labels grandes
  static const double labelM = 12.0; // Labels medianos
  static const double labelS = 11.0; // Labels pequeños
  
  // Display styles - Para elementos hero y títulos principales
  static const TextStyle displayLStyle = TextStyle(
    fontSize: displayL,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: -0.25,
    height: 1.2,
  );
  
  static const TextStyle displayMStyle = TextStyle(
    fontSize: displayM,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.2,
  );
  
  static const TextStyle displaySStyle = TextStyle(
    fontSize: displayS,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.2,
  );
  
  // Heading styles - Para encabezados de sección
  static const TextStyle headingLStyle = TextStyle(
    fontSize: headingL,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.25,
  );
  
  static const TextStyle headingMStyle = TextStyle(
    fontSize: headingM,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.25,
  );
  
  static const TextStyle headingSStyle = TextStyle(
    fontSize: headingS,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.3,
  );
  
  // Title styles - Para títulos de componentes
  static const TextStyle titleLStyle = TextStyle(
    fontSize: titleL,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.3,
  );
  
  static const TextStyle titleMStyle = TextStyle(
    fontSize: titleM,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0.15,
    height: 1.3,
  );
  
  static const TextStyle titleSStyle = TextStyle(
    fontSize: titleS,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0.15,
    height: 1.4,
  );
  
  // Body styles - Para contenido principal
  static const TextStyle bodyLStyle = TextStyle(
    fontSize: bodyL,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
    height: 1.5,
  );
  
  static const TextStyle bodyMStyle = TextStyle(
    fontSize: bodyM,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0.25,
    height: 1.4,
  );
  
  static const TextStyle bodySStyle = TextStyle(
    fontSize: bodyS,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0.4,
    height: 1.4,
  );
  
  // Label styles - Para labels y botones
  static const TextStyle labelLStyle = TextStyle(
    fontSize: labelL,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
    height: 1.4,
  );
  
  static const TextStyle labelMStyle = TextStyle(
    fontSize: labelM,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
    height: 1.3,
  );
  
  static const TextStyle labelSStyle = TextStyle(
    fontSize: labelS,
    fontWeight: FontWeight.w500,
    color: AppColors.textTertiary,
    letterSpacing: 0.5,
    height: 1.3,
  );
  
  // Estilos especiales para elementos emocionales
  static const TextStyle emotionalTitleStyle = TextStyle(
    fontSize: titleL,
    fontWeight: FontWeight.w600,
    color: AppColors.textAccent,
    letterSpacing: 0.5,
    height: 1.2,
  );
  
  static const TextStyle moodLabelStyle = TextStyle(
    fontSize: labelM,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    height: 1.2,
  );
}

/// Sistema de espaciado y dimensiones moderno
class AppSpacing {
  // Espaciado base (múltiplos de 4)
  static const double xs2 = 2.0;  // Extra extra small
  static const double xs = 4.0;   // Extra small
  static const double s = 8.0;    // Small
  static const double m = 16.0;   // Medium (base)
  static const double l = 24.0;   // Large
  static const double xl = 32.0;  // Extra large
  static const double xxl = 48.0; // Extra extra large
  static const double xxxl = 64.0; // Ultra large
  
  // Padding específico para componentes
  static const double paddingComponent = 20.0;
  static const double paddingSection = 24.0;
  static const double paddingScreen = 20.0;
  
  // Márgenes específicos
  static const double marginCard = 16.0;
  static const double marginSection = 32.0;
  
  // Radios modernos con enfoque en Material 3
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 28.0;
  static const double radiusRound = 999.0;
  
  // Radios específicos para componentes
  static const double radiusCard = 16.0;
  static const double radiusButton = 12.0;
  static const double radiusChip = 20.0;
  static const double radiusBottomSheet = 28.0;
  
  // Elevaciones Material 3
  static const double elevationNone = 0.0;
  static const double elevationS = 1.0;
  static const double elevationM = 3.0;
  static const double elevationL = 6.0;
  static const double elevationXL = 8.0;
  static const double elevationXXL = 12.0;
  
  // Dimensiones de componentes
  static const double buttonHeightS = 32.0;
  static const double buttonHeightM = 40.0;
  static const double buttonHeightL = 48.0;
  static const double buttonHeightXL = 56.0;
  
  static const double iconSizeS = 16.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;
  static const double iconSizeXL = 48.0;
  static const double iconSizeXXL = 64.0;
  
  // Dimensiones específicas de Aura
  static const double auraWidgetSize = 280.0;
  static const double moodCircleSize = 200.0;
  static const double thoughtButtonSize = 56.0;
  static const double statusIndicatorSize = 12.0;
}

/// Animaciones y transiciones modernas
class AppAnimations {
  // Duraciones
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration slower = Duration(milliseconds: 800);
  
  // Curvas Material 3
  static const Curve emphasized = Curves.easeOutCubic;
  static const Curve emphasizedDecelerate = Curves.easeOut;
  static const Curve emphasizedAccelerate = Curves.easeIn;
  static const Curve standard = Curves.easeInOut;
  
  // Transiciones específicas
  static const Duration pulseAnimation = Duration(milliseconds: 1200);
  static const Duration thoughtRipple = Duration(milliseconds: 800);
  static const Duration moodTransition = Duration(milliseconds: 400);
  static const Duration statusChange = Duration(milliseconds: 600);
}
