// ============================================================================
// FILE: lib/services/scalable_chat_service.dart
// PURPOSE: Production-ready scalable chat service with sharding and optimization
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../core/constants/app_constants.dart';
import '../core/errors/error_handler.dart';
import '../data/models/chat_model.dart';
import '../data/models/message_model.dart';

class ScalableChatService {
  static final ScalableChatService _instance = ScalableChatService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Sharding configuration
  static const CHAT_SHARD_COUNT = 10;
  static const MESSAGE_SHARD_COUNT = 50;
  static const CHATS_PER_PAGE = 50;
  static const MESSAGES_PER_BATCH = 100;
  
  // Caching configuration
  static const MAX_CACHE_SIZE_MB = 50;
  static const MAX_CACHE_ENTRIES = 10000;
  static const CACHE_TTL = Duration(minutes: 30);
  
  // Retry configuration
  static const MAX_RETRIES = 3;
  static const RETRY_DELAY = Duration(seconds: 1);
  
  // Connection management
  final StreamController<NetworkStatus> _networkStatusController = 
      StreamController.broadcast();
  NetworkStatus _currentNetworkStatus = NetworkStatus.unknown;
  
  factory ScalableChatService() => _instance;

  ScalableChatService._internal() {
    _initializeNetworkMonitoring();
  }

  /// Initialize network monitoring
  void _initializeNetworkMonitoring() {
    Connectivity().onConnectivityChanged.listen((result) {
      final newStatus = _mapConnectivityResult(result);
      if (newStatus != _currentNetworkStatus) {
        _currentNetworkStatus = newStatus;
        _networkStatusController.add(newStatus);
        _handleNetworkStatusChange(newStatus);
      }
    });
  }

  NetworkStatus _mapConnectivityResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.ethernet:
      case ConnectivityResult.mobile:
        return NetworkStatus.connected;
      case ConnectivityResult.none:
        return NetworkStatus.disconnected;
      default:
        return NetworkStatus.unknown;
    }
  }

  void _handleNetworkStatusChange(NetworkStatus status) async {
    switch (status) {
      case NetworkStatus.connected:
        await _syncPendingOperations();
        break;
      case NetworkStatus.disconnected:
        // Show offline notification
        break;
      case NetworkStatus.unknown:
        break;
    }
  }

  /// Get user chats with sharding and pagination
  Future<List<Chat>> getUserChats(String userId, {int page = 0}) async {
    final shardId = _getUserShardId(userId);
    final offset = page * CHATS_PER_PAGE;
    
    try {
      // Get chat references from user shard
      final shardDoc = await _firestore
          .collection('user_chat_shards')
          .doc(shardId)
          .get();
      
      if (!shardDoc.exists) {
        return [];
      }
      
      final chatRefs = (shardDoc.data()?['chatRefs'] as List<dynamic>?)
          ?.map((ref) => _firestore.doc(ref as String))
          .toList() ?? [];
      
      if (chatRefs.isEmpty) {
        return [];
      }
      
      // Batch get chat documents
      final chatSnapshots = await _firestore.getAll(chatRefs);
      final chats = <Chat>[];
      
      for (final snapshot in chatSnapshots) {
        if (snapshot.exists) {
          final chat = Chat.fromMap(snapshot.data()!);
          chats.add(chat);
        }
      }
      
      // Sort by last activity and paginate
      chats.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
      return chats.skip(offset).take(CHATS_PER_PAGE).toList();
      
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'ScalableChatService.getUserChats');
      return [];
    }
  }

  /// Create chat with sharding
  Future<String> createChat({
    required List<String> participants,
    required String chatName,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final chatId = _generateOptimizedId();
      final shardId = _getChatShardId(chatId);
      final timestamp = FieldValue.serverTimestamp();
      
      // Create chat document in shard
      final chatRef = _firestore.collection('chat_shards').doc(shardId).collection('chats').doc(chatId);
      await chatRef.set({
        'id': chatId,
        'participants': participants,
        'name': chatName,
        'metadata': metadata ?? {},
        'createdAt': timestamp,
        'lastActivity': timestamp,
        'messageCount': 0,
        'shardId': shardId,
      });
      
      // Update user chat references
      await _updateUserChatReferences(participants, chatRef.path);
      
      return chatId;
      
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'ScalableChatService.createChat');
      rethrow;
    }
  }

  /// Send message with idempotency and retry logic
  Future<void> sendMessage({
    required String chatId,
    required String content,
    required MessageType messageType,
    String? mediaUrl,
    Map<String, dynamic>? metadata,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    final messageId = _generateMessageId(chatId, content, userId);
    final shardId = _getChatShardId(chatId);
    
    // Check for duplicate message
    if (await _isDuplicateMessage(messageId)) {
      return; // Message already sent
    }
    
    // Store locally first
    await _storeLocalMessage(chatId, messageId, content, messageType, mediaUrl, metadata);
    
    // Send with retry logic
    await _sendMessageWithRetry(chatId, shardId, messageId, userId, content, messageType, mediaUrl, metadata);
  }

  Future<void> _sendMessageWithRetry(
    String chatId,
    String shardId,
    String messageId,
    String senderId,
    String content,
    MessageType messageType,
    String? mediaUrl,
    Map<String, dynamic>? metadata,
  ) async {
    for (var attempt = 1; attempt <= MAX_RETRIES; attempt++) {
      try {
        await _firestore.runTransaction((transaction) async {
          // Check chat exists
          final chatRef = _firestore.collection('chat_shards').doc(shardId).collection('chats').doc(chatId);
          final chatSnapshot = await transaction.get(chatRef);
          
          if (!chatSnapshot.exists) {
            throw Exception('Chat not found');
          }
          
          // Create message
          final messageRef = _firestore.collection('message_shards').doc(shardId).collection('messages').doc(messageId);
          final timestamp = FieldValue.serverTimestamp();
          
          transaction.set(messageRef, {
            'id': messageId,
            'chatId': chatId,
            'senderId': senderId,
            'content': content,
            'type': messageType.name,
            'mediaUrl': mediaUrl ?? '',
            'metadata': metadata ?? {},
            'timestamp': timestamp,
            'shardId': shardId,
          });
          
          // Update chat metadata
          final currentCount = chatSnapshot.data()?['messageCount'] as int? ?? 0;
          transaction.update(chatRef, {
            'lastActivity': timestamp,
            'messageCount': currentCount + 1,
          });
        });
        
        // Mark as sent successfully
        await _markMessageAsSent(messageId);
        return;
        
      } catch (e) {
        if (attempt == MAX_RETRIES) {
          await _handleSendMessageFailure(messageId, e);
          rethrow;
        }
        
        // Wait before retry
        await Future.delayed(RETRY_DELAY * attempt);
     

[Response interrupted by a tool use result. Only one tool may be used at a time and should be placed at the end of the message.]