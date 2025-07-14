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

  const MoodCompassData({
    required this.id,
    required this.userId,
    required this.status,
    required this.mood,
    required this.contextNote,
    required this.lastUpdated,
    this.isManualUpdate = true,
    this.confidenceScore = 1.0,
  });

  /// Crea desde un documento de Appwrite
  factory MoodCompassData.fromAppwriteDocument(models.Document doc) {
    return MoodCompassData(
      id: doc.$id,
      userId: doc.data['userId'] ?? '',
      status: UserStatus.fromString(doc.data['status'] ?? 'available'),
      mood: MoodCoordinates.fromMap(
        Map<String, dynamic>.from(doc.data['mood'] ?? {}),
      ),
      contextNote: doc.data['contextNote'] ?? '',
      lastUpdated: DateTime.parse(
        doc.data['lastUpdated'] ?? DateTime.now().toIso8601String(),
      ),
      isManualUpdate: doc.data['isManualUpdate'] ?? true,
      confidenceScore: (doc.data['confidenceScore'] as num?)?.toDouble() ?? 1.0,
    );
  }

  /// Convierte a formato para Appwrite
  Map<String, dynamic> toAppwriteData() {
    return {
      'userId': userId,
      'status': status.value,
      'mood': mood.toMap(),
      'contextNote': contextNote,
      'lastUpdated': lastUpdated.toIso8601String(),
      'isManualUpdate': isManualUpdate,
      'confidenceScore': confidenceScore,
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
