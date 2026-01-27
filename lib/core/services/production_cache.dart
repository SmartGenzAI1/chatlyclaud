// ============================================================================
// FILE: lib/core/services/production_cache.dart
// PURPOSE: Production-ready cache with size limits, compression, and eviction
// ============================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:gzip/gzip.dart';

class ProductionCache {
  static final ProductionCache _instance = ProductionCache._internal();
  final Map<String, CacheEntry> _memoryCache = {};
  final Map<String, DateTime> _accessTimes = {};
  final Map<String, Completer<CacheEntry>> _pendingLoads = {};
  
  // Configuration
  static const MAX_MEMORY_ENTRIES = 5000;
  static const MAX_MEMORY_SIZE_MB = 50;
  static const MAX_DISK_SIZE_MB = 200;
  static const CLEANUP_INTERVAL = Duration(minutes: 5);
  static const COMPRESSION_THRESHOLD = 1024 * 50; // 50KB
  
  // Cleanup timer
  Timer? _cleanupTimer;

  factory ProductionCache() => _instance;

  ProductionCache._internal() {
    _startCleanupTimer();
  }

  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(CLEANUP_INTERVAL, (_) => _performCleanup());
  }

  /// Get cached data with automatic loading and fallback
  Future<T?> get<T>(String key, {Future<T?> Function()? loader}) async {
    // Check memory cache first
    if (_memoryCache.containsKey(key)) {
      final entry = _memoryCache[key]!;
      if (!entry.isExpired) {
        _updateAccessTime(key);
        return _deserializeData<T>(entry);
      } else {
        _memoryCache.remove(key);
      }
    }

    // Check pending loads
    if (_pendingLoads.containsKey(key)) {
      try {
        final entry = await _pendingLoads[key]!.future;
        return _deserializeData<T>(entry);
      } catch (e) {
        _pendingLoads.remove(key);
        return null;
      }
    }

    // Load from disk cache
    final diskData = await _loadFromDisk(key);
    if (diskData != null && !diskData.isExpired) {
      _memoryCache[key] = diskData;
      _updateAccessTime(key);
      return _deserializeData<T>(diskData);
    }

    // Load from source if loader provided
    if (loader != null) {
      return await _loadAndCache(key, loader);
    }

    return null;
  }

  /// Load and cache data with proper error handling
  Future<T?> _loadAndCache<T>(String key, Future<T?> Function() loader) async {
    // Check if already loading
    if (_pendingLoads.containsKey(key)) {
      try {
        final entry = await _pendingLoads[key]!.future;
        return _deserializeData<T>(entry);
      } catch (e) {
        _pendingLoads.remove(key);
        return null;
      }
    }

    // Start loading
    final completer = Completer<CacheEntry>();
    _pendingLoads[key] = completer;

    try {
      final data = await loader();
      if (data != null) {
        final entry = await _createCacheEntry(key, data);
        _memoryCache[key] = entry;
        _updateAccessTime(key);
        _pendingLoads.remove(key);
        completer.complete(entry);
        return data;
      } else {
        _pendingLoads.remove(key);
        completer.completeError(Exception('Loader returned null'));
        return null;
      }
    } catch (e) {
      _pendingLoads.remove(key);
      completer.completeError(e);
      await ErrorHandler.logError(e, null, context: 'ProductionCache._loadAndCache');
      return null;
    }
  }

  /// Set cached data with size management
  Future<void> set<T>(String key, T data, {Duration? ttl}) async {
    try {
      final entry = await _createCacheEntry(key, data, ttl: ttl);
      _memoryCache[key] = entry;
      _updateAccessTime(key);
      
      // Save to disk
      await _saveToDisk(key, entry);
      
      // Enforce size limits
      await _enforceSizeLimits();
    } catch (e) {
      await ErrorHandler.logError(e, null, context: 'ProductionCache.set');
    }
  }

  /// Create cache entry with compression if needed
  Future<CacheEntry> _createCacheEntry<T>(String key, T data, {Duration? ttl}) async {
    final serialized = _serializeData(data);
    final sizeInBytes = serialized.length;
    final isCompressed = sizeInBytes > COMPRESSION_THRESHOLD;
    final compressedData = isCompressed ? gzip.encode(Uint8List.fromList(serialized.codeUnits)) : null;
    final dataToStore = isCompressed ? base64Encode(compressedData!) : serialized;
    
    return CacheEntry(
      key: key,
      data: dataToStore,
      sizeInBytes: isCompressed ? compressedData!.length : sizeInBytes,
      isCompressed: isCompressed,
      expiryTime: ttl != null ? DateTime.now().add(ttl) : null,
      createdAt: DateTime.now(),
      accessCount: 0,
    );
  }

  /// Serialize data based on type
  String _serializeData<T>(T data) {
    if (data is String) {
      return data;
    } else if (data is Map || data is List) {
      return jsonEncode(data);
    } else {
      return data.toString();
    }
  }

  /// Deserialize data based on type and compression
  T _deserializeData<T>(CacheEntry entry) {
    try {
      final rawData = entry.isCompressed 
          ? String.fromCharCodes(gzip.decode(base64Decode(entry.data)))
          : entry.data;
      
      if (T == String) {
        return rawData as T;
      } else if (T == Map || T == List) {
        return jsonDecode(rawData) as T;
      } else {
        return rawData as T;
      }
    } catch (e) {
      throw Exception('Failed to deserialize cache entry: $e');
    }
  }

  /// Update access time and count
  void _updateAccessTime(String key) {
    _accessTimes[key] = DateTime.now();
    if (_memoryCache.containsKey(key)) {
      _memoryCache[key]!.accessCount++;
    }
  }

  /// Enforce size limits with LRU eviction
  Future<void> _enforceSizeLimits() async {
    // Check memory limits
    if (_memoryCache.length > MAX_MEMORY_ENTRIES) {
      await _evictLRUEntries(count: _memoryCache.length - MAX_MEMORY_ENTRIES + 100);
    }

    final memorySizeMB = _getCurrentMemorySize();
    if (memorySizeMB > MAX_MEMORY_SIZE_MB) {
      await _evictBySize(targetSizeMB: MAX_MEMORY_SIZE_MB * 0.8);
    }
  }

  /// Evict least recently used entries
  Future<void> _evictLRUEntries({int count = 100}) async {
    final sortedEntries = _accessTimes.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final toRemove = sortedEntries.take(count).map((e) => e.key).toList();
    for (final key in toRemove) {
      _memoryCache.remove(key);
      _accessTimes.remove(key);
      await _removeFromDisk(key);
    }
  }

  /// Evict entries by size
  Future<void> _evictBySize({double targetSizeMB = 40.0}) async {
    final currentSize = _getCurrentMemorySize();
    if (currentSize <= targetSizeMB) return;

    // Sort by size and access count (prioritize small, infrequently accessed)
    final entries = _memoryCache.values.toList()
      ..sort((a, b) {
        final sizeDiff = a.sizeInBytes.compareTo(b.sizeInBytes);
        if (sizeDiff != 0) return sizeDiff;
        return a.accessCount.compareTo(b.accessCount);
      });

    var removedSize = 0;
    for (final entry in entries) {
      if (_getCurrentMemorySize() - removedSize <= targetSizeMB) break;
      
      _memoryCache.remove(entry.key);
      _accessTimes.remove(entry.key);
      await _removeFromDisk(entry.key);
      removedSize += entry.sizeInBytes;
    }
  }

  /// Get current memory cache size in MB
  double _getCurrentMemorySize() {
    final totalBytes = _memoryCache.values.fold(0, (sum, entry) => sum + entry.sizeInBytes);
    return totalBytes / (1024 * 1024);
  }

  /// Perform cleanup operations
  Future<void> _performCleanup() async {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    // Find expired entries
    for (final entry in _memoryCache.values) {
      if (entry.isExpired) {
        expiredKeys.add(entry.key);
      }
    }

    // Remove expired entries
    for (final key in expiredKeys) {
      _memoryCache.remove(key);
      _accessTimes.remove(key);
      await _removeFromDisk(key);
    }

    // Enforce size limits
    await _enforceSizeLimits();
  }

  /// Disk cache operations
  Future<void> _saveToDisk(String key, CacheEntry entry) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode({
        'key': entry.key,
        'data': entry.data,
        'sizeInBytes': entry.sizeInBytes,
        'isCompressed': entry.isCompressed,
        'expiryTime': entry.expiryTime?.toIso8601String(),
        'createdAt': entry.createdAt.toIso8601String(),
        'accessCount': entry.accessCount,
      });
      await prefs.setString('cache_$key', data);
    } catch (e) {
      // Disk save failed, but memory cache is still valid
    }
  }

  Future<CacheEntry?> _loadFromDisk(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('cache_$key');
      if (data == null) return null;

      final json = jsonDecode(data) as Map<String, dynamic>;
      return CacheEntry(
        key: json['key'],
        data: json['data'],
        sizeInBytes: json['sizeInBytes'],
        isCompressed: json['isCompressed'],
        expiryTime: json['expiryTime'] != null ? DateTime.parse(json['expiryTime']) : null,
        createdAt: DateTime.parse(json['createdAt']),
        accessCount: json['accessCount'],
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _removeFromDisk(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cache_$key');
    } catch (e) {
      // Ignore disk removal errors
    }
  }

  /// Clear all cache
  Future<void> clear() async {
    _memoryCache.clear();
    _accessTimes.clear();
    _pendingLoads.clear();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('cache_')).toList();
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      await ErrorHandler.logError(e, null, context: 'ProductionCache.clear');
    }
  }

  /// Get cache statistics
  CacheStats getStats() {
    final totalSize = _getCurrentMemorySize();
    final totalEntries = _memoryCache.length;
    final avgAccessCount = _memoryCache.values.fold(0, (sum, entry) => sum + entry.accessCount) / (totalEntries > 0 ? totalEntries : 1);
    
    return CacheStats(
      totalEntries: totalEntries,
      totalSizeMB: totalSize,
      avgAccessCount: avgAccessCount,
      memoryHitRate: _calculateHitRate(),
    );
  }

  double _calculateHitRate() {
    // Simple hit rate calculation based on access patterns
    final totalAccesses = _accessTimes.values.length;
    if (totalAccesses == 0) return 0.0;
    
    final recentAccesses = _accessTimes.values.where((time) => 
      DateTime.now().difference(time).inMinutes < 10).length;
    
    return recentAccesses / totalAccesses;
  }

  /// Dispose resources
  void dispose() {
    _cleanupTimer?.cancel();
    _memoryCache.clear();
    _accessTimes.clear();
    _pendingLoads.clear();
  }
}

class CacheEntry {
  final String key;
  final String data;
  final int sizeInBytes;
  final bool isCompressed;
  final DateTime? expiryTime;
  final DateTime createdAt;
  int accessCount;

  CacheEntry({
    required this.key,
    required this.data,
    required this.sizeInBytes,
    required this.isCompressed,
    this.expiryTime,
    required this.createdAt,
    required this.accessCount,
  });

  bool get isExpired => expiryTime != null && DateTime.now().isAfter(expiryTime!);
}

class CacheStats {
  final int totalEntries;
  final double totalSizeMB;
  final double avgAccessCount;
  final double memoryHitRate;

  CacheStats({
    required this.totalEntries,
    required this.totalSizeMB,
    required this.avgAccessCount,
    required this.memoryHitRate,
  });
}

enum NetworkStatus {
  connected,
  disconnected,
  unknown,
}