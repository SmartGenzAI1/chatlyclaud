// ============================================================================
// FILE: lib/services/security_audit_log.dart
// PURPOSE: Security audit logging for tracking security events
// ============================================================================

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Security event severity levels
enum SecurityLevel {
  info,
  warning,
  critical,
}

/// Security audit logging service
/// 
/// Tracks security-related events for:
/// - Debugging security issues
/// - Detecting attacks
/// - Compliance requirements
/// - Incident response
class SecurityAuditLog {
  static final SecurityAuditLog _instance = SecurityAuditLog._internal();
  
  late final FlutterSecureStorage _storage;
  static const String _logKey = 'security_audit_log';
  static const int _maxLogEntries = 1000;
  
  factory SecurityAuditLog() => _instance;
  
  SecurityAuditLog._internal() {
    _storage = const FlutterSecureStorage();
  }
  
  /// Log a security event
  static Future<void> logEvent({
    required String event,
    required String details,
    SecurityLevel level = SecurityLevel.info,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final entry = {
        'timestamp': DateTime.now().toIso8601String(),
        'event': event,
        'details': details,
        'level': level.name,
        if (metadata != null) 'metadata': metadata,
      };
      
      await _instance._appendToLog(entry);
      
      // Alert on critical events
      if (level == SecurityLevel.critical) {
        await _instance._handleCriticalEvent(entry);
      }
    } catch (e) {
      // Never throw from logging - fail silently
      print('Failed to log security event: $e');
    }
  }
  
  /// Append entry to secure log
  Future<void> _appendToLog(Map<String, dynamic> entry) async {
    try {
      final existingLog = await _storage.read(key: _logKey);
      List<Map<String, dynamic>> logs = [];
      
      if (existingLog != null) {
        final decoded = jsonDecode(existingLog) as List<dynamic>;
        logs = decoded.map((e) => e as Map<String, dynamic>).toList();
      }
      
      logs.add(entry);
      
      // Trim old entries to prevent unbounded growth
      if (logs.length > _maxLogEntries) {
        logs = logs.sublist(logs.length - _maxLogEntries);
      }
      
      await _storage.write(key: _logKey, value: jsonEncode(logs));
    } catch (e) {
      print('Failed to append to log: $e');
    }
  }
  
  /// Handle critical security events
  Future<void> _handleCriticalEvent(Map<String, dynamic> entry) async {
    // TODO: Implement alerting mechanism
    // - Send push notification
    // - Log to remote server
    // - Trigger security protocol
    print('CRITICAL SECURITY EVENT: ${entry['event']}');
  }
  
  /// Get recent security events
  static Future<List<Map<String, dynamic>>> getRecentEvents({
    int limit = 50,
    SecurityLevel? filterLevel,
  }) async {
    try {
      final existingLog = await _instance._storage.read(key: _logKey);
      if (existingLog == null) return [];
      
      final decoded = jsonDecode(existingLog) as List<dynamic>;
      var logs = decoded.map((e) => e as Map<String, dynamic>).toList();
      
      // Filter by level if specified
      if (filterLevel != null) {
        logs = logs.where((log) => log['level'] == filterLevel.name).toList();
      }
      
      // Return most recent entries
      return logs.reversed.take(limit).toList();
    } catch (e) {
      return [];
    }
  }
  
  /// Clear audit log (admin only)
  static Future<void> clearLog() async {
    try {
      await _instance._storage.delete(key: _logKey);
      
      await logEvent(
        event: 'audit_log_cleared',
        details: 'Security audit log was cleared',
        level: SecurityLevel.warning,
      );
    } catch (e) {
      print('Failed to clear log: $e');
    }
  }
  
  /// Get log statistics
  static Future<Map<String, int>> getLogStats() async {
    try {
      final events = await getRecentEvents(limit: _maxLogEntries);
      
      final stats = {
        'total': events.length,
        'info': 0,
        'warning': 0,
        'critical': 0,
      };
      
      for (final event in events) {
        final level = event['level'] as String;
        stats[level] = (stats[level] ?? 0) + 1;
      }
      
      return stats;
    } catch (e) {
      return {'total': 0, 'info': 0, 'warning': 0, 'critical': 0};
    }
  }
}
