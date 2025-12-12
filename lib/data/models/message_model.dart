// ============================================================================
// FILE: lib/data/models/message_model.dart
// PURPOSE: Message data model with encryption and expiration
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String messageId;
  final String chatId;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final List<String> readBy;
  final DateTime expiresAt;
  final bool isEncrypted;
  final Map<String, List<String>> reactions;
  final String? replyToMessageId;
  
  MessageModel({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.readBy,
    required this.expiresAt,
    this.isEncrypted = true,
    this.reactions = const {},
    this.replyToMessageId,
  });
  
  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return MessageModel(
      messageId: doc.id,
      chatId: data['chatId'] ?? '',
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      readBy: List<String>.from(data['readBy'] ?? []),
      expiresAt: (data['expiresAt'] as Timestamp).toDate(),
      isEncrypted: data['isEncrypted'] ?? true,
      reactions: Map<String, List<String>>.from(
        (data['reactions'] ?? {}).map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      ),
      replyToMessageId: data['replyToMessageId'],
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'readBy': readBy,
      'expiresAt': Timestamp.fromDate(expiresAt),
      'isEncrypted': isEncrypted,
      'reactions': reactions,
      'replyToMessageId': replyToMessageId,
    };
  }
  
  /// Check if message has expired
  bool get hasExpired => DateTime.now().isAfter(expiresAt);
  
  /// Check if message is read by user
  bool isReadBy(String userId) => readBy.contains(userId);
  
  /// Add reaction
  MessageModel addReaction(String emoji, String userId) {
    final newReactions = Map<String, List<String>>.from(reactions);
    
    if (newReactions.containsKey(emoji)) {
      if (!newReactions[emoji]!.contains(userId)) {
        newReactions[emoji]!.add(userId);
      }
    } else {
      newReactions[emoji] = [userId];
    }
    
    return MessageModel(
      messageId: messageId,
      chatId: chatId,
      senderId: senderId,
      text: text,
      timestamp: timestamp,
      readBy: readBy,
      expiresAt: expiresAt,
      isEncrypted: isEncrypted,
      reactions: newReactions,
      replyToMessageId: replyToMessageId,
    );
  }
}
