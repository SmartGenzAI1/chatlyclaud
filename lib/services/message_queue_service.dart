//============================================================================
// FILE: lib/services/message_queue_service.dart
// PURPOSE: Offline message queue with retry logic
// STABILITY: Auto-retry, exponential backoff, persistent queue
// ============================================================================

import 'dart:async';
import 'dart:collection';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Message queue entry
class QueuedMessage {
  final String id;
  final String chatId;
  final String content;
  final DateTime timestamp;
  final int retryCount;
  final DateTime? nextRetry;
  final MessagePriority priority;
  
  QueuedMessage({
    required this.id,
    required this.chatId,
    required this.content,
    required this.timestamp,
    this.retryCount = 0,
    this.nextRetry,
    this.priority = MessagePriority.normal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'retryCount': retryCount,
      'nextRetry': nextRetry?.toIso8601String(),
      'priority': priority.index,
    };
  }

  factory QueuedMessage.fromMap(Map<String, dynamic> map) {
    return QueuedMessage(
      id: map['id'],
      chatId: map['chatId'],
      content: map['content'],
      timestamp: DateTime.parse(map['timestamp']),
      retryCount: map['retryCount'],
      nextRetry: map['nextRetry'] != null 
          ? DateTime.parse(map['nextRetry'])
          : null,
      priority: MessagePriority.values[map['priority']],
    );
  }
}

enum MessagePriority {
  urgent,   // Retry immediately
  normal,   // Standard retry
  low,      // Retry when convenient
}

/// Message queue service for offline resilience
/// 
/// Features:
/// - Persistent SQLite-backed queue
/// - Exponential backoff (1s, 2s, 4s, 8s, 16s)
/// - Priority-based delivery
/// - Automatic retry on network restore
/// - 7-day message TTL
class MessageQueueService {
  static final MessageQueueService _instance = MessageQueueService._internal();
  
  Database? _database;
  final _queue = Queue<QueuedMessage>();
  Timer? _processTimer;
  
  // Retry configuration
  static const int maxRetries = 5;
  static const int baseRetryDelaySeconds = 1;
  static const int messageTTLDays = 7;
  
  factory MessageQueueService() => _instance;

  MessageQueueService._internal();

  /// Initialize the queue database
  Future<void> initialize() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'message_queue.db');
    
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE message_queue (
            id TEXT PRIMARY KEY,
            chatId TEXT NOT NULL,
            content TEXT NOT NULL,
            timestamp TEXT NOT NULL,
            retryCount INTEGER DEFAULT 0,
            nextRetry TEXT,
            priority INTEGER DEFAULT 1
          )
        ''');
        
        // Index for faster queries
        await db.execute('''
          CREATE INDEX idx_next_retry ON message_queue(nextRetry)
        ''');
      },
    );
    
    // Load pending messages
    await _loadQueue();
    
    // Start background processor
    _startProcessor();
  }

  /// Add message to queue
  Future<void> enqueue(QueuedMessage message) async {
    if (_database == null) {
      throw Exception('Message queue not initialized');
    }
    
    await _database!.insert(
      'message_queue',
      message.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    _queue.add(message);
    _processQueue();
  }

  /// Load queue from database
  Future<void> _loadQueue() async {
    if (_database == null) return;
    
    final maps = await _database!.query(
      'message_queue',
      orderBy: 'priority DESC, timestamp ASC',
    );
    
    for (final map in maps) {
      final message = QueuedMessage.fromMap(map);
      
      // Check if message is expired
      if (_isExpired(message)) {
        await _removeFromDatabase(message.id);
        continue;
      }
      
      _queue.add(message);
    }
  }

  /// Start background queue processor
  void _startProcessor() {
    _processTimer?.cancel();
    
    _processTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _processQueue(),
    );
  }

  /// Process queue (send pending messages)
  Future<void> _processQueue() async {
    if (_queue.isEmpty) return;
    
    final now = DateTime.now();
    final toProcess = <QueuedMessage>[];
    
    // Find messages ready for retry
    for (final message in _queue) {
      if (message.nextRetry == null || now.isAfter(message.nextRetry!)) {
        toProcess.add(message);
      }
    }
    
    // Process by priority
    toProcess.sort((a, b) {
      if (a.priority != b.priority) {
        return a.priority.index.compareTo(b.priority.index);
      }
      return a.timestamp.compareTo(b.timestamp);
    });
    
    for (final message in toProcess) {
      await _processMessage(message);
    }
  }

  /// Process individual message
  Future<void> _processMessage(QueuedMessage message) async {
    try {
      // TODO: Integrate with actual message sending service
      // For now, simulate send attempt
      final success = await _attemptSend(message);
      
      if (success) {
        await _removeFromQueue(message);
      } else {
        await _scheduleRetry(message);
      }
    } catch (e) {
      await _scheduleRetry(message);
    }
  }

  /// Attempt to send message
  Future<bool> _attemptSend(QueuedMessage message) async {
    // TODO: Replace with actual Firebase/network call
    // This is a placeholder
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Simulate success rate (replace with real network check)
    return DateTime.now().second % 2 == 0;
  }

  /// Schedule retry with exponential backoff
  Future<void> _scheduleRetry(QueuedMessage message) async {
    if (message.retryCount >= maxRetries) {
      // Max retries exceeded, remove from queue
      await _removeFromQueue(message);
      // TODO: Notify user of failed message
      return;
    }
    
    // Calculate exponential backoff
    final delaySeconds = baseRetryDelaySeconds * (1 << message.retryCount);
    final nextRetry = DateTime.now().add(Duration(seconds: delaySeconds));
    
    final updatedMessage = QueuedMessage(
      id: message.id,
      chatId: message.chatId,
      content: message.content,
      timestamp: message.timestamp,
      retryCount: message.retryCount + 1,
      nextRetry: nextRetry,
      priority: message.priority,
    );
    
    // Update in database
    if (_database != null) {
      await _database!.update(
        'message_queue',
        updatedMessage.toMap(),
        where: 'id = ?',
        whereArgs: [message.id],
      );
    }
    
    // Update in memory queue
    _queue.remove(message);
    _queue.add(updatedMessage);
  }

  /// Remove message from queue
  Future<void> _removeFromQueue(QueuedMessage message) async {
    _queue.remove(message);
    await _removeFromDatabase(message.id);
  }

  /// Remove message from database
  Future<void> _removeFromDatabase(String id) async {
    if (_database != null) {
      await _database!.delete(
        'message_queue',
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  /// Check if message is expired
  bool _isExpired(QueuedMessage message) {
    final age = DateTime.now().difference(message.timestamp).inDays;
    return age > messageTTLDays;
  }

  /// Get queue size
  int get queueSize => _queue.length;

  /// Get pending messages for chat
  List<QueuedMessage> getPendingMessages(String chatId) {
    return _queue.where((m) => m.chatId == chatId).toList();
  }

  /// Clear all messages (for logout/reset)
  Future<void> clearAll() async {
    _queue.clear();
    if (_database != null) {
      await _database!.delete('message_queue');
    }
  }

  /// Retry all messages immediately
  Future<void> retryAll() async {
    for (final message in _queue.toList()) {
      final updatedMessage = QueuedMessage(
        id: message.id,
        chatId: message.chatId,
        content: message.content,
        timestamp: message.timestamp,
        retryCount: message.retryCount,
        nextRetry: DateTime.now(), // Retry immediately
        priority: message.priority,
      );
      
      _queue.remove(message);
      _queue.add(updatedMessage);
    }
    
    await _processQueue();
  }

  /// Dispose service
  void dispose() {
    _processTimer?.cancel();
    _database?.close();
  }
}
