import 'package:equatable/equatable.dart';

/// Tipos de pulsos de pensamiento disponibles
enum ThoughtPulseType {
  basic('Pienso en ti', '💭'),
  love('Te amo', '❤️'),
  miss('Te extraño', '😘'),
  support('Estoy aquí para ti', '🤗'),
  celebrate('¡Celebremos!', '🎉');

  const ThoughtPulseType(this.displayName, this.emoji);

  final String displayName;
  final String emoji;

  /// Convierte desde string para almacenamiento
  static ThoughtPulseType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'love':
        return ThoughtPulseType.love;
      case 'miss':
        return ThoughtPulseType.miss;
      case 'support':
        return ThoughtPulseType.support;
      case 'celebrate':
        return ThoughtPulseType.celebrate;
      default:
        return ThoughtPulseType.basic;
    }
  }

  /// Convierte a string para almacenamiento
  String toStorageString() {
    return name;
  }
}

/// Modelo para pulsos de pensamiento entre parejas
class ThoughtPulse extends Equatable {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String relationshipId;
  final DateTime timestamp;
  final ThoughtPulseType type;
  final String? message;
  final bool isRead;
  final bool isReceived; // true si este usuario lo recibió

  const ThoughtPulse({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.relationshipId,
    required this.timestamp,
    required this.type,
    this.message,
    this.isRead = false,
    this.isReceived = false,
  });

  /// Crea una copia con valores modificados
  ThoughtPulse copyWith({
    String? id,
    String? fromUserId,
    String? toUserId,
    String? relationshipId,
    DateTime? timestamp,
    ThoughtPulseType? type,
    String? message,
    bool? isRead,
    bool? isReceived,
  }) {
    return ThoughtPulse(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      relationshipId: relationshipId ?? this.relationshipId,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      isReceived: isReceived ?? this.isReceived,
    );
  }

  /// Convierte desde Map (Appwrite Document)
  factory ThoughtPulse.fromMap(Map<String, dynamic> map) {
    return ThoughtPulse(
      id: map['\$id'] ?? map['id'] ?? '',
      fromUserId: map['from_user_id'] ?? '',
      toUserId: map['to_user_id'] ?? '',
      relationshipId: map['relationship_id'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? map['\$createdAt'] ?? DateTime.now().toIso8601String()),
      type: ThoughtPulseType.fromString(map['type'] ?? 'basic'),
      message: map['message'],
      isRead: map['is_read'] ?? false,
      isReceived: map['is_received'] ?? false,
    );
  }

  /// Convierte a Map para Appwrite
  Map<String, dynamic> toMap() {
    return {
      'from_user_id': fromUserId,
      'to_user_id': toUserId,
      'relationship_id': relationshipId,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toStorageString(),
      'message': message,
      'is_read': isRead,
    };
  }

  /// Alias para toMap() que mantiene la consistencia con otros modelos
  Map<String, dynamic> toAppwriteData() => toMap();

  /// Determina si el pulso es reciente (últimos 5 minutos)
  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    return difference.inMinutes <= 5;
  }

  /// Obtiene la descripción del tiempo transcurrido
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Ahora mismo';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else {
      final days = difference.inDays;
      return 'Hace ${days}d';
    }
  }

  @override
  List<Object?> get props => [
        id,
        fromUserId,
        toUserId,
        relationshipId,
        timestamp,
        type,
        message,
        isRead,
        isReceived,
      ];
}
