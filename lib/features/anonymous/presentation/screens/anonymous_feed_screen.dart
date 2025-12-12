// ============================================================================
// FILE: lib/features/anonymous/presentation/screens/anonymous_feed_screen.dart
// PURPOSE: Anonymous "Lucky Chat" feed
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../providers/subscription_provider.dart';

class AnonymousFeedScreen extends StatelessWidget {
  const AnonymousFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);
    final weeklyLimit = subscriptionProvider.getAnonymousWeeklyLimit();
    final charLimit = subscriptionProvider.getAnonymousCharLimit();
    
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.masks, color: ThemeConstants.anonymousMask),
            SizedBox(width: 8),
            Text('Lucky Chat'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showInfoDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Usage indicator
          Container(
            padding: const EdgeInsets.all(16),
            color: ThemeConstants.anonymousBackground,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.message,
                  size: 20,
                  color: ThemeConstants.anonymousMask,
                ),
                const SizedBox(width: 8),
                Text(
                  'Messages: 0/$weeklyLimit used this week',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          // Feed
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.masks_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No anonymous messages yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Post your first anonymous message!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade500,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showPostDialog(context, charLimit);
        },
        backgroundColor: ThemeConstants.anonymousMask,
        icon: const Icon(Icons.add),
        label: const Text('Post Anonymous'),
      ),
    );
  }
  
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Lucky Chat'),
        content: const Text(
          'Lucky Chat lets you post anonymous messages with topic tags. '
          'Other users with similar interests will see your messages. '
          'You can send connection requests to move from anonymous to regular chat.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
  
  void _showPostDialog(BuildContext context, int charLimit) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Post Anonymous Message'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              maxLength: charLimit,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Share your thoughts...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Add topics (e.g., #advice #fun):',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            // TODO: Implement topic selection
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Post anonymous message
              Navigator.pop(context);
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }
}
