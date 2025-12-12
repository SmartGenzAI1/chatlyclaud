// ============================================================================
// FILE: lib/data/models/chat_model.dart
// PURPOSE: Chat/conversation data model
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String chatId;
  final List<String> participants;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final String? lastMessage;
  final String? lastSenderId;
  final Map<String, int> unreadCount;
  
  ChatModel({
    required this.chatId,
    required this.participants,
    required this.createdAt,
    required this.lastMessageAt,
    this.lastMessage,
    this.lastSenderId,
    this.unreadCount = const {},
  });
  
  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ChatModel(
      chatId: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastMessageAt: (data['lastMessageAt'] as Timestamp).toDate(),
      lastMessage: data['lastMessage'],
      lastSenderId: data['lastSenderId'],
      unreadCount: Map<String, int>.from(data['unreadCount'] ?? {}),
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
      'lastMessage': lastMessage,
      'lastSenderId': lastSenderId,
      'unreadCount': unreadCount,
    };
  }
  
  /// Get other participant's ID (for 1-to-1 chat)
  String? getOtherParticipantId(String currentUserId) {
    return participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }
  
  /// Get unread count for user
  int getUnreadCount(String userId) {
    return unreadCount[userId] ?? 0;
  }
}
