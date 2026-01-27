// ============================================================================
// FILE: lib/services/production_monitoring.dart
// PURPOSE: Production monitoring and alerting service for 200k+ users
// ============================================================================

import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../core/constants/app_constants.dart';
import '../core/errors/error_handler.dart';

class ProductionMonitoring {
  static final ProductionMonitoring _instance = ProductionMonitoring._internal();
  final Map<String, PerformanceTracker> _trackers = {};
  final Map<String, AlertRule> _alertRules = {};
  final StreamController<AlertEvent> _alertController = StreamController.broadcast();
  final StreamController<HealthStatus> _healthController = StreamController.broadcast();
  
  // Monitoring configuration
  static const MONITORING_INTERVAL = Duration(seconds: 30);
  static const ALERT_COOLDOWN = Duration(minutes: 5);
  static const HEALTH_CHECK_INTERVAL = Duration(seconds: 10);
  
  Timer? _monitoringTimer;
  Timer? _healthCheckTimer;
  DateTime? _lastAlertTime;
  HealthStatus _currentHealth = HealthStatus.healthy;

  factory ProductionMonitoring() => _instance;

  ProductionMonitoring._internal() {
    _initializeMonitoring();
    _setupAlertRules();
  }

  void _initializeMonitoring() {
    _monitoringTimer = Timer.periodic(MONITORING_INTERVAL, (_) => _performMonitoring());
    _healthCheckTimer = Timer.periodic(HEALTH_CHECK_INTERVAL, (_) => _performHealthCheck());
  }

  void _setupAlertRules() {
    _alertRules['slow_operation'] = AlertRule(
      name: 'Slow Operation',
      threshold: 1000, // 1 second
      severity: AlertSeverity.warning,
      cooldown: ALERT_COOLDOWN,
    );
    
    _alertRules['high_error_rate'] = AlertRule(
      name: 'High Error Rate',
      threshold: 5.0, // 5%
      severity: AlertSeverity.critical,
      cooldown: ALERT_COOLDOWN,
    );
    
    _alertRules['memory_usage'] = AlertRule(
      name: 'High Memory Usage',
      threshold: 80.0, // 80%
      severity: AlertSeverity.warning,
      cooldown: ALERT_COOLDOWN,
    );
  }

  /// Track operation performance with automatic alerting
  Future<T> trackOperation<T>(String operationName, Future<T> Function() operation) async {
    final tracker = _trackers.putIfAbsent(operationName, () => PerformanceTracker());
    final stopwatch = Stopwatch()..start();
    bool success = false;

    try {
      final result = await operation();
      success = true;
      tracker.recordSuccess(stopwatch.elapsedMilliseconds);
      return result;
    } catch (e, stackTrace) {
      tracker.recordFailure(stopwatch.elapsedMilliseconds);
      await ErrorHandler.logError(e, stackTrace, context: 'ProductionMonitoring.trackOperation');
      rethrow;
    } finally {
      stopwatch.stop();
      final duration = stopwatch.elapsedMilliseconds;
      
      // Check for slow operation alerts
      final slowRule = _alertRules['slow_operation'];
      if (slowRule != null && duration > slowRule.threshold && _shouldAlert(slowRule)) {
        await _triggerAlert(AlertEvent(
          type: AlertType.slow_operation,
          message: 'Operation $operationName took ${duration}ms (threshold: ${slowRule.threshold}ms)',
          severity: slowRule.severity,
          metadata: {'operation': operationName, 'duration': duration},
        ));
      }
    }
  }

  /// Track API calls with detailed metrics
  Future<T> trackAPICall<T>(String endpoint, Future<T> Function() apiCall) async {
    final tracker = _trackers.putIfAbsent('api_$endpoint', () => PerformanceTracker());
    final stopwatch = Stopwatch()..start();

    try {
      final result = await apiCall();
      tracker.recordSuccess(stopwatch.elapsedMilliseconds);
      return result;
    } catch (e) {
      tracker.recordFailure(stopwatch.elapsedMilliseconds);
      throw e;
    } finally {
      stopwatch.stop();
      _logAPIMetrics(endpoint, stopwatch.elapsedMilliseconds);
    }
  }

  /// Track database operations
  Future<T> trackDatabaseOperation<T>(String operation, Future<T> Function() dbCall) async {
    final tracker = _trackers.putIfAbsent('db_$operation', () => PerformanceTracker());
    final stopwatch = Stopwatch()..start();

    try {
      final result = await dbCall();
      tracker.recordSuccess(stopwatch.elapsedMilliseconds);
      return result;
    } catch (e) {
      tracker.recordFailure(stopwatch.elapsedMilliseconds);
      throw e;
    } finally {
      stopwatch.stop();
      _checkDatabasePerformance(operation, stopwatch.elapsedMilliseconds);
    }
  }

  /// Perform comprehensive monitoring
  void _performMonitoring() {
    // Check error rates
    _checkErrorRates();
    
    // Check memory usage
    _checkMemoryUsage();
    
    // Check network connectivity
    _checkNetworkStatus();
    
    // Log performance metrics
    _logPerformanceMetrics();
  }

  /// Check error rates across all operations
  void _checkErrorRates() {
    for (final entry in _trackers.entries) {
      final tracker = entry.value;
      final errorRate = tracker.errorRate;
      
      final errorRule = _alertRules['high_error_rate'];
      if (errorRule != null && errorRate > errorRule.threshold && _shouldAlert(errorRule)) {
        _triggerAlert(AlertEvent(
          type: AlertType.high_error_rate,
          message: 'Error rate for ${entry.key} is ${errorRate.toStringAsFixed(2)}% (threshold: ${errorRule.threshold}%)',
          severity: errorRule.severity,
          metadata: {'operation': entry.key, 'error_rate': errorRate},
        ));
      }
    }
  }

  /// Check memory usage
  void _checkMemoryUsage() {
    if (kDebugMode) return; // Skip in debug mode
    
    try {
      final memoryInfo = developer.MemoryInfo();
      final memoryUsage = memoryInfo.rss / (1024 * 1024); // MB
      final memoryPercentage = (memoryUsage / 512.0) * 100; // Assuming 512MB limit
      
      final memoryRule = _alertRules['memory_usage'];
      if (memoryRule != null && memoryPercentage > memoryRule.threshold && _shouldAlert(memoryRule)) {
        _triggerAlert(AlertEvent(
          type: AlertType.high_memory_usage,
          message: 'Memory usage is ${memoryUsage.toStringAsFixed(2)}MB (${memoryPercentage.toStringAsFixed(2)}%)',
          severity: memoryRule.severity,
          metadata: {'memory_mb': memoryUsage, 'memory_percentage': memoryPercentage},
        ));
      }
    } catch (e) {
      // Ignore memory monitoring errors
    }
  }

  /// Check network status
  void _checkNetworkStatus() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;
      
      if (!isOnline && _currentHealth != HealthStatus.degraded) {
        _currentHealth = HealthStatus.degraded;
        _healthController.add(_currentHealth);
      } else if (isOnline && _currentHealth == HealthStatus.degraded) {
        _currentHealth = HealthStatus.healthy;
        _healthController.add(_currentHealth);
      }
    } catch (e) {
      // Ignore network check errors
    }
  }

  /// Perform health checks
  void _performHealthCheck() async {
    final healthStatus = await _runHealthChecks();
    if (healthStatus != _currentHealth) {
      _currentHealth = healthStatus;
      _healthController.add(_currentHealth);
    }
  }

  Future<HealthStatus> _runHealthChecks() async {
    try {
      // Check database connectivity
      final dbHealthy = await _checkDatabaseHealth();
      
      // Check cache connectivity
      final cacheHealthy = await _checkCacheHealth();
      
      // Check external services
      final servicesHealthy = await _checkExternalServices();
      
      if (dbHealthy && cacheHealthy && servicesHealthy) {
        return HealthStatus.healthy;
      } else if (dbHealthy || cacheHealthy) {
        return HealthStatus.degraded;
      } else {
        return HealthStatus.critical;
      }
    } catch (e) {
      return HealthStatus.critical;
    }
  }

  Future<bool> _checkDatabaseHealth() async {
    try {
      // Simple database ping
      // This would be implemented based on your database choice
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _checkCacheHealth() async {
    try {
      // Simple cache ping
      // This would be implemented based on your cache choice
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _checkExternalServices() async {
    try {
      // Check Firebase services
      // This would be implemented based on your external services
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check database performance and alert on slow queries
  void _checkDatabasePerformance(String operation, int duration) {
    if (duration > 500) { // 500ms threshold for database operations
      _triggerAlert(AlertEvent(
        type: AlertType.slow_database_query,
        message: 'Database operation $operation took ${duration}ms',
        severity: AlertSeverity.warning,
        metadata: {'operation': operation, 'duration': duration},
      ));
    }
  }

  /// Log API metrics for analysis
  void _logAPIMetrics(String endpoint, int duration) {
    developer.log(
      'API Metrics: $endpoint - ${duration}ms',
      name: 'production_monitoring',
      level: developer.LogLevel.FINE,
    );
  }

  /// Log performance metrics
  void _logPerformanceMetrics() {
    final metrics = <String, dynamic>{};
    
    for (final entry in _trackers.entries) {
      final tracker = entry.value;
      metrics[entry.key] = {
        'avg_response_time': tracker.averageResponseTime,
        'p95_response_time': tracker.p95ResponseTime,
        'error_rate': tracker.errorRate,
        'total_requests': tracker.totalRequests,
      };
    }
    
    developer.log(
      'Performance Metrics: ${jsonEncode(metrics)}',
      name: 'production_monitoring',
      level: developer.LogLevel.INFO,
    );
  }

  /// Check if alert should be triggered (respects cooldown)
  bool _shouldAlert(AlertRule rule) {
    if (_lastAlertTime == null) return true;
    
    final timeSinceLastAlert = DateTime.now().difference(_lastAlertTime!);
    return timeSinceLastAlert >= rule.cooldown;
  }

  /// Trigger alert with proper logging and notification
  Future<void> _triggerAlert(AlertEvent alert) async {
    _lastAlertTime = DateTime.now();
    _alertController.add(alert);
    
    // Log to Firebase Crashlytics
    await FirebaseCrashlytics.instance.recordError(
      alert.message,
      null,
      reason: 'Production Alert: ${alert.type}',
      fatal: alert.severity == AlertSeverity.critical,
    );
    
    // Log to console in development
    if (kDebugMode) {
      print('🚨 ALERT [${alert.severity}]: ${alert.message}');
    }
  }

  /// Get performance statistics for all tracked operations
  Map<String, PerformanceStats> getPerformanceStats() {
    final stats = <String, PerformanceStats>{};
    for (final entry in _trackers.entries) {
      stats[entry.key] = entry.value.getStats();
    }
    return stats;
  }

  /// Get current health status
  HealthStatus get currentHealth => _currentHealth;

  /// Stream of alerts
  Stream<AlertEvent> get onAlert => _alertController.stream;

  /// Stream of health status changes
  Stream<HealthStatus> get onHealthChange => _healthController.stream;

  /// Dispose resources
  void dispose() {
    _monitoringTimer?.cancel();
    _healthCheckTimer?.cancel();
    _alertController.close();
    _healthController.close();
    _trackers.clear();
  }
}

class PerformanceTracker {
  final List<int> _successTimes = [];
  final List<int> _failureTimes = [];
  int _totalRequests = 0;

  void recordSuccess(int duration) {
    _successTimes.add(duration);
    _totalRequests++;
    _cleanupOldEntries();
  }

  void recordFailure(int duration) {
    _failureTimes.add(duration);
    _totalRequests++;
    _cleanupOldEntries();
  }

  void _cleanupOldEntries() {
    // Keep only last 1000 entries for performance
    if (_successTimes.length > 1000) {
      _successTimes.removeRange(0, 500);
    }
    if (_failureTimes.length > 1000) {
      _failureTimes.removeRange(0, 500);
    }
  }

  double get averageResponseTime {
    if (_successTimes.isEmpty) return 0;
    return _successTimes.reduce((a, b) => a + b) / _successTimes.length;
  }

  double get p95ResponseTime {
    if (_successTimes.length < 100) return averageResponseTime;
    
    final sorted = List.from(_successTimes)..sort();
    final index = (sorted.length * 0.95).floor();
    return sorted[index].toDouble();
  }

  double get errorRate {
    if (_totalRequests == 0) return 0;
    return (_failureTimes.length / _totalRequests) * 100;
  }

  int get totalRequests => _totalRequests;

  PerformanceStats getStats() {
    return PerformanceStats(
      averageResponseTime: averageResponseTime,
      p95ResponseTime: p95ResponseTime,
      errorRate: errorRate,
      totalRequests: totalRequests,
    );
  }
}

class PerformanceStats {
  final double averageResponseTime;
  final double p95ResponseTime;
  final double errorRate;
  final int totalRequests;

  PerformanceStats({
    required this.averageResponseTime,
    required this.p95ResponseTime,
    required this.errorRate,
    required this.totalRequests,
  });
}

class AlertRule {
  final String name;
  final double threshold;
  final AlertSeverity severity;
  final Duration cooldown;

  AlertRule({
    required this.name,
    required this.threshold,
    required this.severity,
    required this.cooldown,
  });
}

class AlertEvent {
  final AlertType type;
  final String message;
  final AlertSeverity severity;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;

  AlertEvent({
    required this.type,
    required this.message,
    required this.severity,
    required this.metadata,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

enum AlertType {
  slow_operation,
  high_error_rate,
  slow_database_query,
  high_memory_usage,
  service_down,
}

enum AlertSeverity {
  info,
  warning,
  critical,
}

enum HealthStatus {
  healthy,
  degraded,
  critical,
}