// ============================================================================
// FILE: lib/data/models/anonymous_model.dart
// PURPOSE: Anonymous message model for Lucky Chat
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class AnonymousMessageModel {
  final String messageId;
  final String hashId; // Anonymous identifier
  final String text;
  final List<String> topics;
  final List<String> seenBy;
  final DateTime timestamp;
  final DateTime expiresAt;
  final String userId; // Hidden from others
  final List<AnonymousReply> replies;
  
  AnonymousMessageModel({
    required this.messageId,
    required this.hashId,
    required this.text,
    required this.topics,
    required this.seenBy,
    required this.timestamp,
    required this.expiresAt,
    required this.userId,
    this.replies = const [],
  });
  
  factory AnonymousMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AnonymousMessageModel(
      messageId: doc.id,
      hashId: data['hashId'] ?? '',
      text: data['text'] ?? '',
      topics: List<String>.from(data['topics'] ?? []),
      seenBy: List<String>.from(data['seenBy'] ?? []),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
      replies: (data['replies'] as List<dynamic>? ?? [])
          .map((r) => AnonymousReply.fromMap(r))
          .toList(),
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'hashId': hashId,
      'text': text,
      'topics': topics,
      'seenBy': seenBy,
      'timestamp': Timestamp.fromDate(timestamp),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'userId': userId,
      'replies': replies.map((r) => r.toMap()).toList(),
    };
  }
  
  bool get hasExpired => DateTime.now().isAfter(expiresAt);
}

class AnonymousReply {
  final String hashId;
  final String text;
  final DateTime timestamp;
  
  AnonymousReply({
    required this.hashId,
    required this.text,
    required this.timestamp,
  });
  
  factory AnonymousReply.fromMap(Map<String, dynamic> map) {
    return AnonymousReply(
      hashId: map['hashId'] ?? '',
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'hashId': hashId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
