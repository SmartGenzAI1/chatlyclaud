// ============================================================================
// FILE: lib/features/groups/presentation/screens/groups_list_screen.dart
// PURPOSE: Group chat list with create/join functionality
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/chat_provider.dart';
import '../../../../router/app_router.dart';
import '../../../../services/user_cache.dart';

class GroupsListScreen extends StatefulWidget {
  const GroupsListScreen({super.key});

  @override
  State<GroupsListScreen> createState() => _GroupsListScreenState();
}

class _GroupsListScreenState extends State<GroupsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final chat = Provider.of<ChatProvider>(context, listen: false);
      if (auth.user != null) {
        chat.loadUserChats(auth.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final chat = Provider.of<ChatProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final groups = chat.groupChats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showCreateGroupDialog(context),
          ),
        ],
      ),
      body: groups.isEmpty
          ? _buildEmptyState(colorScheme)
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: groups.length,
              itemBuilder: (ctx, i) => _buildGroupTile(context, groups[i], auth, colorScheme),
            ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.group_outlined, size: 40, color: colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text('No groups yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Create or join a group to get started!',
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5))),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _showCreateGroupDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Create Group'),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupTile(BuildContext context, dynamic chat, AuthProvider auth, ColorScheme colorScheme) {
    final groupName = chat.groupName ?? 'Unnamed Group';
    final memberCount = (chat.participants as List?)?.length ?? 0;
    final lastMsg = chat.lastMessage ?? 'No messages yet';
    final initial = groupName.isNotEmpty ? groupName[0].toUpperCase() : 'G';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: colorScheme.primaryContainer,
          child: Text(initial, style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
        ),
        title: Text(groupName, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('$memberCount members • $lastMsg', maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => AppRouter.navigateTo(context, AppRouter.chat, arguments: {
          'chatId': chat.chatId,
          'otherUserId': '',
          'otherUsername': groupName,
        }),
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Group'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Group Name',
            hintText: 'Enter a name for your group',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(ctx);

              final auth = Provider.of<AuthProvider>(context, listen: false);
              final chat = Provider.of<ChatProvider>(context, listen: false);
              if (auth.user != null) {
                await chat.createGroupChat(name, auth.user!.uid, []);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Group "$name" created! Invite others from the group chat.'))
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
