// ============================================================================
// FILE: lib/core/services/production_cache.dart
// PURPOSE: In-memory cache with TTL, size limits, and LRU eviction
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:crypto/crypto.dart';

class ProductionCache {
  static final ProductionCache _instance = ProductionCache._internal();
  final Map<String, CacheEntry> _cache = {};
  final Map<String, DateTime> _accessTimes = {};
  
  static const int _maxEntries = 1000;
  static const Duration _defaultTTL = Duration(minutes: 30);
  Timer? _cleanupTimer;

  factory ProductionCache() => _instance;
  ProductionCache._internal() {
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (_) => _cleanup());
  }

  /// Get value by key, returning null if expired or missing
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    if (_isExpired(entry)) {
      _cache.remove(key);
      _accessTimes.remove(key);
      return null;
    }
    _accessTimes[key] = DateTime.now();
    return entry.value as T?;
  }

  /// Set a value with optional TTL
  void set(String key, dynamic value, {Duration? ttl}) {
    _evictIfNeeded();
    _cache[key] = CacheEntry(
      value: value,
      createdAt: DateTime.now(),
      ttl: ttl ?? _defaultTTL,
    );
    _accessTimes[key] = DateTime.now();
  }

  /// Check if key exists and is not expired
  bool has(String key) {
    final entry = _cache[key];
    if (entry == null) return false;
    if (_isExpired(entry)) {
      _cache.remove(key);
      _accessTimes.remove(key);
      return false;
    }
    return true;
  }

  /// Remove a key
  void remove(String key) {
    _cache.remove(key);
    _accessTimes.remove(key);
  }

  /// Clear all
  void clear() {
    _cache.clear();
    _accessTimes.clear();
  }

  /// Generate a cache key from inputs (deterministic)
  static String hashKey(String input) {
    return sha256.convert(utf8.encode(input)).toString().substring(0, 16);
  }

  bool _isExpired(CacheEntry entry) {
    return DateTime.now().difference(entry.createdAt) > entry.ttl;
  }

  void _evictIfNeeded() {
    if (_cache.length < _maxEntries) return;
    
    // LRU eviction: remove oldest accessed
    final sorted = _accessTimes.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    
    final toRemove = (_cache.length - _maxEntries + 50).clamp(1, sorted.length);
    for (var i = 0; i < toRemove; i++) {
      _cache.remove(sorted[i].key);
      _accessTimes.remove(sorted[i].key);
    }
  }

  void _cleanup() {
    final expired = _cache.keys.where((k) {
      final e = _cache[k];
      return e != null && _isExpired(e);
    }).toList();
    
    for (final k in expired) {
      _cache.remove(k);
      _accessTimes.remove(k);
    }
    
    if (kDebugMode && expired.isNotEmpty) {
      debugPrint('ProductionCache: cleaned ${expired.length} expired entries');
    }
  }

  void dispose() {
    _cleanupTimer?.cancel();
    _cache.clear();
    _accessTimes.clear();
  }
}

class CacheEntry {
  final dynamic value;
  final DateTime createdAt;
  final Duration ttl;
  
  CacheEntry({required this.value, required this.createdAt, required this.ttl});
}
