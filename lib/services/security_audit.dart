// ============================================================================
// FILE: lib/services/security_audit.dart
// PURPOSE: Security audit and monitoring service (cross-platform)
// ============================================================================

import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SecurityAuditService {
  static final SecurityAuditService _instance = SecurityAuditService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Connectivity _connectivity = Connectivity();

  factory SecurityAuditService() => _instance;
  SecurityAuditService._internal();

  /// Log a security event to Firestore
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

      await _firestore.collection('security_audit').add({
        'eventType': eventType,
        'userId': userId,
        'description': description,
        'timestamp': Timestamp.fromDate(timestamp),
        'ipAddress': ipAddress ?? networkInfo['connectionType'],
        'deviceInfo': deviceInfo ?? deviceInfoData,
        'additionalData': additionalData ?? {},
        'severity': _getSeverityLevel(eventType),
        'platform': kIsWeb ? 'web' : 'mobile',
      });
    } catch (e) {
      if (kDebugMode) print('Security audit log failed: $e');
    }
  }

  Future<void> logFailedLogin(String email, String reason) async {
    await logSecurityEvent(
      eventType: 'failed_login',
      userId: email,
      description: 'Failed login attempt: $reason',
      additionalData: {'email': email, 'reason': reason},
    );
  }

  Future<void> logSuccessfulLogin(String userId) async {
    await logSecurityEvent(
      eventType: 'successful_login',
      userId: userId,
      description: 'User successfully logged in',
    );
  }

  Future<void> logSuspiciousActivity(String userId, String activity) async {
    await logSecurityEvent(
      eventType: 'suspicious_activity',
      userId: userId,
      description: 'Suspicious activity: $activity',
      additionalData: {'activity': activity},
    );
  }

  Future<void> logRateLimitExceeded(String identifier, String action) async {
    await logSecurityEvent(
      eventType: 'rate_limit_exceeded',
      userId: identifier,
      description: 'Rate limit exceeded: $action',
      additionalData: {'action': action},
    );
  }

  Future<void> logDataAccess(String userId, String dataType, String action) async {
    await logSecurityEvent(
      eventType: 'data_access',
      userId: userId,
      description: '$action on $dataType',
      additionalData: {'dataType': dataType, 'action': action},
    );
  }

  Future<String> _getDeviceInfo() async {
    return kIsWeb ? 'Web Browser' : 'Mobile Device';
  }

  Future<Map<String, String>> _getNetworkInfo() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return {'connectionType': result.toString()};
    } catch (_) {
      return {'connectionType': 'unknown'};
    }
  }

  String _getSeverityLevel(String eventType) {
    switch (eventType) {
      case 'successful_login':
        return 'low';
      case 'failed_login':
      case 'rate_limit_exceeded':
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
}
