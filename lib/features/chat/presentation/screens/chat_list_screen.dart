// ============================================================================
// FILE: lib/features/chat/presentation/screens/chat_list_screen.dart
// PURPOSE: List of user's conversations
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/common/loading_indicator.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/chat_provider.dart';
import '../../../../router/app_router.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: chatProvider.isLoading
          ? const LoadingIndicator(message: 'Loading chats...')
          : chatProvider.chats.isEmpty
              ? _buildEmptyState(context)
              : _buildChatList(context, chatProvider, authProvider),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement new chat dialog
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No chats yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChatList(
    BuildContext context,
    ChatProvider chatProvider,
    AuthProvider authProvider,
  ) {
    return ListView.builder(
      itemCount: chatProvider.chats.length,
      itemBuilder: (context, index) {
        final chat = chatProvider.chats[index];
        final otherUserId = chat.getOtherParticipantId(authProvider.user!.uid);
        final unreadCount = chat.getUnreadCount(authProvider.user!.uid);
        
        return ListTile(
          leading: CircleAvatar(
            child: Text(otherUserId?.substring(0, 1).toUpperCase() ?? '?'),
          ),
          title: Text(
            otherUserId ?? 'Unknown',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            chat.lastMessage ?? 'No messages yet',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTime(chat.lastMessageAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (unreadCount > 0) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          onTap: () {
            AppRouter.navigateTo(
              context,
              AppRouter.chat,
              arguments: {
                'chatId': chat.chatId,
                'otherUserId': otherUserId,
                'otherUsername': otherUserId, // TODO: Get actual username
              },
            );
          },
        );
      },
    );
  }
  
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      return DateFormat.jm().format(dateTime);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat.E().format(dateTime);
    } else {
      return DateFormat.MMMd().format(dateTime);
    }
  }
}
