// ============================================================================
// FILE: lib/services/analytics_engine.dart
// PURPOSE: Analytics and statistical analysis for security events
// ============================================================================

import 'dart:async';
import 'security_audit_log.dart';
import 'dart:math';

/// Time range for analytics
enum TimeRange {
  last24Hours,
  last7Days,
  last30Days,
  allTime,
}

/// Operation statistic
class OperationStat {
  final String operation;
  final int count;
  final double percentage;

  OperationStat({
    required this.operation,
    required this.count,
    required this.percentage,
  });
}

/// Data point for time-series
class DataPoint {
  final DateTime timestamp;
  final double value;

  DataPoint({
    required this.timestamp,
    required this.value,
  });
}

/// Usage prediction
class UsagePrediction {
  final Map<String, double> predictedDaily;
  final double confidence; // 0-1
  final DateTime generatedAt;

  UsagePrediction({
    required this.predictedDaily,
    required this.confidence,
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now();
}

/// Analytics engine service
/// 
/// Provides:
/// - Event statistics and aggregation
/// - Time-series analysis
/// - Trend detection
/// - Usage predictions
class AnalyticsEngine {
  static final AnalyticsEngine _instance = AnalyticsEngine._internal();
  
  factory AnalyticsEngine() => _instance;
  
  AnalyticsEngine._internal();
  
  /// Get statistics for a time range
  Future<Map<String, dynamic>> getStatistics(TimeRange range) async {
    final events = await SecurityAuditLog.getRecentEvents(limit: 10000);
    final cutoff = _getCutoffDate(range);
    
    final filteredEvents = events.where((e) {
      final timestamp = DateTime.tryParse(e['timestamp'] as String? ?? '');
      if (timestamp == null) return false;
      return timestamp.isAfter(cutoff);
    }).toList();
    
    final stats = {
      'timeRange': range.name,
      'totalEvents': filteredEvents.length,
      'eventsByLevel': _groupByLevel(filteredEvents),
      'eventsByType': _groupByType(filteredEvents),
      'topEvents': await getTopOperations(limit: 10, range: range),
      'errorRate': _calculateErrorRate(filteredEvents),
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    return stats;
  }
  
  /// Get most common operations
  Future<List<OperationStat>> getTopOperations({
    int limit = 10,
    TimeRange range = TimeRange.last24Hours,
  }) async {
    final events = await SecurityAuditLog.getRecentEvents(limit: 10000);
    final cutoff = _getCutoffDate(range);
    
    final filteredEvents = events.where((e) {
      final timestamp = DateTime.tryParse(e['timestamp'] as String? ?? '');
      if (timestamp == null) return false;
      return timestamp.isAfter(cutoff);
    }).toList();
    
    final counts = <String, int>{};
    for (final event in filteredEvents) {
      final operation = event['event'] as String? ?? 'unknown';
      counts[operation] = (counts[operation] ?? 0) + 1;
    }
    
    final total = filteredEvents.length;
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(limit).map((e) => OperationStat(
      operation: e.key,
      count: e.value,
      percentage: total > 0 ? (e.value / total * 100) : 0,
    )).toList();
  }
  
  /// Get error rate trend over time
  Future<List<DataPoint>> getErrorTrend({
    TimeRange range = TimeRange.last24Hours,
    int dataPoints = 24,
  }) async {
    final events = await SecurityAuditLog.getRecentEvents(limit: 10000);
    final cutoff = _getCutoffDate(range);
    
    final filteredEvents = events.where((e) {
      final timestamp = DateTime.tryParse(e['timestamp'] as String? ?? '');
      if (timestamp == null) return false;
      return timestamp.isAfter(cutoff);
    }).toList();
    
    // Group events into time buckets
    final bucketSize = DateTime.now().difference(cutoff).inMinutes / dataPoints;
    final buckets = <DateTime, List<Map<String, dynamic>>>{};
    
    for (final event in filteredEvents) {
      final timestamp = DateTime.tryParse(event['timestamp'] as String? ?? '');
      if (timestamp == null) continue;
      
      final bucketTime = DateTime.fromMillisecondsSinceEpoch(
        (timestamp.millisecondsSinceEpoch / (bucketSize * 60000)).floor() * 
        (bucketSize * 60000).toInt(),
      );
      
      buckets[bucketTime] ??= [];
      buckets[bucketTime]!.add(event);
    }
    
    // Calculate error rate for each bucket
    final trend = <DataPoint>[];
    for (final entry in buckets.entries) {
      final total = entry.value.length;
      final errors = entry.value.where((e) => 
        (e['level'] == 'critical' || e['level'] == 'warning') ||
        (e['event'] as String).contains('failed')
      ).length;
      
      final errorRate = total > 0 ? (errors / total * 100) : 0;
      trend.add(DataPoint(
        timestamp: entry.key,
        value: errorRate,
      ));
    }
    
    return trend..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
  
  /// Predict future usage based on historical data
  Future<UsagePrediction> predictUsage() async {
    final events = await SecurityAuditLog.getRecentEvents(limit: 10000);
    
    // Group by day of week
    final dayOfWeekCounts = <int, int>{};
    for (final event in events) {
      final timestamp = DateTime.tryParse(event['timestamp'] as String? ?? '');
      if (timestamp == null) continue;
      
      final dayOfWeek = timestamp.weekday;
      dayOfWeekCounts[dayOfWeek] = (dayOfWeekCounts[dayOfWeek] ?? 0) + 1;
    }
    
    // Calculate average for each day
    final predicted = <String, double>{};
    final daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    for (int i = 1; i <= 7; i++) {
      final count = dayOfWeekCounts[i] ?? 0;
      predicted[daysOfWeek[i - 1]] = count.toDouble();
    }
    
    // Calculate confidence based on data quantity
    final totalDataPoints = events.length;
    final confidence = min(totalDataPoints / 1000, 1.0);
    
    return UsagePrediction(
      predictedDaily: predicted,
      confidence: confidence,
    );
  }
  
  /// Generate comprehensive report
  Future<Map<String, dynamic>> generateReport({
    TimeRange range = TimeRange.last7Days,
  }) async {
    final stats = await getStatistics(range);
    final topOps = await getTopOperations(range: range);
    final errorTrend = await getErrorTrend(range: range);
    final prediction = await predictUsage();
    
    return {
      'generatedAt': DateTime.now().toIso8601String(),
      'timeRange': range.name,
      'overview': stats,
      'topOperations': topOps.map((o) => {
        'operation': o.operation,
        'count': o.count,
        'percentage': o.percentage,
      }).toList(),
      'errorTrend': errorTrend.map((d) => {
        'timestamp': d.timestamp.toIso8601String(),
        'errorRate': d.value,
      }).toList(),
      'prediction': {
        'daily': prediction.predictedDaily,
        'confidence': prediction.confidence,
      },
    };
  }
  
  // Helper methods
  
  DateTime _getCutoffDate(TimeRange range) {
    final now = DateTime.now();
    switch (range) {
      case TimeRange.last24Hours:
        return now.subtract(const Duration(hours: 24));
      case TimeRange.last7Days:
        return now.subtract(const Duration(days: 7));
      case TimeRange.last30Days:
        return now.subtract(const Duration(days: 30));
      case TimeRange.allTime:
        return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }
  
  Map<String, int> _groupByLevel(List<Map<String, dynamic>> events) {
    final grouped = <String, int>{};
    for (final event in events) {
      final level = event['level'] as String? ?? 'unknown';
      grouped[level] = (grouped[level] ?? 0) + 1;
    }
    return grouped;
  }
  
  Map<String, int> _groupByType(List<Map<String, dynamic>> events) {
    final grouped = <String, int>{};
    for (final event in events) {
      final type = event['event'] as String? ?? 'unknown';
      grouped[type] = (grouped[type] ?? 0) + 1;
    }
    return grouped;
  }
  
  double _calculateErrorRate(List<Map<String, dynamic>> events) {
    if (events.isEmpty) return 0;
    
    final errors = events.where((e) => 
      (e['level'] == 'critical' || e['level'] == 'warning') ||
      (e['event'] as String).contains('failed')
    ).length;
    
    return (errors / events.length * 100);
  }
}
