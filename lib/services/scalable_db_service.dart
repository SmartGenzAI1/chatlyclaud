// ============================================================================
// FILE: lib/services/scalable_db_service.dart
// PURPOSE: Scalable database service with temporary storage and binary optimization
// ============================================================================

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/error_handler.dart';

class ScalableDBService {
  static final ScalableDBService _instance = ScalableDBService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  factory ScalableDBService() => _instance;

  ScalableDBService._internal();

  /// Optimized message storage with binary encoding
  Future<String> storeMessage({
    required String chatId,
    required String senderId,
    required String content,
    required String encryptedContent,
    required Map<String, dynamic> metadata,
    MessageType messageType = MessageType.text,
    String? mediaUrl,
    Duration retentionPeriod = const Duration(hours: 24),
  }) async {
    try {
      final messageId = _generateOptimizedId();
      final timestamp = FieldValue.serverTimestamp();
      final expiresAt = Timestamp.fromDate(DateTime.now().add(retentionPeriod));

      // Binary optimization: Convert to compact binary format
      final binaryData = _convertToBinaryFormat({
        'id': messageId,
        'chatId': chatId,
        'senderId': senderId,
        'content': encryptedContent,
        'metadata': metadata,
        'type': messageType.name,
        'mediaUrl': mediaUrl ?? '',
        'timestamp': timestamp,
        'expiresAt': expiresAt,
        'isEncrypted': true,
      });

      final docRef = _firestore.collection('messages').doc(messageId);
      await docRef.set({
        'data': binaryData,
        'expiresAt': expiresAt,
        'chatId': chatId,
        'senderId': senderId,
        'type': messageType.name,
      });

      // Set up automatic cleanup
      await _scheduleCleanup(messageId, expiresAt.toDate());

      return messageId;
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'ScalableDBService.storeMessage');
      rethrow;
    }
  }

  /// Retrieve and decrypt message
  Future<Map<String, dynamic>> retrieveMessage(String messageId, String privateKey) async {
    try {
      final doc = await _firestore.collection('messages').doc(messageId).get();
      
      if (!doc.exists) {
        throw Exception('Message not found or expired');
      }

      final data = doc.data()!;
      final binaryData = data['data'] as String;
      
      // Convert from binary format
      final messageData = _convertFromBinaryFormat(binaryData);
      
      // Decrypt content if encrypted
      String decryptedContent = messageData['content'];
      if (messageData['isEncrypted'] == true) {
        decryptedContent = _decryptBinaryContent(messageData['content'], privateKey);
      }

      return {
        'id': messageData['id'],
        'chatId': messageData['chatId'],
        'senderId': messageData['senderId'],
        'content': decryptedContent,
        'metadata': messageData['metadata'],
        'type': messageData['type'],
        'mediaUrl': messageData['mediaUrl'],
        'timestamp': messageData['timestamp'],
        'expiresAt': messageData['expiresAt'],
      };
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'ScalableDBService.retrieveMessage');
      rethrow;
    }
  }

  /// Store user data with binary optimization
  Future<void> storeUserData(String userId, Map<String, dynamic> userData) async {
    try {
      // Binary optimization for user data
      final binaryData = _convertToBinaryFormat(userData);
      
      await _firestore.collection('users').doc(userId).set({
        'data': binaryData,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'ScalableDBService.storeUserData');
      rethrow;
    }
  }

  /// Retrieve user data
  Future<Map<String, dynamic>> retrieveUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      
      if (!doc.exists) {
        throw Exception('User data not found');
      }

      final data = doc.data()!;
      final binaryData = data['data'] as String;
      
      return _convertFromBinaryFormat(binaryData);
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'ScalableDBService.retrieveUserData');
      rethrow;
    }
  }

  /// Optimized chat creation with binary storage
  Future<String> createChat({
    required List<String> participants,
    required String chatName,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final chatId = _generateOptimizedId();
      final timestamp = FieldValue.serverTimestamp();

      final binaryMetadata = metadata != null 
          ? _convertToBinaryFormat(metadata)
          : '';

      await _firestore.collection('chats').doc(chatId).set({
        'id': chatId,
        'participants': participants,
        'name': chatName,
        'metadata': binaryMetadata,
        'createdAt': timestamp,
        'lastActivity': timestamp,
        'messageCount': 0,
      });

      return chatId;
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'ScalableDBService.createChat');
      rethrow;
    }
  }

  /// Get optimized chat list for user
  Future<List<Map<String, dynamic>>> getUserChats(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('chats')
          .where('participants', arrayContains: userId)
          .orderBy('lastActivity', descending: true)
          .limit(50)
          .get();

      final chats = <Map<String, dynamic>>[];
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final metadata = data['metadata'] as String;
        
        chats.add({
          'id': data['id'],
          'participants': data['participants'],
          'name': data['name'],
          'metadata': metadata.isNotEmpty ? _convertFromBinaryFormat(metadata) : {},
          'createdAt': data['createdAt'],
          'lastActivity': data['lastActivity'],
          'messageCount': data['messageCount'],
        });
      }

      return chats;
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'ScalableDBService.getUserChats');
      rethrow;
   

[Response interrupted by a tool use result. Only one tool may be used at a time and should be placed at the end of the message.]