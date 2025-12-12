// ============================================================================
// FILE: lib/services/chat_service.dart
// PURPOSE: Chat and messaging service
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/message_model.dart';
import '../data/models/chat_model.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/error_handler.dart';
import '../core/utils/sanitizers.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Create or get existing chat
  Future<String> createOrGetChat(String userId1, String userId2) async {
    try {
      // Sort user IDs to ensure consistent chat ID
      final participants = [userId1, userId2]..sort();
      final chatId = '${participants[0]}_${participants[1]}';
      
      final chatRef = _firestore.collection('chats').doc(chatId);
      final chatDoc = await chatRef.get();
      
      if (!chatDoc.exists) {
        // Create new chat
        final chat = ChatModel(
          chatId: chatId,
          participants: participants,
          createdAt: DateTime.now(),
          lastMessageAt: DateTime.now(),
        );
        
        await chatRef.set(chat.toFirestore());
      }
      
      return chatId;
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'createOrGetChat');
      rethrow;
    }
  }
  
  /// Send message
  Future<void> sendMessage(
    String chatId,
    String senderId,
    String text,
    int retentionDays,
  ) async {
    try {
      // Sanitize message
      final sanitizedText = Sanitizers.sanitizeMessage(text);
      
      // TODO: Check toxicity with Perspective API
      
      // Create message
      final message = MessageModel(
        messageId: '',
        chatId: chatId,
        senderId: senderId,
        text: sanitizedText,
        timestamp: DateTime.now(),
        readBy: [senderId],
        expiresAt: DateTime.now().add(Duration(days: retentionDays)),
        isEncrypted: true,
      );
      
      // Add message to Firestore
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message.toFirestore());
      
      // Update chat last message
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': sanitizedText,
        'lastSenderId': senderId,
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
      
      // Increment unread count for other participant
      // TODO: Implement unread count increment
      
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'sendMessage');
      rethrow;
    }
  }
  
  /// Get messages stream
  Stream<List<MessageModel>> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc))
          .where((msg) => !msg.hasExpired)
          .toList();
    });
  }
  
  /// Mark message as read
  Future<void> markMessageAsRead(
    String chatId,
    String messageId,
    String userId,
  ) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({
        'readBy': FieldValue.arrayUnion([userId]),
      });
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'markMessageAsRead');
    }
  }
  
  /// Add reaction to message
  Future<void> addReaction(
    String chatId,
    String messageId,
    String emoji,
    String userId,
  ) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({
        'reactions.$emoji': FieldValue.arrayUnion([userId]),
      });
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'addReaction');
    }
  }
  
  /// Get user chats stream
  Stream<List<ChatModel>> getUserChatsStream(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList();
    });
  }
  
  /// Delete old messages (Cloud Function should handle this)
  Future<void> deleteExpiredMessages() async {
    try {
      final now = DateTime.now();
      
      // Query expired messages
      final expiredMessages = await _firestore
          .collectionGroup('messages')
          .where('expiresAt', isLessThan: Timestamp.fromDate(now))
          .get();
      
      // Delete in batch
      final batch = _firestore.batch();
      for (final doc in expiredMessages.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'deleteExpiredMessages');
    }
  }
}
