import 'package:equatable/equatable.dart';
import 'dart:convert'; // Agregamos esta importación para json.decode

/// Representa un elemento de actividad reciente en la aplicación
class ActivityItem extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String? partnerId; // Nuevo campo agregado
  final ActivityType type;
  final String title;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  final bool isRead;

  const ActivityItem({
    required this.id,
    required this.userId,
    required this.userName,
    this.partnerId, // Nuevo parámetro opcional
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.metadata,
    this.isRead = false,
  });

  /// Crea una instancia desde datos de Appwrite
  factory ActivityItem.fromAppwriteData(Map<String, dynamic> data) {
    // Procesar el campo metadata que puede ser String (JSON) o Map
    Map<String, dynamic>? metadataMap;
    if (data['metadata'] is String) {
      try {
        // Si es una cadena, intentar convertirla de JSON a Map
        final metadataStr = data['metadata'] as String;
        if (metadataStr.isNotEmpty && metadataStr != '{}') {
          metadataMap = json.decode(metadataStr) as Map<String, dynamic>;
        } else {
          metadataMap = {};
        }
      } catch (e) {
        print('⚠️ Error al convertir metadata de JSON a Map en ActivityItem.fromAppwriteData: $e');
        metadataMap = {};
      }
    } else {
      // Si ya es un Map o null, usarlo directamente
      metadataMap = data['metadata'] as Map<String, dynamic>?;
    }

    return ActivityItem(
      id: data['\$id'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      partnerId: data['partnerId'],
      type: ActivityType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => ActivityType.other,
      ),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      timestamp: data['timestamp'] != null
          ? DateTime.parse(data['timestamp'])
          : DateTime.now(),
      metadata: metadataMap, // Usar el metadata procesado
      isRead: data['isRead'] ?? false,
    );
  }

  /// Convierte la instancia a formato para Appwrite
  Map<String, dynamic> toAppwriteData() {
    return {
      'userId': userId,
      'userName': userName,
      'partnerId': partnerId, // Nuevo campo
      'type': type.toString().split('.').last,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
      'isRead': isRead,
    };
  }

  /// Crea una copia con campos modificados
  ActivityItem copyWith({
    String? id,
    String? userId,
    String? userName,
    String? partnerId, // Nuevo parámetro
    ActivityType? type,
    String? title,
    String? description,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
    bool? isRead,
  }) {
    return ActivityItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      partnerId: partnerId ?? this.partnerId, // Nuevo campo
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      isRead: isRead ?? this.isRead,
    );
  }

  /// Tiempo transcurrido desde la actividad
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Ahora mismo';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }

  /// Icono asociado al tipo de actividad
  String get icon {
    switch (type) {
      case ActivityType.moodUpdate:
        return '🎭';
      case ActivityType.statusChange:
        return '📍';
      case ActivityType.thoughtPulse:
        return '💭';
      case ActivityType.message:
        return '💬';
      case ActivityType.connection:
        return '🔗';
      case ActivityType.partnerJoined:
        return '👥';
      case ActivityType.other:
        return '✨';
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        partnerId, // Agregado a props
        type,
        title,
        description,
        timestamp,
        metadata,
        isRead,
      ];
}

/// Tipos de actividades disponibles
enum ActivityType {
  moodUpdate,
  statusChange,
  thoughtPulse,
  message,
  connection,
  partnerJoined,
  other,
}
