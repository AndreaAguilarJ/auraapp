import 'package:appwrite/models.dart' as models;
import 'user_status.dart';
import 'mood_coordinates.dart';

/// Modelo principal de datos de la Brújula de Estado y Ánimo
class MoodCompassData {
  final String id;
  final String userId;
  final UserStatus status;
  final MoodCoordinates mood;
  final String contextNote;
  final DateTime lastUpdated;
  final bool isManualUpdate;
  final double confidenceScore;
  final String privacyLevel; // Añadiendo el campo requerido privacyLevel

  const MoodCompassData({
    required this.id,
    required this.userId,
    required this.status,
    required this.mood,
    required this.contextNote,
    required this.lastUpdated,
    this.isManualUpdate = true,
    this.confidenceScore = 1.0,
    this.privacyLevel = 'shared', // Valor por defecto 'shared' (compartido con la pareja)
  });

  /// Crea desde un documento de Appwrite
  factory MoodCompassData.fromAppwriteDocument(models.Document doc) {
    // Convertir el formato "valencia,energía" a MoodCoordinates
    MoodCoordinates moodFromString(String moodStr) {
      final parts = moodStr.split(',');
      if (parts.length == 2) {
        try {
          final positivity = double.parse(parts[0]);
          final energy = double.parse(parts[1]);
          return MoodCoordinates(positivity: positivity, energy: energy);
        } catch (e) {
          print('Error parsing mood coordinates: $e');
        }
      }
      return const MoodCoordinates(positivity: 0.0, energy: 0.0);
    }

    return MoodCompassData(
      id: doc.$id,
      userId: doc.data['userId'] ?? '',
      status: UserStatus.fromString(doc.data['status'] ?? 'available'),
      // Manejar mood como string o como mapa
      mood: doc.data['mood'] is String
          ? moodFromString(doc.data['mood'])
          : MoodCoordinates.fromMap(
              Map<String, dynamic>.from(doc.data['mood'] ?? {}),
            ),
      contextNote: doc.data['contextNote'] ?? '',
      lastUpdated: DateTime.parse(
        doc.data['timestamp'] ?? DateTime.now().toIso8601String(), // Usar timestamp en lugar de lastUpdated
      ),
      isManualUpdate: doc.data['isManualUpdate'] ?? true,
      confidenceScore: (doc.data['confidenceScore'] as num?)?.toDouble() ?? 1.0,
      privacyLevel: doc.data['privacyLevel'] ?? 'shared',
    );
  }

  /// Crea desde datos genéricos de Appwrite (para eventos de tiempo real)
  factory MoodCompassData.fromAppwriteData(Map<String, dynamic> data) {
    // Convertir el formato "valencia,energía" a MoodCoordinates
    MoodCoordinates moodFromString(String moodStr) {
      final parts = moodStr.split(',');
      if (parts.length == 2) {
        try {
          final positivity = double.parse(parts[0]);
          final energy = double.parse(parts[1]);
          return MoodCoordinates(positivity: positivity, energy: energy);
        } catch (e) {
          print('Error parsing mood coordinates: $e');
        }
      }
      return const MoodCoordinates(positivity: 0.0, energy: 0.0);
    }

    return MoodCompassData(
      id: data['\$id'] ?? data['id'] ?? '',
      userId: data['userId'] ?? '',
      status: UserStatus.fromString(data['status'] ?? 'available'),
      // Manejar mood como string o como mapa
      mood: data['mood'] is String
          ? moodFromString(data['mood'])
          : MoodCoordinates.fromMap(
              Map<String, dynamic>.from(data['mood'] ?? {}),
            ),
      contextNote: data['contextNote'] ?? '',
      lastUpdated: data['timestamp'] != null
          ? DateTime.parse(data['timestamp'])
          : DateTime.now(),
      isManualUpdate: data['isManualUpdate'] ?? true,
      confidenceScore: (data['confidenceScore'] as num?)?.toDouble() ?? 1.0,
      privacyLevel: data['privacyLevel'] ?? 'shared',
    );
  }

  /// Convierte a formato para Appwrite
  Map<String, dynamic> toAppwriteData() {
    // Convertir las coordenadas del estado de ánimo al formato "valencia,energía" requerido
    final String moodString = "${mood.positivity.toStringAsFixed(0)},${mood.energy.toStringAsFixed(0)}";

    return {
      'userId': userId,
      'status': status.value,
      'mood': moodString, // Formato simple: "80,60"
      'contextNote': contextNote,
      'timestamp': lastUpdated.toIso8601String(),
      'isManualUpdate': isManualUpdate,
      'confidenceScore': confidenceScore,
      'privacyLevel': privacyLevel,
    };
  }

  /// Calcula la "frescura" de la actualización (0.0 a 1.0)
  double get freshness {
    final hoursSinceUpdate = DateTime.now().difference(lastUpdated).inHours;
    const halfLifeHours = 6; // Después de 6 horas, freshness = 0.5

    return (0.5 * (hoursSinceUpdate / halfLifeHours)).clamp(0.0, 1.0);
  }

  /// Determina si la actualización es reciente (menos de 2 horas)
  bool get isRecent {
    return DateTime.now().difference(lastUpdated).inHours < 2;
  }

  /// Obtiene una descripción legible del estado
  String get statusDescription {
    final moodDesc = mood.quadrant.description;
    final statusDesc = status.description;

    if (contextNote.isNotEmpty) {
      return '$statusDesc • $moodDesc • "$contextNote"';
    } else {
      return '$statusDesc • $moodDesc';
    }
  }

  /// Crea una copia con valores modificados
  MoodCompassData copyWith({
    String? id,
    String? userId,
    UserStatus? status,
    MoodCoordinates? mood,
    String? contextNote,
    DateTime? lastUpdated,
    bool? isManualUpdate,
    double? confidenceScore,
    String? privacyLevel,
  }) {
    return MoodCompassData(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      mood: mood ?? this.mood,
      contextNote: contextNote ?? this.contextNote,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isManualUpdate: isManualUpdate ?? this.isManualUpdate,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      privacyLevel: privacyLevel ?? this.privacyLevel,
    );
  }

  @override
  String toString() {
    return 'MoodCompassData(id: $id, status: ${status.value}, mood: $mood, note: "$contextNote")';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MoodCompassData &&
           other.id == id &&
           other.userId == userId &&
           other.status == status &&
           other.mood == mood &&
           other.contextNote == contextNote &&
           other.lastUpdated == lastUpdated;
  }

  @override
  int get hashCode {
    return id.hashCode ^
           userId.hashCode ^
           status.hashCode ^
           mood.hashCode ^
           contextNote.hashCode ^
           lastUpdated.hashCode;
  }
}
