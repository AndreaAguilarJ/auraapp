import 'package:equatable/equatable.dart';
import 'user_status.dart';

/// Snapshot completo del estado y ánimo de un usuario
class MoodSnapshot extends Equatable {
  final String id;
  final String userId;
  final UserStatus status;
  final double energyLevel; // -1.0 a 1.0
  final double positivityLevel; // -1.0 a 1.0
  final String contextNote;
  final DateTime timestamp;
  final DateTime? expiresAt;
  
  // Configuraciones de privacidad
  final bool shareStatus;
  final bool shareMood;
  final bool shareContextNote;

  const MoodSnapshot({
    required this.id,
    required this.userId,
    required this.status,
    required this.energyLevel,
    required this.positivityLevel,
    required this.contextNote,
    required this.timestamp,
    this.expiresAt,
    this.shareStatus = true,
    this.shareMood = true,
    this.shareContextNote = false,
  });

  /// Crea una copia con valores modificados
  MoodSnapshot copyWith({
    String? id,
    String? userId,
    UserStatus? status,
    double? energyLevel,
    double? positivityLevel,
    String? contextNote,
    DateTime? timestamp,
    DateTime? expiresAt,
    bool? shareStatus,
    bool? shareMood,
    bool? shareContextNote,
  }) {
    return MoodSnapshot(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      energyLevel: energyLevel ?? this.energyLevel,
      positivityLevel: positivityLevel ?? this.positivityLevel,
      contextNote: contextNote ?? this.contextNote,
      timestamp: timestamp ?? this.timestamp,
      expiresAt: expiresAt ?? this.expiresAt,
      shareStatus: shareStatus ?? this.shareStatus,
      shareMood: shareMood ?? this.shareMood,
      shareContextNote: shareContextNote ?? this.shareContextNote,
    );
  }

  /// Convierte a Map para Appwrite
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'status': status.toStorageString(),
      'energy_level': energyLevel,
      'positivity_level': positivityLevel,
      'context_note': contextNote,
      'timestamp': timestamp.toIso8601String(),
      'expires_at': expiresAt?.toIso8601String(),
      'share_status': shareStatus,
      'share_mood': shareMood,
      'share_context_note': shareContextNote,
    };
  }

  /// Crea desde Map de Appwrite
  factory MoodSnapshot.fromMap(Map<String, dynamic> map, String id) {
    return MoodSnapshot(
      id: id,
      userId: map['user_id'] ?? '',
      status: UserStatus.fromString(map['status'] ?? 'available'),
      energyLevel: (map['energy_level'] ?? 0.0).toDouble(),
      positivityLevel: (map['positivity_level'] ?? 0.0).toDouble(),
      contextNote: map['context_note'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      expiresAt: map['expires_at'] != null ? DateTime.parse(map['expires_at']) : null,
      shareStatus: map['share_status'] ?? true,
      shareMood: map['share_mood'] ?? true,
      shareContextNote: map['share_context_note'] ?? false,
    );
  }

  /// Filtra los datos según configuraciones de privacidad
  MoodSnapshot applyPrivacyFilter() {
    return copyWith(
      status: shareStatus ? status : UserStatus.available,
      energyLevel: shareMood ? energyLevel : 0.0,
      positivityLevel: shareMood ? positivityLevel : 0.0,
      contextNote: shareContextNote ? contextNote : '',
    );
  }

  /// Verifica si el snapshot ha expirado
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Calcula el nivel de frescura (0.0 a 1.0)
  double get freshnessLevel {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    final minutes = difference.inMinutes;
    
    // Frescura se reduce exponencialmente (half-life de 15 minutos)
    return (1.0 - (minutes / 15.0) * 0.5).clamp(0.0, 1.0);
  }

  /// Convierte a formato específico para la colección Mood_Snapshots en Appwrite
  Map<String, dynamic> toAppwriteData() {
    // Convertir energyLevel y positivityLevel a un string "mood"
    final String moodString = "${positivityLevel.toStringAsFixed(0)},${energyLevel.toStringAsFixed(0)}";

    // Determinar el nivel de privacidad basado en los flags de compartición
    String privacyLevel = "private";
    if (shareStatus && shareMood && shareContextNote) {
      privacyLevel = "full";
    } else if (shareStatus && shareMood) {
      privacyLevel = "mood_and_status";
    } else if (shareStatus) {
      privacyLevel = "status_only";
    }

    return {
      'userId': userId,
      'status': status.value,
      'mood': moodString,
      'contextNote': contextNote,
      'privacyLevel': privacyLevel,
      'timestamp': timestamp.toIso8601String(),
      'isManualUpdate': true, // valor por defecto
      'confidenceScore': 1.0, // valor por defecto
    };
  }

  /// Crea desde datos de Appwrite para la colección Mood_Snapshots
  factory MoodSnapshot.fromAppwriteData(Map<String, dynamic> data) {
    // Extraer valores de energía y positividad del campo mood
    double energy = 0.0;
    double positivity = 0.0;
    if (data['mood'] != null && data['mood'] is String) {
      final parts = (data['mood'] as String).split(',');
      if (parts.length == 2) {
        try {
          positivity = double.parse(parts[0]);
          energy = double.parse(parts[1]);
        } catch (_) {}
      }
    }

    // Determinar los flags de compartición basados en privacyLevel
    final privacyLevel = data['privacyLevel'] as String? ?? 'private';
    final shareStatus = privacyLevel != 'private';
    final shareMood = privacyLevel == 'full' || privacyLevel == 'mood_and_status';
    final shareContextNote = privacyLevel == 'full';

    return MoodSnapshot(
      id: data['\$id'] ?? data['id'] ?? '',
      userId: data['userId'] ?? '',
      status: UserStatus.fromString(data['status'] ?? 'available'),
      energyLevel: energy,
      positivityLevel: positivity,
      contextNote: data['contextNote'] ?? '',
      timestamp: data['timestamp'] != null
          ? DateTime.parse(data['timestamp'])
          : DateTime.now(),
      shareStatus: shareStatus,
      shareMood: shareMood,
      shareContextNote: shareContextNote,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    status,
    energyLevel,
    positivityLevel,
    contextNote,
    timestamp,
    expiresAt,
    shareStatus,
    shareMood,
    shareContextNote,
  ];
}
