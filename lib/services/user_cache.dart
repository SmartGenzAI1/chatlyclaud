// ============================================================================
// FILE: lib/services/user_cache.dart
// PURPOSE: Singleton in-memory cache for UID → UserModel lookups.
//          Eliminates redundant Firestore reads when rendering chat lists.
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/user_model.dart';

class UserCache {
  UserCache._();
  static final UserCache instance = UserCache._();

  final _cache = <String, UserModel?>{};
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Returns cached or freshly-fetched [UserModel] for the given [uid].
  /// Returns null if the user doesn't exist or a network error occurs.
  Future<UserModel?> getUser(String uid) async {
    if (_cache.containsKey(uid)) return _cache[uid];
    try {
      final doc = await _db.collection('users').doc(uid).get();
      final user = doc.exists ? UserModel.fromFirestore(doc) : null;
      _cache[uid] = user;
      return user;
    } catch (_) {
      return null;
    }
  }

  /// Resolve a display name (username) for [uid], falling back to a
  /// truncated UID so the UI never shows null.
  Future<String> getUsername(String uid) async {
    final user = await getUser(uid);
    return user?.username ?? uid.substring(0, uid.length.clamp(0, 8)).toLowerCase();
  }

  /// Pre-warm cache with a list of [uids]. Call once when chat list loads.
  Future<void> prefetch(List<String> uids) async {
    final missing = uids.where((id) => !_cache.containsKey(id)).toList();
    if (missing.isEmpty) return;

    // Batch into groups of 10 (Firestore 'in' limit)
    for (var i = 0; i < missing.length; i += 10) {
      final batch = missing.sublist(i, (i + 10).clamp(0, missing.length));
      try {
        final snap = await _db
            .collection('users')
            .where(FieldPath.documentId, whereIn: batch)
            .get();
        for (final doc in snap.docs) {
          _cache[doc.id] = UserModel.fromFirestore(doc);
        }
        // Mark not-found UIDs so we don't retry
        for (final uid in batch) {
          _cache.putIfAbsent(uid, () => null);
        }
      } catch (_) {}
    }
  }

  void invalidate(String uid) => _cache.remove(uid);
  void clear() => _cache.clear();
}
