// ============================================================================
// FILE: lib/services/security_audit.dart
// PURPOSE: Security audit and monitoring service
// ============================================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SecurityAuditService {
  static final SecurityAuditService _instance = SecurityAuditService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Connectivity _connectivity = Connectivity();

  factory SecurityAuditService() => _instance;

  SecurityAuditService._internal();

  /// Log security events
  Future<void> logSecurityEvent({
    required String eventType,
    required String userId,
    required String description,
    String? ipAddress,
    String? deviceInfo,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final timestamp = DateTime.now();
      final networkInfo = await _getNetworkInfo();
      final deviceInfoData = await _getDeviceInfo();
      
      final securityEvent = {
        'eventType': eventType,
        'userId': userId,
        'description': description,
        'timestamp': Timestamp.fromDate(timestamp),
        'ipAddress': ipAddress ?? networkInfo['ipAddress'],
        'deviceInfo': deviceInfo ?? deviceInfoData,
        'additionalData': additionalData ?? {},
        'severity': _getSeverityLevel(eventType),
        'location': await _getLocationInfo(),
      };

      await _firestore.collection('security_audit').add(securityEvent);
    } catch (e) {
      // Silent fail for security logging to prevent blocking main operations
      print('Failed to log security event: $e');
    }
  }

  /// Log failed login attempt
  Future<void> logFailedLogin(String email, String reason) async {
    await logSecurityEvent(
      eventType: 'failed_login',
      userId: email,
      description: 'Failed login attempt: $reason',
      additionalData: {'email': email, 'reason': reason},
    );
  }

  /// Log successful login
  Future<void> logSuccessfulLogin(String userId) async {
    await logSecurityEvent(
      eventType: 'successful_login',
      userId: userId,
      description: 'User successfully logged in',
    );
  }

  /// Log suspicious activity
  Future<void> logSuspiciousActivity(String userId, String activity) async {
    await logSecurityEvent(
      eventType: 'suspicious_activity',
      userId: userId,
      description: 'Suspicious activity detected: $activity',
      additionalData: {'activity': activity},
    );
  }

  /// Log rate limiting event
  Future<void> logRateLimitExceeded(String identifier, String action) async {
    await logSecurityEvent(
      eventType: 'rate_limit_exceeded',
      userId: identifier,
      description: 'Rate limit exceeded for action: $action',
      additionalData: {'action': action},
    );
  }

  /// Log data access
  Future<void> logDataAccess(String userId, String dataType, String action) async {
    await logSecurityEvent(
      eventType: 'data_access',
      userId: userId,
      description: '$action performed on $dataType data',
      additionalData: {'dataType': dataType, 'action': action},
    );
  }

  /// Log privilege escalation attempt
  Future<void> logPrivilegeEscalation(String userId, String attemptedAction) async {
    await logSecurityEvent(
      eventType: 'privilege_escalation',
      userId: userId,
      description: 'Privilege escalation attempt: $attemptedAction',
      additionalData: {'attemptedAction': attemptedAction},
      severity: 'high',
    );
  }

  /// Log injection attempt
  Future<void> logInjectionAttempt(String userId, String type, String payload) async {
    await logSecurityEvent(
      eventType: 'injection_attempt',
      userId: userId,
      description: '$type injection attempt detected',
      additionalData: {'type': type, 'payload': payload},
      severity: 'high',
    );
  }

  /// Log brute force attempt
  Future<void> logBruteForceAttempt(String identifier) async {
    await logSecurityEvent(
      eventType: 'brute_force',
      userId: identifier,
      description: 'Brute force attack detected',
      severity: 'high',
    );
  }

  /// Get device information
  Future<Map<String, String>> _getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'model': androidInfo.model ?? '',
          'manufacturer': androidInfo.manufacturer ?? '',
          'version': androidInfo.version.release ?? '',
          'apiLevel': androidInfo.version.sdkInt.toString(),
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'model': iosInfo.model ?? '',
          'systemName': iosInfo.systemName ?? '',
          'systemVersion': iosInfo.systemVersion ?? '',
          'identifierForVendor': iosInfo.identifierForVendor ?? '',
        };
      }
    } catch (e) {
      print('Failed to get device info: $e');
    }
    return {};
  }

  /// Get network information
  Future<Map<String, String>> _getNetworkInfo() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return {
        'connectionType': connectivityResult.toString(),
      };
    } catch (e) {
      print('Failed to get network info: $e');
    }
    return {};
  }

  /// Get location information (approximate)
  Future<Map<String, dynamic>> _getLocationInfo() async {
    try {
      // Note: This is a simplified implementation
      // In production, you might want to use a geolocation service
      return {
        'country': 'Unknown', // Would need geolocation API
        'city': 'Unknown',    // Would need geolocation API
        'coordinates': null,  // Would need geolocation API
      };
    } catch (e) {
      print('Failed to get location info: $e');
    }
    return {};
  }

  /// Determine severity level based on event type
  String _getSeverityLevel(String eventType) {
    switch (eventType) {
      case 'successful_login':
        return 'low';
      case 'failed_login':
        return 'medium';
      case 'rate_limit_exceeded':
        return 'medium';
      case 'data_access':
        return 'low';
      case 'suspicious_activity':
        return 'medium';
      case 'injection_attempt':
      case 'privilege_escalation':
      case 'brute_force':
        return 'high';
      default:
        return 'medium';
    }
  }

  /// Get security statistics for monitoring
  Future<Map<String, dynamic>> getSecurityStats() async {
    try {
      final now = DateTime.now();
      final last24Hours = now.subtract(Duration(hours: 24));
      final last7Days = now.subtract(Duration(days: 7));

      final query24h = _firestore
          .collection('security_audit')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(last24Hours));

      final query7d = _firestore
          .collection('security_audit')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(last7Days));

      final snapshot24h = await query24h.get();
      final snapshot7d = await query7d.get();

      final stats24h = _calculateStats(snapshot24h.docs);
      final stats7d = _calculateStats(snapshot7d.docs);

      return {
        'last24Hours': stats24h,
        'last7Days': stats7d,
        'timestamp': now.toIso8601String(),
      };
    } catch (e) {
      print('Failed to get security stats: $e');
      return {};
    }
  }

  /// Calculate statistics from security events
  Map<String, dynamic> _calculateStats(List<QueryDocumentSnapshot> docs) {
    final stats = <String, int>{};
    final severityCounts = <String, int>{};
    final eventTypes = <String, int>{};

    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final eventType = data['eventType'] as String;
      final severity = data['severity'] as String;

      eventTypes[eventType] = (eventTypes[eventType] ?? 0) + 1;
      severityCounts[severity] = (severityCounts[severity] ?? 0) + 1;
    }

    return {
      'totalEvents': docs.length,
      'eventTypes': eventTypes,
      'severityCounts': severityCounts,
    };
  }

  /// Check for security anomalies
  Future<Map<String, dynamic>> checkSecurityAnomalies() async {
    try {
      final stats = await getSecurityStats();
      final last24h = stats['last24Hours'] as Map<String, dynamic>?;
      final last7d = stats['last7Days'] as Map<String, dynamic>?;

      final anomalies = <String, dynamic>{};

      if (last24h != null && last7d != null) {
        final failedLogins24h = (last24h['eventTypes'] as Map<String, dynamic>)['failed_login'] ?? 0;
        final failedLogins7dAvg = ((last7d['eventTypes'] as Map<String, dynamic>)['failed_login'] ?? 0) / 7;

        if (failedLogins24h > failedLogins7dAvg * 3) {
          anomalies['failedLogins'] = {
            'current': failedLogins24h,
            'average': failedLogins7dAvg,
            'description': 'Failed login attempts significantly higher than average',
          };
        }

        final highSeverity24h = (last24h['severityCounts'] as Map<String, dynamic>)['high'] ?? 0;
        final highSeverity7dAvg = ((last7d['severityCounts'] as Map<String, dynamic>)['high'] ?? 0) / 7;

        if (highSeverity24h > highSeverity7dAvg * 2) {
          anomalies['highSeverityEvents'] = {
            'current': highSeverity24h,
            'average': highSeverity7dAvg,
            'description': 'High severity security events significantly higher than average',
          };
        }
      }

      return {
        'anomaliesDetected': anomalies.isNotEmpty,
        'anomalies': anomalies,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Failed to check security anomalies: $e');
      return {'error': e.toString()};
    }
  }

  /// Generate security report
  Future<Map<String, dynamic>> generateSecurityReport() async {
    try {
      final stats = await getSecurityStats();
      final anomalies = await checkSecurityAnomalies();

      return {
        'reportType': 'security_audit',
        'generatedAt': DateTime.now().toIso8601String(),
        'securityStats': stats,
        'anomalies': anomalies,
        'recommendations': _generateRecommendations(stats, anomalies),
      };
    } catch (e) {
      print('Failed to generate security report: $e');
      return {'error': e.toString()};
    }
  }

  /// Generate security recommendations based on stats and anomalies
  List<String> _generateRecommendations(Map<String, dynamic> stats, Map<String, dynamic> anomalies) {
    final recommendations = <String>[];

    final last24h = stats['last24Hours'] as Map<String, dynamic>?;
    if (last24h != null) {
      final failedLogins = (last24h['eventTypes'] as Map<String, dynamic>)['failed_login'] ?? 0;
      final injectionAttempts = (last24h['eventTypes'] as Map<String, dynamic>)['injection_attempt'] ?? 0;
      final bruteForce = (last24h['eventTypes'] as Map<String, dynamic>)['brute_force'] ?? 0;

      if (failedLogins > 10) {
        recommendations.add('Consider implementing CAPTCHA for login attempts');
        recommendations.add('Review and strengthen password policies');
      }

      if (injectionAttempts > 0) {
        recommendations.add('Review input validation and sanitization');
        recommendations.add('Consider implementing WAF (Web Application Firewall) rules');
      }

      if (bruteForce > 0) {
        recommendations.add('Implement stricter rate limiting for authentication');
        recommendations.add('Consider IP blocking for repeated brute force attempts');
      }

      if (anomalies['anomaliesDetected'] == true) {
        recommendations.add('Investigate detected security anomalies immediately');
        recommendations.add('Review security logs for potential breaches');
      }
    }

    if (recommendations.isEmpty) {
      recommendations.add('No immediate security concerns detected');
      recommendations.add('Continue monitoring security events regularly');
    }

    return recommendations;
  }
}