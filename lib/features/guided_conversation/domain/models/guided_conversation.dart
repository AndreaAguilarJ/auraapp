import 'dart:convert';
import 'conversation_turn.dart';

class GuidedConversation {
  final String? id;
  final String relationshipId;
  final String initiatorUserId;
  final String partnerUserId;
  final Map<String, dynamic> topic;
  final String status; // active, completed, paused, cancelled
  final String currentTurn;
  final int totalTurns;
  final List<ConversationTurn> turns;
  final Map<String, dynamic>? finalSummary;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const GuidedConversation({
    this.id,
    required this.relationshipId,
    required this.initiatorUserId,
    required this.partnerUserId,
    required this.topic,
    required this.status,
    required this.currentTurn,
    required this.totalTurns,
    required this.turns,
    this.finalSummary,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '\$id': id,
      'relationshipId': relationshipId,
      'initiatorUserId': initiatorUserId,
      'partnerUserId': partnerUserId,
      'topic': json.encode(topic), // Convertir a JSON string
      'status': status,
      'currentTurn': currentTurn,
      'totalTurns': totalTurns,
      'turns': json.encode(turns.map((turn) => turn.toMap()).toList()), // Convertir a JSON string
      if (finalSummary != null) 'finalSummary': json.encode(finalSummary!), // Convertir a JSON string
    };
  }

  factory GuidedConversation.fromMap(Map<String, dynamic> map) {
    return GuidedConversation(
      id: map['\$id'],
      relationshipId: map['relationshipId'] ?? '',
      initiatorUserId: map['initiatorUserId'] ?? '',
      partnerUserId: map['partnerUserId'] ?? '',
      topic: map['topic'] != null
          ? (map['topic'] is String ? json.decode(map['topic']) : map['topic'])
          : {},
      status: map['status'] ?? 'active',
      currentTurn: map['currentTurn'] ?? '',
      totalTurns: map['totalTurns']?.toInt() ?? 0,
      turns: _parseJsonToTurnsList(map['turns']),
      finalSummary: map['finalSummary'] != null
          ? (map['finalSummary'] is String ? json.decode(map['finalSummary']) : map['finalSummary'])
          : null,
      createdAt: map['\$createdAt'] != null
          ? DateTime.parse(map['\$createdAt'])
          : null,
      updatedAt: map['\$updatedAt'] != null
          ? DateTime.parse(map['\$updatedAt'])
          : null,
    );
  }

  // Método auxiliar para parsear turns de JSON
  static List<ConversationTurn> _parseJsonToTurnsList(dynamic turnsData) {
    if (turnsData == null) return [];

    if (turnsData is String) {
      // Si es un string JSON, decodificarlo
      try {
        final List<dynamic> turnsList = json.decode(turnsData);
        return turnsList.map((turnMap) => ConversationTurn.fromMap(turnMap)).toList();
      } catch (e) {
        return [];
      }
    } else if (turnsData is List) {
      // Si ya es una lista, procesarla directamente
      return turnsData.map((turnMap) => ConversationTurn.fromMap(turnMap)).toList();
    }

    return [];
  }

  GuidedConversation copyWith({
    String? id,
    String? relationshipId,
    String? initiatorUserId,
    String? partnerUserId,
    Map<String, dynamic>? topic,
    String? status,
    String? currentTurn,
    int? totalTurns,
    List<ConversationTurn>? turns,
    Map<String, dynamic>? finalSummary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GuidedConversation(
      id: id ?? this.id,
      relationshipId: relationshipId ?? this.relationshipId,
      initiatorUserId: initiatorUserId ?? this.initiatorUserId,
      partnerUserId: partnerUserId ?? this.partnerUserId,
      topic: topic ?? this.topic,
      status: status ?? this.status,
      currentTurn: currentTurn ?? this.currentTurn,
      totalTurns: totalTurns ?? this.totalTurns,
      turns: turns ?? this.turns,
      finalSummary: finalSummary ?? this.finalSummary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Métodos de utilidad
  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isPaused => status == 'paused';
  bool get isCancelled => status == 'cancelled';

  String getPartnerUserId(String currentUserId) {
    return initiatorUserId == currentUserId ? partnerUserId : initiatorUserId;
  }

  bool isUserTurn(String userId) => currentTurn == userId;

  ConversationTurn? get lastTurn => turns.isNotEmpty ? turns.last : null;

  bool get needsListenerSummary =>
      lastTurn != null && !lastTurn!.isValidated;

  @override
  String toString() {
    return 'GuidedConversation(id: $id, status: $status, totalTurns: $totalTurns)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GuidedConversation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
