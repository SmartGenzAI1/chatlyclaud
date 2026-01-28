// ============================================================================
// FILE: lib/features/chat/presentation/screens/chat_screen.dart
// PURPOSE: Individual chat conversation screen
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/themes/modern_colors.dart';
import '../../../core/themes/app_spacing.dart';
import '../../../core/widgets/common/loading_indicator.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/chat_provider.dart';
import '../../../data/models/message_model.dart';
import '../widgets/modern_message_bubble.dart';
import '../widgets/enhanced_input_bar.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserId;
  final String otherUsername;
  
  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserId,
    required this.otherUsername,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _loadMessages();
  }
  
  void _loadMessages() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.loadMessages(widget.chatId);
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final messages = chatProvider.getMessages(widget.chatId);
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              child: Text(widget.otherUsername.substring(0, 1).toUpperCase()),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.otherUsername,
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Online',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Show chat options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text('No messages yet. Say hi! 👋'),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: AppSpacing.allMD,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == authProvider.user!.uid;
                      
                      return ModernMessageBubble(
                        message: message,
                        isMe: isMe,
                        onSwipeReply: () {
                          // TODO: Implement reply functionality
                        },
                        onLongPress: () {
                          // TODO: Show message options
                        },
                      );
                    },
                  ),
          ),
          
          // Enhanced input area
          EnhancedInputBar(
            controller: _messageController,
            onSendMessage: () => _sendMessage(authProvider, chatProvider),
            onAttachmentTap: () {
              // TODO: Show attachment options
            },
            onEmojiTap: () {
              // TODO: Show emoji picker
            },
            onVoiceTap: () {
              // TODO: Start voice recording
            },
          ),
        ],
      ),
    );
  }
  
  Future<void> _sendMessage(
    AuthProvider authProvider,
    ChatProvider chatProvider,
  ) async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    _messageController.clear();
    
    final retentionDays = authProvider.userModel?.settings.retentionDays ??
        AppConstants.defaultRetentionDays;
    
    final success = await chatProvider.sendMessage(
      widget.chatId,
      authProvider.user!.uid,
      text,
      retentionDays,
    );
    
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send message'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
