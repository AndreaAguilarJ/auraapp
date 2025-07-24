import 'dart:convert';

class ConversationInvitation {
  final String? id;
  final String fromUserId;
  final String fromUserName;
  final String toUserId;
  final String toUserName;
  final Map<String, dynamic> topic;
  final String status; // pending, accepted, rejected, expired
  final DateTime createdAt;
  final DateTime? respondedAt;
  final DateTime expiresAt;
  final String? message; // Mensaje opcional del invitador

  const ConversationInvitation({
    this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.toUserName,
    required this.topic,
    required this.status,
    required this.createdAt,
    this.respondedAt,
    required this.expiresAt,
    this.message,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '\$id': id,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'toUserId': toUserId,
      'toUserName': toUserName,
      'topic': jsonEncode(topic),
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      if (respondedAt != null) 'respondedAt': respondedAt!.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      if (message != null) 'message': message,
    };
  }

  factory ConversationInvitation.fromMap(Map<String, dynamic> map) {
    return ConversationInvitation(
      id: map['\$id'],
      fromUserId: map['fromUserId'] ?? '',
      fromUserName: map['fromUserName'] ?? '',
      toUserId: map['toUserId'] ?? '',
      toUserName: map['toUserName'] ?? '',
      topic: map['topic'] != null
          ? (map['topic'] is String ? jsonDecode(map['topic']) : map['topic'])
          : {},
      status: map['status'] ?? 'pending',
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      respondedAt: map['respondedAt'] != null
          ? DateTime.parse(map['respondedAt'])
          : null,
      expiresAt: DateTime.parse(map['expiresAt'] ?? DateTime.now().add(Duration(hours: 24)).toIso8601String()),
      message: map['message'],
    );
  }

  ConversationInvitation copyWith({
    String? id,
    String? fromUserId,
    String? fromUserName,
    String? toUserId,
    String? toUserName,
    Map<String, dynamic>? topic,
    String? status,
    DateTime? createdAt,
    DateTime? respondedAt,
    DateTime? expiresAt,
    String? message,
  }) {
    return ConversationInvitation(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUserName: fromUserName ?? this.fromUserName,
      toUserId: toUserId ?? this.toUserId,
      toUserName: toUserName ?? this.toUserName,
      topic: topic ?? this.topic,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      message: message ?? this.message,
    );
  }

  // Métodos de utilidad
  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  bool get isExpired => status == 'expired' || DateTime.now().isAfter(expiresAt);
  bool get canRespond => isPending && !isExpired;

  String get topicTitle => topic['title']?.toString() ?? 'Conversación guiada';
  String get topicDescription => topic['description']?.toString() ?? '';

  @override
  String toString() {
    return 'ConversationInvitation(id: $id, from: $fromUserName, to: $toUserName, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConversationInvitation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
