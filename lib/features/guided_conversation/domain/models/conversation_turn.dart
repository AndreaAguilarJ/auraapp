class ConversationTurn {
  final int turnNumber;
  final String speakerId;
  final String speakerMessage;
  final String listenerUserId;
  final String? listenerSummary;
  final bool isValidated;
  final DateTime timestamp;
  final String? accusationsDetected;

  const ConversationTurn({
    required this.turnNumber,
    required this.speakerId,
    required this.speakerMessage,
    required this.listenerUserId,
    this.listenerSummary,
    required this.isValidated,
    required this.timestamp,
    this.accusationsDetected,
  });

  Map<String, dynamic> toMap() {
    return {
      'turnNumber': turnNumber,
      'speakerId': speakerId,
      'speakerMessage': speakerMessage,
      'listenerUserId': listenerUserId,
      'listenerSummary': listenerSummary,
      'isValidated': isValidated,
      'timestamp': timestamp.toIso8601String(),
      'accusations_detected': accusationsDetected,
    };
  }

  factory ConversationTurn.fromMap(Map<String, dynamic> map) {
    return ConversationTurn(
      turnNumber: map['turnNumber']?.toInt() ?? 0,
      speakerId: map['speakerId'] ?? '',
      speakerMessage: map['speakerMessage'] ?? '',
      listenerUserId: map['listenerUserId'] ?? '',
      listenerSummary: map['listenerSummary'],
      isValidated: map['isValidated'] ?? false,
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      accusationsDetected: map['accusations_detected'],
    );
  }

  ConversationTurn copyWith({
    int? turnNumber,
    String? speakerId,
    String? speakerMessage,
    String? listenerUserId,
    String? listenerSummary,
    bool? isValidated,
    DateTime? timestamp,
    String? accusationsDetected,
  }) {
    return ConversationTurn(
      turnNumber: turnNumber ?? this.turnNumber,
      speakerId: speakerId ?? this.speakerId,
      speakerMessage: speakerMessage ?? this.speakerMessage,
      listenerUserId: listenerUserId ?? this.listenerUserId,
      listenerSummary: listenerSummary ?? this.listenerSummary,
      isValidated: isValidated ?? this.isValidated,
      timestamp: timestamp ?? this.timestamp,
      accusationsDetected: accusationsDetected ?? this.accusationsDetected,
    );
  }

  @override
  String toString() {
    return 'ConversationTurn(turnNumber: $turnNumber, speakerId: $speakerId, isValidated: $isValidated)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConversationTurn &&
        other.turnNumber == turnNumber &&
        other.speakerId == speakerId &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return turnNumber.hashCode ^ speakerId.hashCode ^ timestamp.hashCode;
  }
}
