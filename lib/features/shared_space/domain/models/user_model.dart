import 'package:appwrite/models.dart' as models;
import 'dart:convert'; // Agregar para JSON decode

/// Modelo de usuario para la aplicación AURA
class UserModel {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final DateTime lastActiveAt;
  final String? partnerId;
  final RelationshipStatus relationshipStatus;
  final Map<String, dynamic> preferences;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.lastActiveAt,
    this.partnerId,
    required this.relationshipStatus,
    required this.preferences,
  });

  /// Crea un UserModel desde un documento de Appwrite
  factory UserModel.fromAppwriteDocument(models.Document doc) {
    // Decodificar preferences desde JSON string
    Map<String, dynamic> decodedPreferences = {};
    try {
      final preferencesData = doc.data['preferences'];
      if (preferencesData is String) {
        // Si es un string JSON, decodificarlo
        decodedPreferences = Map<String, dynamic>.from(jsonDecode(preferencesData));
      } else if (preferencesData is Map) {
        // Si ya es un Map (compatibilidad hacia atrás)
        decodedPreferences = Map<String, dynamic>.from(preferencesData);
      }
    } catch (e) {
      print('Error decodificando preferences: $e');
      // Usar preferencias por defecto si hay error
      decodedPreferences = {
        'shareStatus': true,
        'shareMood': true,
        'shareContextNotes': false,
        'allowNotifications': true,
      };
    }

    return UserModel(
      id: doc.$id,
      name: doc.data['name'] ?? '',
      email: doc.data['email'] ?? '',
      createdAt: DateTime.parse(doc.data['createdAt'] ?? DateTime.now().toIso8601String()),
      lastActiveAt: DateTime.parse(doc.data['lastActiveAt'] ?? DateTime.now().toIso8601String()),
      partnerId: doc.data['partnerId'],
      relationshipStatus: RelationshipStatus.fromString(doc.data['relationshipStatus'] ?? 'single'),
      preferences: decodedPreferences,
    );
  }

  /// Convierte el modelo a un Map para Appwrite
  Map<String, dynamic> toAppwriteData() {
    return {
      'name': name,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
      'partnerId': partnerId,
      'relationshipStatus': relationshipStatus.value,
      'preferences': preferences,
    };
  }

  /// Crea una copia del modelo con valores actualizados
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    String? partnerId,
    RelationshipStatus? relationshipStatus,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      partnerId: partnerId ?? this.partnerId,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      preferences: preferences ?? this.preferences,
    );
  }

  /// Verifica si el usuario tiene pareja
  bool get hasPartner => partnerId != null && partnerId!.isNotEmpty;

  /// Obtiene una preferencia específica
  T getPreference<T>(String key, T defaultValue) {
    return preferences[key] as T? ?? defaultValue;
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, hasPartner: $hasPartner)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Estados de relación posibles
enum RelationshipStatus {
  single('single'),
  connected('connected'),
  pending('pending'),
  paused('paused');

  const RelationshipStatus(this.value);
  final String value;

  static RelationshipStatus fromString(String value) {
    switch (value) {
      case 'single':
        return RelationshipStatus.single;
      case 'connected':
        return RelationshipStatus.connected;
      case 'pending':
        return RelationshipStatus.pending;
      case 'paused':
        return RelationshipStatus.paused;
      default:
        return RelationshipStatus.single;
    }
  }

  String get displayName {
    switch (this) {
      case RelationshipStatus.single:
        return 'Sin pareja conectada';
      case RelationshipStatus.connected:
        return 'Conectado';
      case RelationshipStatus.pending:
        return 'Conexión pendiente';
      case RelationshipStatus.paused:
        return 'Conexión pausada';
    }
  }

  bool get isConnected => this == RelationshipStatus.connected;
  bool get canShareData => this == RelationshipStatus.connected;
}
