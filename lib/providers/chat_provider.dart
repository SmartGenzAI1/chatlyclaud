// ============================================================================
// FILE: lib/providers/chat_provider.dart
// PURPOSE: Chat and messaging state management
// ============================================================================

import 'package:flutter/material.dart';
import '../data/models/chat_model.dart';
import '../data/models/message_model.dart';
import '../services/chat_service.dart';
import '../core/errors/error_handler.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  
  List<ChatModel> _chats = [];
  Map<String, List<MessageModel>> _messages = {};
  bool _isLoading = false;
  String? _error;
  
  List<ChatModel> get chats => _chats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Get messages for a specific chat
  List<MessageModel> getMessages(String chatId) {
    return _messages[chatId] ?? [];
  }
  
  /// Load user chats
  void loadUserChats(String userId) {
    _chatService.getUserChatsStream(userId).listen(
      (chats) {
        _chats = chats;
        notifyListeners();
      },
      onError: (e, stackTrace) {
        _error = ErrorHandler.getUserFriendlyError(e);
        ErrorHandler.logError(e, stackTrace, context: 'ChatProvider.loadUserChats');
        notifyListeners();
      },
    );
  }
  
  /// Load messages for a chat
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
  
  /// Send message
  Future<bool> sendMessage(
    String chatId,
    String senderId,
    String text,
    int retentionDays,
  ) async {
    _error = null;
    
    try {
      await _chatService.sendMessage(chatId, senderId, text, retentionDays);
      return true;
    } catch (e, stackTrace) {
      _error = ErrorHandler.getUserFriendlyError(e);
      await ErrorHandler.logError(e, stackTrace, context: 'ChatProvider.sendMessage');
      notifyListeners();
      return false;
    }
  }
  
  /// Create or get chat
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
  
  /// Mark message as read
  Future<void> markAsRead(String chatId, String messageId, String userId) async {
    try {
      await _chatService.markMessageAsRead(chatId, messageId, userId);
    } catch (e, stackTrace) {
      await ErrorHandler.logError(e, stackTrace, context: 'ChatProvider.markAsRead');
    }
  }
  
  /// Add reaction
  Future<void> addReaction(
    String chatId,
    String messageId,
    String emoji,
    String userId,
  ) async {
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
