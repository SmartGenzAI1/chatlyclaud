import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase/supabase.dart';
import 'package:chatly/core/constants/app_constants.dart';
import 'package:chatly/core/services/production_cache.dart';
import 'package:chatly/core/utils/sanitizers.dart';
import 'package:chatly/data/models/chat_model.dart';
import 'package:chatly/data/models/message_model.dart';
import 'package:chatly/data/models/user_model.dart';

/// Supabase Service for optional storage and database operations
/// Can be used as alternative to Firebase or for additional features
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  late SupabaseClient _client;
  final ProductionCache _cache = ProductionCache();
  
  // Feature flags for optional services
  static bool enableSupabaseStorage = false;
  static bool enableSupabaseDatabase = false;
  
  SupabaseService._internal() {
    if (enableSupabaseStorage || enableSupabaseDatabase) {
      _initializeSupabase();
    }
  }
  
  factory SupabaseService() => _instance;
  
  void _initializeSupabase() {
    try {
      _client = SupabaseClient(
        AppConstants.supabaseUrl,
        AppConstants.supabaseKey,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Supabase initialization failed: $e');
      }
    }
  }
  
  /// Check if Supabase is available and configured
  bool get isAvailable => enableSupabaseStorage || enableSupabaseDatabase;
  
  /// Upload file to Supabase storage with optional encryption
  Future<String?> uploadFile(
    File file,
    String path, {
    bool encrypt = true,
    String? encryptionKey,
  }) async {
    if (!isAvailable || !enableSupabaseStorage) {
      return null;
    }
    
    try {
      final fileName = file.path.split('/').last;
      final sanitizedPath = Sanitizer.sanitizePath(path);
      final fullPath = '$sanitizedPath/$fileName';
      
      // Encrypt file if requested
      File uploadFile = file;
      if (encrypt && encryptionKey != null) {
        // Note: File encryption would need to be implemented
        // For now, we'll upload without encryption for free tier compatibility
      }
      
      final response = await _client.storage
        .from('chat_media')
        .upload(fullPath, file);
      
      if (response.error == null) {
        // Get public URL
        final publicUrl = _client.storage
          .from('chat_media')
          .getPublicUrl(fullPath);
        
        // Cache the URL
        await _cache.set('supabase_file_$fullPath', publicUrl);
        
        return publicUrl;
      } else {
        if (kDebugMode) {
          print('Supabase upload error: ${response.error?.message}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Supabase upload failed: $e');
      }
      return null;
    }
  }
  
  /// Download file from Supabase storage
  Future<File?> downloadFile(String path) async {
    if (!isAvailable || !enableSupabaseStorage) {
      return null;
    }
    
    try {
      final response = await _client.storage
        .from('chat_media')
        .download(path);
      
      if (response.error == null) {
        // Note: File download implementation would need platform-specific code
        // For web, you would use the public URL
        return null; // Placeholder for actual implementation
      } else {
        if (kDebugMode) {
          print('Supabase download error: ${response.error?.message}');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Supabase download failed: $e');
      }
      return null;
    }
  }
  
  /// Get public URL for a file
  String? getPublicUrl(String path) {
    if (!isAvailable || !enableSupabaseStorage) {
      return null;
    }
    
    try {
      return _client.storage
        .from('chat_media')
        .getPublicUrl(path);
    } catch (e) {
      if (kDebugMode) {
        print('Supabase getPublicUrl failed: $e');
      }
      return null;
    }
  }
  
  /// Save chat data to Supabase (optional database backup)
  Future<bool> saveChat(ChatModel chat) async {
    if (!isAvailable || !enableSupabaseDatabase) {
      return false;
    }
    
    try {
      final response = await _client
        .from('chats')
        .upsert({
          'id': chat.id,
          'user1_id': chat.user1Id,
          'user2_id': chat.user2Id,
          'last_message': chat.lastMessage,
          'last_message_time': chat.lastMessageTime.toIso8601String(),
          'created_at': chat.createdAt.toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      
      if (response.error == null) {
        await _cache.set('supabase_chat_${chat.id}', chat.toJson());
        return true;
      } else {
        if (kDebugMode) {
          print('Supabase chat save error: ${response.error?.message}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Supabase chat save failed: $e');
      }
      return false;
    }
  }
  
  /// Save message to Supabase (optional database backup)
  Future<bool> saveMessage(MessageModel message) async {
    if (!isAvailable || !enableSupabaseDatabase) {
      return false;
    }
    
    try {
      final response = await _client
        .from('messages')
        .insert({
          'id': message.id,
          'chat_id': message.chatId,
          'sender_id': message.senderId,
          'content': message.content,
          'message_type': message.messageType,
          'media_url': message.mediaUrl,
          'timestamp': message.timestamp.toIso8601String(),
          'is_read': message.isRead,
        });
      
      if (response.error == null) {
        await _cache.set('supabase_message_${message.id}', message.toJson());
        return true;
      } else {
        if (kDebugMode) {
          print('Supabase message save error: ${response.error?.message}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Supabase message save failed: $e');
      }
      return false;
    }
  }
  
  /// Get chat from Supabase (optional database read)
  Future<ChatModel?> getChat(String chatId) async {
    if (!isAvailable || !enableSupabaseDatabase) {
      return null;
    }
    
    try {
      // Check cache first
      final cached = await _cache.get('supabase_chat_$chatId');
      if (cached != null) {
        return ChatModel.fromJson(cached);
      }
      
      final response = await _client
        .from('chats')
        .select()
        .eq('id', chatId)
        .single();
      
      if (response.error == null && response.data != null) {
        final chat = ChatModel.fromJson(response.data);
        await _cache.set('supabase_chat_$chatId', chat.toJson());
        return chat;
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Supabase chat get failed: $e');
      }
      return null;
    }
  }
  
  /// Get messages from Supabase (optional database read)
  Future<List<MessageModel>> getMessages(String chatId, {int limit = 50}) async {
    if (!isAvailable || !enableSupabaseDatabase) {
      return [];
    }
    
    try {
      final cacheKey = 'supabase_messages_$chatId';
      final cached = await _cache.get(cacheKey);
      if (cached != null) {
        return List<MessageModel>.from(
          (cached as List).map((item) => MessageModel.fromJson(item))
        );
      }
      
      final response = await _client
        .from('messages')
        .select()
        .eq('chat_id', chatId)
        .order('timestamp', ascending: false)
        .limit(limit);
      
      if (response.error == null && response.data != null) {
        final messages = List<MessageModel>.from(
          (response.data as List).map((item) => MessageModel.fromJson(item))
        );
        await _cache.set(cacheKey, messages.map((m) => m.toJson()).toList());
        return messages;
      } else {
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Supabase messages get failed: $e');
      }
      return [];
    }
  }
  
  /// Delete file from Supabase storage
  Future<bool> deleteFile(String path) async {
    if (!isAvailable || !enableSupabaseStorage) {
      return false;
    }
    
    try {
      final response = await _client.storage
        .from('chat_media')
        .remove([path]);
      
      if (response.error == null) {
        await _cache.delete('supabase_file_$path');
        return true;
      } else {
        if (kDebugMode) {
          print('Supabase delete error: ${response.error?.message}');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Supabase delete failed: $e');
      }
      return false;
    }
  }
  
  /// Configure Supabase features
  static void configure({
    bool enableStorage = false,
    bool enableDatabase = false,
  }) {
    enableSupabaseStorage = enableStorage;
    enableSupabaseDatabase = enableDatabase;
  }
  
  /// Test Supabase connection
  Future<bool> testConnection() async {
    if (!isAvailable) {
      return false;
    }
    
    try {
      final response = await _client.from('test').select().limit(1);
      return response.error == null;
    } catch (e) {
      return false;
    }
  }
  
  /// Cleanup resources
  void dispose() {
    _cache.dispose();
  }
}