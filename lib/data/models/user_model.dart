// ============================================================================
// FILE: lib/data/models/user_model.dart
// PURPOSE: User data model with subscription tier and settings
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';

enum UserTier { free, plus, pro }

class UserModel {
  final String uid;
  final String email;
  final String username;
  final String? phone;
  final UserTier tier;
  final DateTime createdAt;
  final DateTime lastSeen;
  final UserSettings settings;
  final UserLimits limits;
  final String? profileImageUrl;
  
  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    this.phone,
    required this.tier,
    required this.createdAt,
    required this.lastSeen,
    required this.settings,
    required this.limits,
    this.profileImageUrl,
  });
  
  /// Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      phone: data['phone'],
      tier: UserTier.values.firstWhere(
        (e) => e.name == data['tier'],
        orElse: () => UserTier.free,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastSeen: (data['lastSeen'] as Timestamp).toDate(),
      settings: UserSettings.fromMap(data['settings'] ?? {}),
      limits: UserLimits.fromMap(data['limits'] ?? {}),
      profileImageUrl: data['profileImageUrl'],
    );
  }
  
  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'username': username,
      'phone': phone,
      'tier': tier.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastSeen': Timestamp.fromDate(lastSeen),
      'settings': settings.toMap(),
      'limits': limits.toMap(),
      'profileImageUrl': profileImageUrl,
    };
  }
  
  /// Create a copy with updated fields
  UserModel copyWith({
    String? email,
    String? username,
    String? phone,
    UserTier? tier,
    DateTime? createdAt,
    DateTime? lastSeen,
    UserSettings? settings,
    UserLimits? limits,
    String? profileImageUrl,
  }) {
    return UserModel(
      uid: uid,
      email: email ?? this.email,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      tier: tier ?? this.tier,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
      settings: settings ?? this.settings,
      limits: limits ?? this.limits,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}

class UserSettings {
  final String theme; // 'light', 'dark', 'custom'
  final double fontSize;
  final int retentionDays;
  final bool showOnline;
  final bool allowContactsSync;
  final bool notificationsEnabled;
  final String selectedWallpaper;
  
  UserSettings({
    this.theme = 'light',
    this.fontSize = 14.0,
    this.retentionDays = 7,
    this.showOnline = true,
    this.allowContactsSync = false,
    this.notificationsEnabled = true,
    this.selectedWallpaper = 'default',
  });
  
  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      theme: map['theme'] ?? 'light',
      fontSize: (map['fontSize'] ?? 14.0).toDouble(),
      retentionDays: map['retentionDays'] ?? 7,
      showOnline: map['showOnline'] ?? true,
      allowContactsSync: map['allowContactsSync'] ?? false,
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      selectedWallpaper: map['selectedWallpaper'] ?? 'default',
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'theme': theme,
      'fontSize': fontSize,
      'retentionDays': retentionDays,
      'showOnline': showOnline,
      'allowContactsSync': allowContactsSync,
      'notificationsEnabled': notificationsEnabled,
      'selectedWallpaper': selectedWallpaper,
    };
  }
  
  UserSettings copyWith({
    String? theme,
    double? fontSize,
    int? retentionDays,
    bool? showOnline,
    bool? allowContactsSync,
    bool? notificationsEnabled,
    String? selectedWallpaper,
  }) {
    return UserSettings(
      theme: theme ?? this.theme,
      fontSize: fontSize ?? this.fontSize,
      retentionDays: retentionDays ?? this.retentionDays,
      showOnline: showOnline ?? this.showOnline,
      allowContactsSync: allowContactsSync ?? this.allowContactsSync,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      selectedWallpaper: selectedWallpaper ?? this.selectedWallpaper,
    );
  }
}

class UserLimits {
  final int anonymousThisWeek;
  final int messagesToday;
  final int groupsCreated;
  final DateTime lastAnonymousReset;
  final DateTime lastMessageReset;
  
  UserLimits({
    this.anonymousThisWeek = 0,
    this.messagesToday = 0,
    this.groupsCreated = 0,
    DateTime? lastAnonymousReset,
    DateTime? lastMessageReset,
  })  : lastAnonymousReset = lastAnonymousReset ?? DateTime.now(),
        lastMessageReset = lastMessageReset ?? DateTime.now();
  
  factory UserLimits.fromMap(Map<String, dynamic> map) {
    return UserLimits(
      anonymousThisWeek: map['anonymousThisWeek'] ?? 0,
      messagesToday: map['messagesToday'] ?? 0,
      groupsCreated: map['groupsCreated'] ?? 0,
      lastAnonymousReset: map['lastAnonymousReset'] != null
          ? (map['lastAnonymousReset'] as Timestamp).toDate()
          : DateTime.now(),
      lastMessageReset: map['lastMessageReset'] != null
          ? (map['lastMessageReset'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'anonymousThisWeek': anonymousThisWeek,
      'messagesToday': messagesToday,
      'groupsCreated': groupsCreated,
      'lastAnonymousReset': Timestamp.fromDate(lastAnonymousReset),
      'lastMessageReset': Timestamp.fromDate(lastMessageReset),
    };
  }
}
