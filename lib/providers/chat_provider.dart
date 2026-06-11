// ============================================================================
// FILE: lib/providers/chat_provider.dart
// PURPOSE: Chat state management with Signal Protocol encryption
// ============================================================================

import 'package:flutter/material.dart';
import '../data/models/chat_model.dart';
import '../data/models/message_model.dart';
import '../services/chat_service.dart';
import '../core/errors/error_handler.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();

  List<ChatModel> _chats = [];
  List<ChatModel> _groupChats = [];
  Map<String, List<MessageModel>> _messages = {};
  Map<String, Map<String, Map<String, dynamic>>> _messageMetadata = {};
  bool _isLoading = false;
  String? _error;

  List<ChatModel> get chats => _chats;
  List<ChatModel> get groupChats => _groupChats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<MessageModel> getMessages(String chatId) => _messages[chatId] ?? [];

  /// Decrypt a message for display using Signal Protocol
  String decryptMessage(MessageModel message, String chatId) {
    if (!message.isEncrypted) return message.text;
    final meta = _messageMetadata[chatId]?[message.messageId];
    return _chatService.decryptMessage(message, chatId, meta);
  }

  void loadUserChats(String userId) {
    _chatService.getUserChatsStream(userId).listen(
      (chats) {
        _chats = chats.where((c) => c.isGroup != true).toList();
        _groupChats = chats.where((c) => c.isGroup == true).toList();
        notifyListeners();
      },
      onError: (e, stackTrace) {
        _error = ErrorHandler.getUserFriendlyError(e);
        ErrorHandler.logError(e, stackTrace, context: 'ChatProvider.loadUserChats');
        notifyListeners();
      },
    );
  }

  void loadMessages(String chatId) {
    _chatService.getMessagesStream(chatId).listen(
      (messages) {
        _messages[chatId] = messages;
        notifyListeners();
      },
      onError: (e, stackTrace) {
        _error = ErrorHandler.getUserFriendlyError(e);
        ErrorHandler.logError(e, stackTrace, context: 'ChatProvider.loadMessages');
        notifyListeners();
      },
    );
  }

  /// Store message metadata for decryption
  void cacheMessageMetadata(String chatId, String messageId, Map<String, dynamic> metadata) {
    _messageMetadata[chatId] ??= {};
    _messageMetadata[chatId]![messageId] = metadata;
  }

  Future<bool> sendMessage(String chatId, String senderId, String text, int retentionDays) async {
    _error = null;
    try {
      await _chatService.sendMessage(
        chatId: chatId,
        senderId: senderId,
        text: text,
        retentionDays: retentionDays,
      );
      return true;
    } catch (e, stackTrace) {
      _error = ErrorHandler.getUserFriendlyError(e);
      await ErrorHandler.logError(e, stackTrace, context: 'ChatProvider.sendMessage');
      notifyListeners();
      return false;
    }
  }

  Future<String?> createOrGetChat(String userId1, String userId2) async {
    _error = null;
    try {
      return await _chatService.createOrGetChat(userId1, userId2);
    } catch (e, stackTrace) {
      _error = ErrorHandler.getUserFriendlyError(e);
      await ErrorHandler.logError(e, stackTrace, context: 'ChatProvider.createOrGetChat');
      notifyListeners();
      return null;
    }
  }

  /// Create a group chat
  Future<String?> createGroupChat(String name, String creatorId, List<String> memberIds) async {
    _error = null;
    try {
      return await _chatService.createGroupChat(
        name: name,
        creatorId: creatorId,
        memberIds: memberIds,
      );
    } catch (e, stackTrace) {
      _error = ErrorHandler.getUserFriendlyError(e);
      await ErrorHandler.logError(e, stackTrace, context: 'ChatProvider.createGroupChat');
      notifyListeners();
      return null;
    }
  }

  /// Send a media message (image/file)
  Future<bool> sendMediaMessage({
    required String chatId,
    required String senderId,
    required String mediaUrl,
    required MessageType type,
    String? thumbnailUrl,
    int retentionDays = 7,
  }) async {
    _error = null;
    try {
      await _chatService.sendMediaMessage(
        chatId: chatId,
        senderId: senderId,
        mediaUrl: mediaUrl,
        type: type,
        thumbnailUrl: thumbnailUrl,
        retentionDays: retentionDays,
      );
      return true;
    } catch (e, stackTrace) {
      _error = ErrorHandler.getUserFriendlyError(e);
      await ErrorHandler.logError(e, stackTrace, context: 'ChatProvider.sendMediaMessage');
      notifyListeners();
      return false;
    }
  }

  Future<void> markAsRead(String chatId, String messageId, String userId) async {
    try {
      await _chatService.markMessageAsRead(chatId, messageId, userId);
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'ChatProvider.markAsRead');
    }
  }

  Future<void> addReaction(String chatId, String messageId, String emoji, String userId) async {
    try {
      await _chatService.addReaction(chatId, messageId, emoji, userId);
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'ChatProvider.addReaction');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
