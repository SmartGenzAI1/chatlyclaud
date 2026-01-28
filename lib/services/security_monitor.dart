// ============================================================================
// FILE: lib/services/security_monitor.dart
// PURPOSE: Advanced security monitoring with anomaly detection and threat scoring
// ============================================================================

import 'dart:async';
import 'security_audit_log.dart';

/// Security anomaly types
enum AnomalyType {
  repeatedFailures,
  rateLimitViolations,
  unusualTiming,
  suspiciousPatterns,
  keyIntegrityIssues,
}

/// Anomaly severity
enum Severity {
  low,
  medium,
  high,
  critical,
}

/// Security anomaly model
class SecurityAnomaly {
  final AnomalyType type;
  final Severity severity;
  final String description;
  final DateTime detectedAt;
  final Map<String, dynamic>? metadata;

  SecurityAnomaly({
    required this.type,
    required this.severity,
    required this.description,
    DateTime? detectedAt,
    this.metadata,
  }) : detectedAt = detectedAt ?? DateTime.now();
}

/// Security health status
class SecurityHealth {
  final int threatScore; // 0-100
  final List<SecurityAnomaly> anomalies;
  final Map<String, int> eventCounts;
  final DateTime timestamp;

  SecurityHealth({
    required this.threatScore,
    required this.anomalies,
    required this.eventCounts,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
  
  String get status {
    if (threatScore >= 70) return 'CRITICAL';
    if (threatScore >= 40) return 'WARNING';
    if (threatScore >= 20) return 'CAUTION';
    return 'HEALTHY';
  }
}

/// Security monitoring service
/// 
/// Provides:
/// - Real-time anomaly detection
/// - Threat scoring
/// - Security health monitoring
/// - Alert system
class SecurityMonitor {
  static final SecurityMonitor _instance = SecurityMonitor._internal();
  
  factory SecurityMonitor() => _instance;
  
  SecurityMonitor._internal();
  
  // Alert handlers
  final List<Function(SecurityAnomaly)> _alertHandlers = [];
  
  // Monitoring state
  bool _isMonitoring = false;
  Timer? _monitoringTimer;
  
  /// Initialize monitoring
  Future<void> initialize() async {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    
    // Start periodic monitoring (every 60 seconds)
    _monitoringTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _performMonitoringCheck(),
    );
    
    await SecurityAuditLog.logEvent(
      event: 'security_monitor_initialized',
      details: 'Security monitoring started',
      level: SecurityLevel.info,
    );
  }
  
  /// Stop monitoring
  Future<void> dispose() async {
    _isMonitoring = false;
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    
    await SecurityAuditLog.logEvent(
      event: 'security_monitor_stopped',
      details: 'Security monitoring stopped',
      level: SecurityLevel.info,
    );
  }
  
  /// Perform periodic monitoring check
  Future<void> _performMonitoringCheck() async {
    final anomalies = await detectAnomalies();
    
    // Trigger alerts for new anomalies
    for (final anomaly in anomalies) {
      if (anomaly.severity == Severity.high || 
          anomaly.severity == Severity.critical) {
        _triggerAlert(anomaly);
      }
    }
  }
  
  /// Detect security anomalies
  Future<List<SecurityAnomaly>> detectAnomalies({
    Duration timeWindow = const Duration(minutes: 5),
  }) async {
    final anomalies = <SecurityAnomaly>[];
    final events = await SecurityAuditLog.getRecentEvents(limit: 1000);
    final now = DateTime.now();
    
    // Filter to recent events in time window
    final recentEvents = events.where((e) {
      final timestamp = DateTime.tryParse(e['timestamp'] as String? ?? '');
      if (timestamp == null) return false;
      return now.difference(timestamp) <= timeWindow;
    }).toList();
    
    // Pattern 1: Repeated decryption failures
    final decryptionFailures = recentEvents.where((e) => 
      e['event'] == 'decryption_failed'
    ).length;
    
    if (decryptionFailures >= 3) {
      anomalies.add(SecurityAnomaly(
        type: AnomalyType.repeatedFailures,
        severity: decryptionFailures >= 10 ? Severity.critical : Severity.high,
        description: '$decryptionFailures decryption failures in ${timeWindow.inMinutes} minutes',
        metadata: {'count': decryptionFailures},
      ));
    }
    
    // Pattern 2: Rate limit violations
    final rateLimitViolations = recentEvents.where((e) => 
      e['event'] == 'rate_limit_exceeded'
    ).length;
    
    if (rateLimitViolations >= 2) {
      anomalies.add(SecurityAnomaly(
        type: AnomalyType.rateLimitViolations,
        severity: Severity.medium,
        description: '$rateLimitViolations rate limit violations detected',
        metadata: {'count': rateLimitViolations},
      ));
    }
    
    // Pattern 3: Key integrity failures
    final keyIntegrityFailures = recentEvents.where((e) => 
      e['event'] == 'key_integrity_check_failed'
    ).length;
    
    if (keyIntegrityFailures > 0) {
      anomalies.add(SecurityAnomaly(
        type: AnomalyType.keyIntegrityIssues,
        severity: Severity.critical,
        description: 'Key integrity check failed',
        metadata: {'count': keyIntegrityFailures},
      ));
    }
    
    // Pattern 4: Unusual activity timing (late night/early morning)
    final unusualTimingEvents = recentEvents.where((e) {
      final timestamp = DateTime.tryParse(e['timestamp'] as String? ?? '');
      if (timestamp == null) return false;
      final hour = timestamp.hour;
      // Consider 2 AM - 5 AM as unusual
      return hour >= 2 && hour < 5;
    }).length;
    
    if (unusualTimingEvents >= 5) {
      anomalies.add(SecurityAnomaly(
        type: AnomalyType.unusualTiming,
        severity: Severity.low,
        description: '$unusualTimingEvents activities during unusual hours (2-5 AM)',
        metadata: {'count': unusualTimingEvents},
      ));
    }
    
    // Pattern 5: Suspicious encryption/decryption patterns
    final encryptionEvents = recentEvents.where((e) => 
      e['event'] == 'message_encrypted'
    ).length;
    final decryptionEvents = recentEvents.where((e) => 
      e['event'] == 'message_decrypted'
    ).length;
    
    // Unusual ratio (e.g., 10x more encryption than decryption)
    if (encryptionEvents > 0 && decryptionEvents > 0) {
      final ratio = encryptionEvents / decryptionEvents;
      if (ratio > 10 || ratio < 0.1) {
        anomalies.add(SecurityAnomaly(
          type: AnomalyType.suspiciousPatterns,
          severity: Severity.medium,
          description: 'Unusual encryption/decryption ratio: ${ratio.toStringAsFixed(1)}',
          metadata: {
            'encrypted': encryptionEvents,
            'decrypted': decryptionEvents,
            'ratio': ratio,
          },
        ));
      }
    }
    
    return anomalies;
  }
  
  /// Calculate threat score (0-100)
  Future<int> calculateThreatScore() async {
    int score = 0;
    
    // Get recent critical events (last hour)
    final criticalEvents = await SecurityAuditLog.getRecentEvents(
      filterLevel: SecurityLevel.critical,
      limit: 50,
    );
    
    final recentCritical = criticalEvents.where((e) {
      final timestamp = DateTime.tryParse(e['timestamp'] as String? ?? '');
      if (timestamp == null) return false;
      return DateTime.now().difference(timestamp).inHours < 1;
    }).length;
    
    // Critical events: +25 points each (capped at 50)
    score += (recentCritical * 25).clamp(0, 50);
    
    // Anomalies detected
    final anomalies = await detectAnomalies();
    
    for (final anomaly in anomalies) {
      switch (anomaly.severity) {
        case Severity.critical:
          score += 30;
          break;
        case Severity.high:
          score += 20;
          break;
        case Severity.medium:
          score += 10;
          break;
        case Severity.low:
          score += 5;
          break;
      }
    }
    
    // Get warning events (last hour)
    final warningEvents = await SecurityAuditLog.getRecentEvents(
      filterLevel: SecurityLevel.warning,
      limit: 100,
    );
    
    final recentWarnings = warningEvents.where((e) {
      final timestamp = DateTime.tryParse(e['timestamp'] as String? ?? '');
      if (timestamp == null) return false;
      return DateTime.now().difference(timestamp).inHours < 1;
    }).length;
    
    // Warning events: +2 points each (capped at 20)
    score += (recentWarnings * 2).clamp(0, 20);
    
    // Clamp final score to 0-100
    return score.clamp(0, 100);
  }
  
  /// Get security health status
  Future<SecurityHealth> getHealthStatus() async {
    final threatScore = await calculateThreatScore();
    final anomalies = await detectAnomalies();
    
    // Get event counts by type
    final allEvents = await SecurityAuditLog.getRecentEvents(limit: 1000);
    final eventCounts = <String, int>{};
    
    for (final event in allEvents) {
      final eventName = event['event'] as String? ?? 'unknown';
      eventCounts[eventName] = (eventCounts[eventName] ?? 0) + 1;
    }
    
    return SecurityHealth(
      threatScore: threatScore,
      anomalies: anomalies,
      eventCounts: eventCounts,
    );
  }
  
  /// Register alert handler
  void registerAlertHandler(Function(SecurityAnomaly) handler) {
    _alertHandlers.add(handler);
  }
  
  /// Unregister alert handler
  void unregisterAlertHandler(Function(SecurityAnomaly) handler) {
    _alertHandlers.remove(handler);
  }
  
  /// Trigger alert for anomaly
  void _triggerAlert(SecurityAnomaly anomaly) async {
    // Log the alert
    await SecurityAuditLog.logEvent(
      event: 'security_alert_triggered',
      details: anomaly.description,
      level: anomaly.severity == Severity.critical 
          ? SecurityLevel.critical 
          : SecurityLevel.warning,
      metadata: {
        'type': anomaly.type.name,
        'severity': anomaly.severity.name,
        ...?anomaly.metadata,
      },
    );
    
    // Call registered handlers
    for (final handler in _alertHandlers) {
      try {
        handler(anomaly);
      } catch (e) {
        // Don't let handler errors break monitoring
        print('Alert handler error: $e');
      }
    }
  }
  
  /// Get statistics for dashboard
  Future<Map<String, dynamic>> getStatistics() async {
    final health = await getHealthStatus();
    final stats = await SecurityAuditLog.getLogStats();
    
    return {
      'threatScore': health.threatScore,
      'status': health.status,
      'anomalyCount': health.anomalies.length,
      'criticalAnomalies': health.anomalies
          .where((a) => a.severity == Severity.critical)
          .length,
      'totalEvents': stats['total'],
      'criticalEvents': stats['critical'],
      'warningEvents': stats['warning'],
      'infoEvents': stats['info'],
      'timestamp': health.timestamp.toIso8601String(),
    };
  }
}
