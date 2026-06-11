// ============================================================================
// FILE: lib/services/security_audit_log.dart
// PURPOSE: Security audit logging for tracking security events
// ============================================================================

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum SecurityLevel { info, warning, critical }

class SecurityAuditLog {
  static final SecurityAuditLog _instance = SecurityAuditLog._internal();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _logKey = 'security_audit_log';
  static const int _maxLogEntries = 500;
  final List<Map<String, dynamic>> _buffer = [];

  factory SecurityAuditLog() => _instance;
  SecurityAuditLog._internal();

  /// Log a security event
  static Future<void> logEvent({
    required String event,
    required String details,
    required SecurityLevel level,
  }) async {
    final entry = {
      'event': event,
      'details': details,
      'level': level.name,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    _instance._buffer.add(entry);
    
    if (_instance._buffer.length >= 50) {
      await _instance._flush();
    }
    
    if (kDebugMode && level == SecurityLevel.critical) {
      debugPrint('SECURITY CRITICAL: $event - $details');
    }
  }

  /// Get recent security events
  static Future<List<Map<String, dynamic>>> getRecentEvents({int limit = 50}) async {
    try {
      final raw = await _instance._secureStorage.read(key: _logKey);
      if (raw == null) return [];
      
      final events = List<Map<String, dynamic>>.from(
        (raw.split('|||').map((e) {
          try {
            return Map<String, dynamic>.from(
              e.split('|').fold<Map<String, dynamic>>({}, (map, pair) {
                final parts = pair.split(':');
                if (parts.length == 2) map[parts[0]] = parts[1];
                return map;
              }),
            );
          } catch (_) {
            return <String, dynamic>{};
          }
        }))
      );
      
      return events.take(limit).toList();
    } catch (e) {
      if (kDebugMode) debugPrint('SecurityAuditLog: failed to read log: $e');
      return [];
    }
  }

  /// Clear the audit log
  static Future<void> clear() async {
    try {
      await _instance._secureStorage.delete(key: _logKey);
      _instance._buffer.clear();
    } catch (e) {
      if (kDebugMode) debugPrint('SecurityAuditLog: failed to clear: $e');
    }
  }

  Future<void> _flush() async {
    try {
      final existing = await _secureStorage.read(key: _logKey) ?? '';
      final allEntries = [..._buffer, ..._formatExisting(existing)];
      final trimmed = allEntries.take(_maxLogEntries).toList();
      
      final serialized = trimmed.map((e) => 
        e.entries.map((kv) => '${kv.key}:${kv.value}').join('|')
      ).join('|||');
      
      await _secureStorage.write(key: _logKey, value: serialized);
      _buffer.clear();
    } catch (e) {
      if (kDebugMode) debugPrint('SecurityAuditLog: flush failed: $e');
    }
  }

  List<Map<String, dynamic>> _formatExisting(String existing) {
    if (existing.isEmpty) return [];
    try {
      return existing.split('|||').map((e) {
        final map = <String, dynamic>{};
        for (final pair in e.split('|')) {
          final parts = pair.split(':');
          if (parts.length == 2) map[parts[0]] = parts[1];
        }
        return map;
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
