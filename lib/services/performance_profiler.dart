// ============================================================================
// FILE: lib/services/performance_profiler.dart
// PURPOSE: Performance profiling and benchmarking for security operations
// ============================================================================

import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

/// Performance metric for a single operation
class PerformanceMetric {
  final String operation;
  final Duration duration;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  PerformanceMetric({
    required this.operation,
    required this.duration,
    DateTime? timestamp,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();
  
  Map<String, dynamic> toMap() {
    return {
      'operation': operation,
      'durationMs': duration.inMilliseconds,
      'timestamp': timestamp.toIso8601String(),
      if (metadata != null) 'metadata': metadata,
    };
  }
}

/// Performance statistics
class PerformanceStats {
  final String operation;
  final int count;
  final Duration avgDuration;
  final Duration minDuration;
  final Duration maxDuration;
  final double p95Duration; // 95th percentile

  PerformanceStats({
    required this.operation,
    required this.count,
    required this.avgDuration,
    required this.minDuration,
    required this.maxDuration,
    required this.p95Duration,
  });
}

/// Performance profiler service
/// 
/// Tracks performance metrics for:
/// - Encryption/decryption operations
/// - Key generation
/// - Storage operations
/// - Custom operations
class PerformanceProfiler {
  static final PerformanceProfiler _instance = PerformanceProfiler._internal();
  
  factory PerformanceProfiler() => _instance;
  
  PerformanceProfiler._internal();
  
  // Storage
  final _storage = const FlutterSecureStorage();
  static const String _metricsKey = 'performance_metrics';
  static const int _maxMetrics = 1000; // Keep last 1000 metrics
  
  // Active timers
  final Map<String, DateTime> _activeTimers = {};
  
  // Performance targets (ms)
  static const Map<String, int> _targets = {
    'encrypt': 15,
    'decrypt': 10,
    'key_generation': 500,
    'storage_write': 50,
    'storage_read': 30,
  };
  
  bool _isEnabled = false;
  
  /// Enable profiling
  Future<void> enable() async {
    _isEnabled = true;
  }
  
  /// Disable profiling
  Future<void> disable() async {
    _isEnabled = false;
  }
  
  /// Start timing an operation
  void startOperation(String operation) {
    if (!_isEnabled) return;
    _activeTimers[operation] = DateTime.now();
  }
  
  /// End timing and record metric
  Future<Duration?> endOperation(String operation, {
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isEnabled) return null;
    
    final startTime = _activeTimers.remove(operation);
    if (startTime == null) return null;
    
    final duration = DateTime.now().difference(startTime);
    final metric = PerformanceMetric(
      operation: operation,
      duration: duration,
      metadata: metadata,
    );
    
    await _recordMetric(metric);
    
    // Check if performance degraded
    final target = _targets[operation];
    if (target != null && duration.inMilliseconds > target) {
      _handlePerformanceDegradation(operation, duration, target);
    }
    
    return duration;
  }
  
  /// Time an async function
  Future<T> timeAsync<T>(
    String operation,
    Future<T> Function() function, {
    Map<String, dynamic>? metadata,
  }) async {
    if (!_isEnabled) return await function();
    
    startOperation(operation);
    try {
      final result = await function();
      await endOperation(operation, metadata: metadata);
      return result;
    } catch (e) {
      await endOperation(operation, metadata: {
        ...?metadata,
        'error': e.toString(),
      });
      rethrow;
    }
  }
  
  /// Time a synchronous function
  T timeSync<T>(
    String operation,
    T Function() function, {
    Map<String, dynamic>? metadata,
  }) {
    if (!_isEnabled) return function();
    
    startOperation(operation);
    try {
      final result = function();
      endOperation(operation, metadata: metadata);
      return result;
    } catch (e) {
      endOperation(operation, metadata: {
        ...?metadata,
        'error': e.toString(),
      });
      rethrow;
    }
  }
  
  /// Record performance metric
  Future<void> _recordMetric(PerformanceMetric metric) async {
    try {
      final existing = await _storage.read(key: _metricsKey);
      List<Map<String, dynamic>> metrics = [];
      
      if (existing != null) {
        final decoded = jsonDecode(existing) as List<dynamic>;
        metrics = decoded.map((e) => e as Map<String, dynamic>).toList();
      }
      
      metrics.add(metric.toMap());
      
      // Keep only last N metrics
      if (metrics.length > _maxMetrics) {
        metrics = metrics.sublist(metrics.length - _maxMetrics);
      }
      
      await _storage.write(key: _metricsKey, value: jsonEncode(metrics));
    } catch (e) {
      print('Failed to record metric: $e');
    }
  }
  
  /// Get statistics for an operation
  Future<PerformanceStats?> getStats(String operation) async {
    final metrics = await _getMetrics();
    final operationMetrics = metrics.where((m) => 
      m['operation'] == operation
    ).toList();
    
    if (operationMetrics.isEmpty) return null;
    
    final durations = operationMetrics
        .map((m) => m['durationMs'] as int)
        .toList()
      ..sort();
    
    final avg = durations.reduce((a, b) => a + b) / durations.length;
    final p95Index = (durations.length * 0.95).floor();
    
    return PerformanceStats(
      operation: operation,
      count: durations.length,
      avgDuration: Duration(milliseconds: avg.round()),
      minDuration: Duration(milliseconds: durations.first),
      maxDuration: Duration(milliseconds: durations.last),
      p95Duration: durations[p95Index].toDouble(),
    );
  }
  
  /// Get all metrics
  Future<List<Map<String, dynamic>>> _getMetrics() async {
    try {
      final existing = await _storage.read(key: _metricsKey);
      if (existing == null) return [];
      
      final decoded = jsonDecode(existing) as List<dynamic>;
      return decoded.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      return [];
    }
  }
  
  /// Get summary of all operations
  Future<Map<String, PerformanceStats>> getAllStats() async {
    final metrics = await _getMetrics();
    final operations = metrics.map((m) => m['operation'] as String).toSet();
    
    final stats = <String, PerformanceStats>{};
    for (final operation in operations) {
      final opStats = await getStats(operation);
      if (opStats != null) {
        stats[operation] = opStats;
      }
    }
    
    return stats;
  }
  
  /// Handle performance degradation
  void _handlePerformanceDegradation(
    String operation,
    Duration actual,
    int target,
  ) {
    final degradation = ((actual.inMilliseconds - target) / target * 100).round();
    print(
      'Performance degradation detected: $operation took ${actual.inMilliseconds}ms '
      '(target: ${target}ms, ${degradation}% slower)',
    );
  }
  
  /// Clear all metrics
  Future<void> clearMetrics() async {
    await _storage.delete(key: _metricsKey);
  }
  
  /// Get performance report
  Future<Map<String, dynamic>> getReport() async {
    final allStats = await getAllStats();
    final report = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'operations': {},
    };
    
    for (final entry in allStats.entries) {
      final stats = entry.value;
      report['operations'][entry.key] = {
        'count': stats.count,
        'avgMs': stats.avgDuration.inMilliseconds,
        'minMs': stats.minDuration.inMilliseconds,
        'maxMs': stats.maxDuration.inMilliseconds,
        'p95Ms': stats.p95Duration,
        'target': _targets[entry.key],
        'meetingTarget': _targets[entry.key] != null 
            ? stats.avgDuration.inMilliseconds <= _targets[entry.key]!
            : true,
      };
    }
    
    return report;
  }
}
