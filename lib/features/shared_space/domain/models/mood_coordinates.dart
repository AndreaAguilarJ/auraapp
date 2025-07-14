import 'dart:math' as math;

/// Coordenadas de estado de ánimo en el espectro bidimensional
///
/// Representa la posición del usuario en la brújula emocional usando:
/// - Energy: Eje horizontal (-1.0 = Tranquilo, +1.0 = Energético)
/// - Positivity: Eje vertical (-1.0 = Negativo, +1.0 = Positivo)
class MoodCoordinates {
  final double energy;
  final double positivity;

  const MoodCoordinates({
    required this.energy,
    required this.positivity,
  });

  /// Constructor para el centro neutro
  const MoodCoordinates.neutral() : energy = 0.0, positivity = 0.0;

  /// Crea desde un mapa de datos
  factory MoodCoordinates.fromMap(Map<String, dynamic> map) {
    return MoodCoordinates(
      energy: (map['energy'] as num?)?.toDouble() ?? 0.0,
      positivity: (map['positivity'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convierte a mapa para almacenamiento
  Map<String, dynamic> toMap() {
    return {
      'energy': energy,
      'positivity': positivity,
    };
  }

  /// Calcula la distancia desde el centro
  double get magnitude {
    return math.sqrt(energy * energy + positivity * positivity);
  }

  /// Obtiene el ángulo en radianes
  double get angle {
    return math.atan2(positivity, energy);
  }

  /// Determina el cuadrante emocional
  MoodQuadrant get quadrant {
    if (energy >= 0 && positivity >= 0) return MoodQuadrant.energeticPositive;
    if (energy < 0 && positivity >= 0) return MoodQuadrant.calmPositive;
    if (energy < 0 && positivity < 0) return MoodQuadrant.calmNegative;
    return MoodQuadrant.energeticNegative;
  }

  /// Normaliza las coordenadas dentro del círculo unitario
  MoodCoordinates normalize() {
    final mag = magnitude;
    if (mag <= 1.0) return this;

    return MoodCoordinates(
      energy: energy / mag,
      positivity: positivity / mag,
    );
  }

  /// Crea una copia con valores modificados
  MoodCoordinates copyWith({
    double? energy,
    double? positivity,
  }) {
    return MoodCoordinates(
      energy: energy ?? this.energy,
      positivity: positivity ?? this.positivity,
    );
  }

  @override
  String toString() {
    return 'MoodCoordinates(energy: ${energy.toStringAsFixed(2)}, positivity: ${positivity.toStringAsFixed(2)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MoodCoordinates &&
           other.energy == energy &&
           other.positivity == positivity;
  }

  @override
  int get hashCode => energy.hashCode ^ positivity.hashCode;
}

/// Enumera los cuatro cuadrantes emocionales
enum MoodQuadrant {
  energeticPositive, // Energético + Positivo (Feliz, Emocionado)
  calmPositive,      // Tranquilo + Positivo (Sereno, Relajado)
  calmNegative,      // Tranquilo + Negativo (Triste, Melancólico)
  energeticNegative, // Energético + Negativo (Enojado, Ansioso)
}

extension MoodQuadrantExtension on MoodQuadrant {
  /// Descripción legible del cuadrante
  String get description {
    switch (this) {
      case MoodQuadrant.energeticPositive:
        return 'Energético y Positivo';
      case MoodQuadrant.calmPositive:
        return 'Tranquilo y Positivo';
      case MoodQuadrant.calmNegative:
        return 'Tranquilo y Reflexivo';
      case MoodQuadrant.energeticNegative:
        return 'Energético e Intenso';
    }
  }

  /// Emoji representativo del cuadrante
  String get emoji {
    switch (this) {
      case MoodQuadrant.energeticPositive:
        return '😄';
      case MoodQuadrant.calmPositive:
        return '😌';
      case MoodQuadrant.calmNegative:
        return '😔';
      case MoodQuadrant.energeticNegative:
        return '😤';
    }
  }

  /// Color representativo del cuadrante
  String get colorHex {
    switch (this) {
      case MoodQuadrant.energeticPositive:
        return '#FFD700'; // Dorado
      case MoodQuadrant.calmPositive:
        return '#32CD32'; // Verde lima
      case MoodQuadrant.calmNegative:
        return '#4169E1'; // Azul real
      case MoodQuadrant.energeticNegative:
        return '#DC143C'; // Carmesí
    }
  }
}
