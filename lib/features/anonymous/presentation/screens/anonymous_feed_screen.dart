// ============================================================================
// FILE: lib/features/anonymous/presentation/screens/anonymous_feed_screen.dart
// PURPOSE: Anonymous "Lucky Chat" feed with working post functionality
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/subscription_provider.dart';

class AnonymousFeedScreen extends StatefulWidget {
  const AnonymousFeedScreen({super.key});

  @override
  State<AnonymousFeedScreen> createState() => _AnonymousFeedScreenState();
}

class _AnonymousFeedScreenState extends State<AnonymousFeedScreen> {
  // Local demo posts (until Firestore is wired)
  final List<_AnonPost> _posts = [];

  @override
  Widget build(BuildContext context) {
    final subProvider = Provider.of<SubscriptionProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final weeklyLimit = subProvider.getAnonymousWeeklyLimit();
    final charLimit = subProvider.getAnonymousCharLimit();
    final usedCount = _posts.length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.masks_rounded, color: ThemeConstants.anonymousMask),
            const SizedBox(width: 8),
            const Text('Lucky Chat',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Usage bar
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: ThemeConstants.anonymousBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.swap_horiz_rounded,
                    color: ThemeConstants.anonymousMask, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$usedCount / $weeklyLimit messages used this week',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    width: 80,
                    height: 6,
                    child: LinearProgressIndicator(
                      value: weeklyLimit > 0 ? usedCount / weeklyLimit : 0,
                      backgroundColor: Colors.grey.shade200,
                      color: ThemeConstants.anonymousMask,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Feed
          Expanded(
            child: _posts.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _posts.length,
                    itemBuilder: (ctx, i) {
                      final post = _posts[_posts.length - 1 - i];
                      return _buildPostCard(context, post, colorScheme);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: usedCount >= weeklyLimit
            ? () => _showLimitDialog(context)
            : () => _showPostDialog(context, charLimit),
        backgroundColor: usedCount >= weeklyLimit
            ? Colors.grey
            : ThemeConstants.anonymousMask,
        icon: Icon(usedCount >= weeklyLimit ? Icons.lock : Icons.add_rounded),
        label: Text(
            usedCount >= weeklyLimit ? 'Limit Reached' : 'Post Anonymous'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.masks_outlined,
              size: 80,
              color: ThemeConstants.anonymousMask.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            'No anonymous posts yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to post anonymously!',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(
      BuildContext context, _AnonPost post, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Anonymous',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    _formatPostTime(post.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.4),
                        ),
                  ),
                ],
              ),
              const Spacer(),
              if (post.isOwn)
                Chip(
                  label: const Text('You', style: TextStyle(fontSize: 11)),
                  backgroundColor:
                      colorScheme.primaryContainer,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(post.message, style: const TextStyle(fontSize: 15, height: 1.5)),
          if (post.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: post.tags
                  .map((tag) => Chip(
                        label: Text('#$tag',
                            style: const TextStyle(fontSize: 11)),
                        backgroundColor:
                            ThemeConstants.anonymousMask.withOpacity(0.1),
                        side: BorderSide.none,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  String _formatPostTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('About Lucky Chat'),
        content: const Text(
          'Post anonymous messages with topic tags. Other users with similar interests will see your posts. Weekly limits apply based on your subscription tier.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Got it')),
        ],
      ),
    );
  }

  void _showLimitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Weekly Limit Reached'),
        content: const Text(
            'Upgrade to Plus or Pro for more anonymous messages per week.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Maybe later')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, '/premium');
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  void _showPostDialog(BuildContext context, int charLimit) {
    final controller = TextEditingController();
    final tagsController = TextEditingController();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            const Text('Post Anonymously',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLength: charLimit,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Share your thoughts anonymously...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (optional)',
                hintText: 'advice, fun, travel',
                prefixIcon: Icon(Icons.tag),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  final msg = controller.text.trim();
                  if (msg.isEmpty) return;
                  final tags = tagsController.text
                      .split(',')
                      .map((t) => t.trim())
                      .where((t) => t.isNotEmpty)
                      .toList();
                  setState(() {
                    _posts.add(_AnonPost(
                      message: msg,
                      tags: tags,
                      createdAt: DateTime.now(),
                      isOwn: true,
                    ));
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Posted anonymously! ✓'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.send_rounded),
                label: const Text('Post Anonymously'),
                style: FilledButton.styleFrom(
                    backgroundColor: ThemeConstants.anonymousMask),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnonPost {
  final String message;
  final List<String> tags;
  final DateTime createdAt;
  final bool isOwn;
  _AnonPost({
    required this.message,
    required this.tags,
    required this.createdAt,
    required this.isOwn,
  });
}
