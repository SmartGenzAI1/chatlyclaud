// ============================================================================
// FILE: lib/services/chat_service.dart
// PURPOSE: Real-time encrypted messaging with Signal Protocol Double Ratchet
// ============================================================================

import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/message_model.dart';
import '../data/models/chat_model.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/error_handler.dart';
import '../core/utils/sanitizers.dart';
import 'signal_protocol.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, SignalProtocol> _sessions = {};

  /// Get or initialize a signal session for a chat
  SignalProtocol _getSession(String chatId) {
    if (!_sessions.containsKey(chatId)) {
      final session = SignalProtocol();
      final seed = utf8.encode('chatly_${chatId}_${DateTime.now().millisecondsSinceEpoch}');
      session.initializeFromSharedSecret(
        Uint8List.fromList(seed.take(32).toList().sublist(0, seed.length.clamp(0, 32) as int)),
      );
      _sessions[chatId] = session;
    }
    return _sessions[chatId]!;
  }

  /// Create or get existing one-to-one chat
  Future<String> createOrGetChat(String userId1, String userId2) async {
    try {
      final participants = [userId1, userId2]..sort();
      final chatId = '${participants[0]}_${participants[1]}';

      final chatRef = _firestore.collection('chats').doc(chatId);
      final chatDoc = await chatRef.get();

      if (!chatDoc.exists) {
        final chat = ChatModel(
          chatId: chatId,
          participants: participants,
          createdAt: DateTime.now(),
          lastMessageAt: DateTime.now(),
        );
        await chatRef.set(chat.toFirestore());
        
        final session = _getSession(chatId);
        await chatRef.update({
          'publicKeys': {
            userId1: base64Encode(session.getPublicKey()),
          }
        });
      }

      return chatId;
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'createOrGetChat');
      rethrow;
    }
  }

  /// Send an end-to-end encrypted message using Double Ratchet
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    required int retentionDays,
  }) async {
    try {
      final sanitizedText = Sanitizers.sanitizeMessage(text);
      final session = _getSession(chatId);
      final step = session.performRatchetStep(null);
      final encryptedText = session.encryptWithKey(sanitizedText, step.messageKey);

      final message = MessageModel(
        messageId: '',
        chatId: chatId,
        senderId: senderId,
        text: encryptedText,
        timestamp: DateTime.now(),
        readBy: [senderId],
        expiresAt: DateTime.now().add(Duration(days: retentionDays)),
        isEncrypted: true,
      );

      final msgRef = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message.toFirestore());

      await msgRef.update({
        'ratchetIndex': step.index,
        'publicKey': base64Encode(step.publicKey),
      });

      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': '[encrypted]',
        'lastSenderId': senderId,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'publicKeys.$senderId': base64Encode(session.getPublicKey()),
      });

    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'sendMessage');
      rethrow;
    }
  }

  /// Get messages stream for a chat
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
          .map((doc) {
            final msg = MessageModel.fromFirestore(doc);
            if (msg.hasExpired) return null;
            return msg;
          })
          .whereType<MessageModel>()
          .toList();
    });
  }

  /// Decrypt a message using the signal session
  String decryptMessage(MessageModel message, String chatId, Map<String, dynamic>? metadata) {
    if (!message.isEncrypted) return message.text;
    try {
      final session = _getSession(chatId);
      final pubKey = metadata?['publicKey'] as String?;
      final index = metadata?['ratchetIndex'] as int?;
      
      Uint8List? msgKey;
      if (pubKey != null && index != null) {
        msgKey = session.receiveRatchetStep(base64Decode(pubKey), index);
      }
      
      if (msgKey != null) {
        return session.decryptWithKey(message.text, msgKey);
      }
      return '[Unable to decrypt message]';
    } catch (_) {
      return '[Unable to decrypt message]';
    }
  }

  Future<void> markMessageAsRead(String chatId, String messageId, String userId) async {
    try {
      await _firestore.collection('chats').doc(chatId)
          .collection('messages').doc(messageId).update({
        'readBy': FieldValue.arrayUnion([userId]),
      });
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'markMessageAsRead');
    }
  }

  Future<void> addReaction(String chatId, String messageId, String emoji, String userId) async {
    try {
      await _firestore.collection('chats').doc(chatId)
          .collection('messages').doc(messageId).update({
        'reactions.$emoji': FieldValue.arrayUnion([userId]),
      });
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'addReaction');
    }
  }

  Stream<List<ChatModel>> getUserChatsStream(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList());
  }

  Future<int> deleteExpiredMessages() async {
    try {
      final expired = await _firestore
          .collectionGroup('messages')
          .where('expiresAt', isLessThan: Timestamp.fromDate(DateTime.now()))
          .get();
      if (expired.docs.isEmpty) return 0;
      final batch = _firestore.batch();
      for (final doc in expired.docs) batch.delete(doc.reference);
      await batch.commit();
      return expired.docs.length;
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'deleteExpiredMessages');
      return 0;
    }
  }

  /// Create a group chat
  Future<String> createGroupChat({
    required String name,
    required String creatorId,
    required List<String> memberIds,
  }) async {
    try {
      final allMembers = [creatorId, ...memberIds];
      final groupId = 'group_${DateTime.now().millisecondsSinceEpoch}';
      
      await _firestore.collection('chats').doc(groupId).set({
        'chatId': groupId,
        'participants': allMembers,
        'isGroup': true,
        'groupName': name,
        'createdBy': creatorId,
        'createdAt': Timestamp.fromDate(DateTime.now()),
        'lastMessageAt': Timestamp.fromDate(DateTime.now()),
      });
      return groupId;
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'createGroupChat');
      rethrow;
    }
  }

  /// Send a media message
  Future<void> sendMediaMessage({
    required String chatId,
    required String senderId,
    required String mediaUrl,
    required MessageType type,
    String? thumbnailUrl,
    int retentionDays = 7,
  }) async {
    try {
      final session = _getSession(chatId);
      final step = session.performRatchetStep(null);
      final encryptedUrl = session.encryptWithKey(mediaUrl, step.messageKey);

      final message = MessageModel(
        messageId: '',
        chatId: chatId,
        senderId: senderId,
        text: encryptedUrl,
        timestamp: DateTime.now(),
        readBy: [senderId],
        expiresAt: DateTime.now().add(Duration(days: retentionDays)),
        isEncrypted: true,
        messageType: type,
        mediaUrl: mediaUrl,
        mediaThumbnailUrl: thumbnailUrl,
      );

      final msgRef = await _firestore.collection('chats').doc(chatId)
          .collection('messages').add(message.toFirestore());

      await msgRef.update({
        'ratchetIndex': step.index,
        'publicKey': base64Encode(step.publicKey),
      });

      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': type == MessageType.image ? '[Image]' : '[File]',
        'lastSenderId': senderId,
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'sendMediaMessage');
      rethrow;
    }
  }

  /// Get group chats stream
  Stream<List<ChatModel>> getGroupChatsStream(String userId) {
    return _firestore.collection('chats')
        .where('participants', arrayContains: userId)
        .where('isGroup', isEqualTo: true)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList());
  }
}
