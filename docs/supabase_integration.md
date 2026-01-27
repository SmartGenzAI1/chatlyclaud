# Supabase Integration Guide

This guide explains how to use Supabase as an optional storage and database service for Chatly, providing a cost-effective alternative to Firebase.

## 🎯 Overview

Supabase integration is **completely optional** and designed to work alongside Firebase or as an alternative. This allows you to:

- **Reduce costs** - Use free Supabase tiers instead of paid Firebase services
- **Avoid billing** - No credit card required for basic usage
- **Maintain functionality** - App works perfectly without Supabase
- **Scale gradually** - Enable Supabase features as needed

## 🚀 Quick Setup

### 1. Create Supabase Project

1. Go to [Supabase](https://supabase.com/)
2. Sign up for free account (no credit card required)
3. Create new project:
   - Name: `chatly-app`
   - Region: Choose closest to your users
   - Database password: Set a secure password

### 2. Configure Environment

Add to your `.env` file:
```bash
# Supabase Configuration (Optional)
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_KEY=your-anon-public-key
```

### 3. Enable Supabase Features

In your app initialization:
```dart
// Enable Supabase storage only
SupabaseService.configure(enableStorage: true);

// Enable Supabase database only  
SupabaseService.configure(enableDatabase: true);

// Enable both
SupabaseService.configure(
  enableStorage: true,
  enableDatabase: true,
);

// Disable completely (default)
SupabaseService.configure();
```

## 💰 Cost Comparison

| Service | Firebase Free Tier | Supabase Free Tier | Notes |
|---------|-------------------|-------------------|--------|
| **Storage** | 1GB/month | 1GB/month | Both free |
| **Database** | 1GB storage | 500MB storage | Supabase more generous |
| **Bandwidth** | 10GB/month | 2GB/month | Firebase better |
| **Functions** | 2M invocations | N/A | Supabase uses Edge Functions |
| **Authentication** | 10K MAU | 50K MAU | Supabase better |

**Winner: Supabase** for most use cases, especially with lower traffic

## 🔧 Database Setup

### Required Tables

Create these tables in Supabase SQL Editor:

```sql
-- Chats table
CREATE TABLE chats (
  id VARCHAR PRIMARY KEY,
  user1_id VARCHAR NOT NULL,
  user2_id VARCHAR NOT NULL,
  last_message TEXT,
  last_message_time TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Messages table
CREATE TABLE messages (
  id VARCHAR PRIMARY KEY,
  chat_id VARCHAR NOT NULL REFERENCES chats(id),
  sender_id VARCHAR NOT NULL,
  content TEXT,
  message_type VARCHAR DEFAULT 'text',
  media_url TEXT,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_read BOOLEAN DEFAULT false
);

-- Groups table
CREATE TABLE groups (
  id VARCHAR PRIMARY KEY,
  name VARCHAR NOT NULL,
  created_by VARCHAR NOT NULL,
  members_list VARCHAR[] NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Group messages table
CREATE TABLE group_messages (
  id VARCHAR PRIMARY KEY,
  group_id VARCHAR NOT NULL REFERENCES groups(id),
  sender_id VARCHAR NOT NULL,
  content TEXT,
  message_type VARCHAR DEFAULT 'text',
  media_url TEXT,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Row Level Security (RLS)

Enable RLS on all tables for security:

```sql
-- Chats RLS
ALTER TABLE chats ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read their chats" ON chats
FOR SELECT USING (
  user1_id = auth.uid() OR user2_id = auth.uid()
);

CREATE POLICY "Users can insert chats" ON chats
FOR INSERT WITH CHECK (
  user1_id = auth.uid() OR user2_id = auth.uid()
);

-- Messages RLS
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read chat messages" ON messages
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM chats 
    WHERE chats.id = messages.chat_id 
    AND (chats.user1_id = auth.uid() OR chats.user2_id = auth.uid())
  )
);

CREATE POLICY "Users can insert messages" ON messages
FOR INSERT WITH CHECK (
  sender_id = auth.uid()
);
```

## 📁 Storage Setup

### Create Storage Bucket

1. Go to Storage → Buckets in Supabase Dashboard
2. Create bucket: `chat_media`
3. Set public access: `false` (private by default)
4. Configure RLS policies

### Storage Policies

```sql
-- Allow users to upload media
CREATE POLICY "Users can upload media" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'chat_media' AND
  auth.uid() = owner
);

-- Allow users to read their media
CREATE POLICY "Users can read their media" ON storage.objects
FOR SELECT USING (
  bucket_id = 'chat_media' AND
  auth.uid() = owner
);

-- Allow users to delete their media
CREATE POLICY "Users can delete their media" ON storage.objects
FOR DELETE USING (
  bucket_id = 'chat_media' AND
  auth.uid() = owner
);
```

## 🔄 Integration Patterns

### Pattern 1: Firebase Primary, Supabase Backup

```dart
class ChatService {
  final FirebaseService _firebase = FirebaseService();
  final SupabaseService _supabase = SupabaseService();
  
  Future<void> saveMessage(MessageModel message) async {
    // Save to Firebase (primary)
    await _firebase.saveMessage(message);
    
    // Save to Supabase (backup, if enabled)
    if (_supabase.isAvailable) {
      await _supabase.saveMessage(message);
    }
  }
}
```

### Pattern 2: Supabase Primary, Firebase Fallback

```dart
class StorageService {
  final FirebaseStorageService _firebase = FirebaseStorageService();
  final SupabaseService _supabase = SupabaseService();
  
  Future<String?> uploadFile(File file, String path) async {
    // Try Supabase first (if enabled)
    if (_supabase.isAvailable && _supabase.enableSupabaseStorage) {
      final result = await _supabase.uploadFile(file, path);
      if (result != null) return result;
    }
    
    // Fallback to Firebase
    return await _firebase.uploadFile(file, path);
  }
}
```

### Pattern 3: Feature-Based Selection

```dart
class MediaService {
  // Use Supabase for storage (cheaper)
  Future<String?> uploadMedia(File file) async {
    if (SupabaseService.enableSupabaseStorage) {
      return await SupabaseService().uploadFile(file, 'media');
    }
    return await FirebaseStorageService().uploadFile(file, 'media');
  }
  
  // Use Firebase for real-time features
  Stream<List<MessageModel>> getMessages(String chatId) {
    return FirebaseService().getMessagesStream(chatId);
  }
}
```

## 🎛️ Configuration Options

### Environment Variables

```bash
# Enable Supabase storage only
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-anon-key
ENABLE_SUPABASE_STORAGE=true
ENABLE_SUPABASE_DATABASE=false

# Enable both
ENABLE_SUPABASE_STORAGE=true
ENABLE_SUPABASE_DATABASE=true

# Disable completely
ENABLE_SUPABASE_STORAGE=false
ENABLE_SUPABASE_DATABASE=false
```

### Runtime Configuration

```dart
void main() {
  // Configure based on environment
  final enableStorage = bool.fromEnvironment('ENABLE_SUPABASE_STORAGE', defaultValue: false);
  final enableDatabase = bool.fromEnvironment('ENABLE_SUPABASE_DATABASE', defaultValue: false);
  
  SupabaseService.configure(
    enableStorage: enableStorage,
    enableDatabase: enableDatabase,
  );
  
  runApp(MyApp());
}
```

## 📊 Monitoring & Analytics

### Supabase Dashboard

Monitor usage in Supabase Dashboard:
- **Database**: Row counts, query performance
- **Storage**: File counts, bandwidth usage
- **Authentication**: User signups, active users
- **Functions**: Execution counts, performance

### Cost Tracking

Set up usage alerts:
1. Go to Organization Settings → Billing
2. Set up usage alerts for storage and database
3. Monitor monthly usage patterns

### Performance Monitoring

```dart
class SupabaseMonitor {
  static Future<void> logOperation(String operation, Duration duration) async {
    if (kDebugMode) {
      print('Supabase $operation: ${duration.inMilliseconds}ms');
    }
    
    // Log to analytics if enabled
    if (AnalyticsService.isEnabled) {
      await AnalyticsService.logEvent('supabase_operation', {
        'operation': operation,
        'duration_ms': duration.inMilliseconds,
      });
    }
  }
}
```

## 🚨 Important Notes

### Free Tier Limitations

1. **Storage**: 1GB free, then $0.02/GB/month
2. **Database**: 500MB free, then $0.01/GB/month  
3. **Bandwidth**: 2GB free, then $0.01/GB/month
4. **Auth**: 50K MAU free, then $0.01/MAU

### When to Use Supabase

**✅ Good for:**
- MVP and early-stage apps
- Low to medium traffic (<10K users)
- Cost-sensitive projects
- Simple storage needs

**❌ Consider Firebase when:**
- High traffic (>50K users)
- Complex real-time features
- Global CDN requirements
- Enterprise features needed

### Migration Strategy

If you start with Supabase and need to migrate to Firebase:

1. **Data Migration**: Use Supabase export/import tools
2. **Storage Migration**: Copy files between storage buckets
3. **Code Updates**: Update service implementations
4. **Testing**: Thoroughly test all features

## 🎯 Best Practices

### 1. Graceful Degradation

```dart
class MediaService {
  Future<String?> uploadFile(File file, String path) async {
    try {
      // Try primary service
      return await _primaryService.uploadFile(file, path);
    } catch (e) {
      // Fallback to secondary service
      return await _secondaryService.uploadFile(file, path);
    }
  }
}
```

### 2. Feature Flags

```dart
class FeatureFlags {
  static bool get useSupabaseStorage => 
    SupabaseService.enableSupabaseStorage && 
    !isHighTrafficPeriod();
  
  static bool get useSupabaseDatabase => 
    SupabaseService.enableSupabaseDatabase && 
    !isHighTrafficPeriod();
}
```

### 3. Monitoring

```dart
class ServiceMonitor {
  static void trackServiceUsage(String service, bool success) {
    // Log to analytics
    AnalyticsService.logEvent('service_usage', {
      'service': service,
      'success': success,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
```

## 📞 Support

For Supabase-specific issues:
- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Community](https://supabase.com/community)
- [Supabase GitHub](https://github.com/supabase/supabase)

For Chatly integration issues:
- Check the main [Deployment Guide](./deployment_guide.md)
- Review [Troubleshooting Guide](./troubleshooting.md)

---

**Remember**: Supabase integration is completely optional. Your Chatly app will work perfectly without it, using Firebase as the primary backend service.