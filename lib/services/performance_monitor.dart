// ============================================================================
// FILE: lib/services/performance_monitor.dart
// PURPOSE: Performance monitoring and metrics collection
// ============================================================================

import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  final FirebasePerformance _performance = FirebasePerformance.instance;
  final Map<String, StopWatchTimer> _timers = {};
  final Map<String, num> _metrics = {};

  factory PerformanceMonitor() => _instance;

  PerformanceMonitor._internal();

  /// Start timing a specific operation
  void startTimer(String operationName) {
    if (_timers.containsKey(operationName)) {
      _timers[operationName]!.onResetTimer();
      _timers[operationName]!.onStartTimer();
    } else {
      final timer = StopWatchTimer(mode: StopWatchMode.countUp);
      _timers[operationName] = timer;
      timer.onStartTimer();
    }
  }

  /// Stop timing and record the duration
  Future<void> stopTimer(String operationName) async {
    final timer = _timers[operationName];
    if (timer != null) {
      timer.onStopTimer();
      await Future.delayed(const Duration(milliseconds: 100)); // Allow timer to stop
      
      final duration = timer.rawTime.value;
      await recordTiming(operationName, duration);
      
      timer.onResetTimer();
      _timers.remove(operationName);
    }
  }

  /// Record a timing metric
  Future<void> recordTiming(String name, int durationMs) async {
    try {
      final trace = _performance.newTrace(name);
      await trace.start();
      await Future.delayed(Duration(milliseconds: durationMs));
      await trace.stop();
    } catch (e) {
      debugPrint('Failed to record timing metric: $e');
    }
  }

  /// Record a custom metric
  void recordMetric(String name, num value) {
    _metrics[name] = value;
    debugPrint('Performance Metric - $name: $value');
  }

  /// Record app launch time
  Future<void> recordAppLaunchTime(int durationMs) async {
    await recordTiming('app_launch', durationMs);
    recordMetric('app_launch_time_ms', durationMs);
  }

  /// Record screen transition time
  Future<void> recordScreenTransition(String screenName, int durationMs) async {
    await recordTiming('screen_transition_$screenName', durationMs);
    recordMetric('screen_transition_time_$screenName', durationMs);
  }

  /// Record API call performance
  Future<void> recordApiCall(String endpoint, int durationMs, bool success) async {
    await recordTiming('api_call_$endpoint', durationMs);
    recordMetric('api_call_duration_$endpoint', durationMs);
    recordMetric('api_call_success_$endpoint', success ? 1 : 0);
  }

  /// Record database operation performance
  Future<void> recordDatabaseOperation(String operation, int durationMs) async {
    await recordTiming('db_operation_$operation', durationMs);
    recordMetric('db_operation_duration_$operation', durationMs);
  }

  /// Record message delivery metrics
  Future<void> recordMessageDelivery(int messageSize, int deliveryTimeMs, bool success) async {
    await recordTiming('message_delivery', deliveryTimeMs);
    recordMetric('message_delivery_time_ms', deliveryTimeMs);
    recordMetric('message_size_bytes', messageSize);
    recordMetric('message_delivery_success', success ? 1 : 0);
  }

  /// Record memory usage
  void recordMemoryUsage() {
    final memoryUsage = _getMemoryUsage();
    recordMetric('memory_usage_mb', memoryUsage);
  }

  /// Record frame rendering performance
  void recordFrameRenderTime(int frameTimeMs) {
    recordMetric('frame_render_time_ms', frameTimeMs);
  }

  /// Record user interaction response time
  Future<void> recordUserInteraction(String interactionType, int responseTimeMs) async {
    await recordTiming('user_interaction_$interactionType', responseTimeMs);
    recordMetric('user_interaction_response_time_$interactionType', responseTimeMs);
  }

  /// Get current performance metrics
  Map<String, num> getMetrics() {
    return Map.from(_metrics);
  }

  /// Reset all metrics
  void resetMetrics() {
    _metrics.clear();
  }

  /// Log performance summary
  void logPerformanceSummary() {
    debugPrint('=== Performance Summary ===');
    _metrics.forEach((key, value) {
      debugPrint('$key: $value');
    });
    debugPrint('=== End Summary ===');
  }

  /// Get memory usage (approximate)
  num _getMemoryUsage() {
    // This is a simplified implementation
    // In a real app, you might use platform-specific APIs or plugins
    // to get actual memory usage
    return 50.0; // Placeholder value in MB
  }

  /// Monitor app startup performance
  static Future<void> monitorAppStartup() async {
    final monitor = PerformanceMonitor();
    final startTime = DateTime.now();
    
    // This would typically be called from main.dart after app initialization
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime).inMilliseconds;
    
    await monitor.recordAppLaunchTime(duration);
    monitor.recordMemoryUsage();
  }

  /// Monitor chat performance
  void monitorChatPerformance({
    required int messageCount,
    required int avgMessageSize,
    required int deliveryTime,
  }) {
    recordMetric('chat_message_count', messageCount);
    recordMetric('chat_avg_message_size', avgMessageSize);
    recordMetric('chat_delivery_time', deliveryTime);
  }

  /// Monitor authentication performance
  void monitorAuthPerformance(int authTimeMs, bool success) {
    recordMetric('auth_time_ms', authTimeMs);
    recordMetric('auth_success', success ? 1 : 0);
  }

  /// Monitor database query performance
  void monitorQueryPerformance(String queryType, int queryTimeMs, int resultCount) {
    recordMetric('query_time_$queryType', queryTimeMs);
    recordMetric('query_results_$queryType', resultCount);
  }

  /// Check if app is performing well based on thresholds
  bool isPerformingWell() {
    final metrics = getMetrics();
    
    // Check app launch time (should be under 3 seconds)
    final launchTime = metrics['app_launch_time_ms'] ?? 0;
    if (launchTime > 3000) return false;

    // Check average frame render time (should be under 16ms for 60fps)
    final frameTime = metrics['frame_render_time_ms'] ?? 1000;
    if (frameTime > 16) return false;

    // Check average API call time (should be under 2 seconds)
    final apiTime = metrics['api_call_duration'] ?? 0;
    if (apiTime > 2000) return false;

    return true;
  }
}