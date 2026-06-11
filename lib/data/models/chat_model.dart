// ============================================================================
// FILE: lib/data/models/chat_model.dart
// PURPOSE: Chat/conversation data model with group support
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
  final bool isGroup;
  final String? groupName;
  final String? createdBy;

  ChatModel({
    required this.chatId,
    required this.participants,
    required this.createdAt,
    required this.lastMessageAt,
    this.lastMessage,
    this.lastSenderId,
    this.unreadCount = const {},
    this.isGroup = false,
    this.groupName,
    this.createdBy,
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
      isGroup: data['isGroup'] ?? false,
      groupName: data['groupName'],
      createdBy: data['createdBy'],
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
      'isGroup': isGroup,
      'groupName': groupName,
      'createdBy': createdBy,
    };
  }

  String? getOtherParticipantId(String currentUserId) {
    return participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }

  int getUnreadCount(String userId) {
    return unreadCount[userId] ?? 0;
  }
}
