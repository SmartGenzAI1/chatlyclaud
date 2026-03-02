// ============================================================================
// FILE: lib/features/chat/presentation/screens/chat_list_screen.dart
// PURPOSE: Real-time chat list with resolved usernames, skeleton loading,
//          gradient avatars, and new-chat bottom sheet.
// ============================================================================

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/chat_provider.dart';
import '../../../../router/app_router.dart';
import '../../../../data/models/chat_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/user_cache.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // resolved uid → username map, populated from UserCache
  final Map<String, String> _resolvedNames = {};
  bool _resolving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _prefetchUsernames();
  }

  Future<void> _prefetchUsernames() async {
    if (_resolving) return;
    _resolving = true;
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final myUid = authProvider.user?.uid ?? '';

    // Collect all "other" participants
    final uids = chatProvider.chats
        .map((c) => c.getOtherParticipantId(myUid) ?? '')
        .where((u) => u.isNotEmpty && !_resolvedNames.containsKey(u))
        .toSet()
        .toList();

    if (uids.isEmpty) { _resolving = false; return; }

    await UserCache.instance.prefetch(uids);
    if (!mounted) return;

    final resolved = <String, String>{};
    for (final uid in uids) {
      resolved[uid] = await UserCache.instance.getUsername(uid);
    }
    if (mounted) setState(() { _resolvedNames.addAll(resolved); _resolving = false; });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final myUid = authProvider.user?.uid ?? '';

    // Trigger username prefetch whenever chats update
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefetchUsernames());

    final chats = chatProvider.chats.where((c) {
      if (_searchQuery.isEmpty) return true;
      final otherUid = c.getOtherParticipantId(myUid) ?? '';
      final resolvedName = _resolvedNames[otherUid] ?? otherUid;
      return resolvedName.toLowerCase().contains(_searchQuery) ||
          (c.lastMessage ?? '').toLowerCase().contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(colorScheme),
      body: chatProvider.isLoading
          ? _buildSkeleton()
          : chats.isEmpty
              ? _buildEmptyState(context)
              : _buildChatList(context, chats, authProvider),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewChatSheet(context, authProvider, chatProvider),
        icon: const Icon(Icons.edit_rounded),
        label: const Text('New Chat'),
        elevation: 3,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ColorScheme colorScheme) {
    return AppBar(
      backgroundColor: colorScheme.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Search chats, messages…',
                border: InputBorder.none,
                filled: false,
                hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
              ),
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            )
          : const Text('Messages',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22)),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
          onPressed: () => setState(() {
            _isSearching = !_isSearching;
            if (!_isSearching) { _searchQuery = ''; _searchController.clear(); }
          }),
        ),
      ],
    );
  }

  Widget _buildSkeleton() {
    return ListView.separated(
      itemCount: 6,
      separatorBuilder: (_, __) => Divider(height: 1, indent: 86),
      itemBuilder: (_, __) => const ChatTileSkeleton(),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary.withOpacity(0.15),
                  colorScheme.tertiary.withOpacity(0.15),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.chat_bubble_outline_rounded,
                size: 48, color: colorScheme.primary.withOpacity(0.6)),
          ),
          const SizedBox(height: 20),
          Text(
            _searchQuery.isEmpty ? 'No Messages Yet' : 'No results',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Tap "New Chat" to start a conversation'
                : 'Try a different search term',
            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.45)),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                final chat = Provider.of<ChatProvider>(context, listen: false);
                _showNewChatSheet(context, auth, chat);
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Start a Chat'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChatList(
    BuildContext context,
    List<ChatModel> chats,
    AuthProvider authProvider,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final myUid = authProvider.user?.uid ?? '';

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: chats.length,
      separatorBuilder: (_, __) => Divider(
          height: 1, indent: 86, color: colorScheme.outlineVariant.withOpacity(0.25)),
      itemBuilder: (context, index) {
        final chat = chats[index];
        final otherUid = chat.getOtherParticipantId(myUid) ?? 'Unknown';
        final displayName = _resolvedNames[otherUid] ??
            otherUid.substring(0, otherUid.length.clamp(0, 8)).toLowerCase();
        final unread = chat.getUnreadCount(myUid);
        final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => AppRouter.navigateTo(
              context,
              AppRouter.chat,
              arguments: {
                'chatId': chat.chatId,
                'otherUserId': otherUid,
                'otherUsername': displayName,
              },
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Gradient avatar
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _avatarColors(otherUid),
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _avatarColors(otherUid)[0].withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Chat info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '@$displayName',
                                style: TextStyle(
                                  fontWeight: unread > 0
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              _formatTime(chat.lastMessageAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: unread > 0
                                    ? colorScheme.primary
                                    : colorScheme.onSurface.withOpacity(0.38),
                                fontWeight: unread > 0
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                chat.lastMessage ?? 'Say hello 👋',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colorScheme.onSurface.withOpacity(
                                      unread > 0 ? 0.85 : 0.45),
                                  fontWeight: unread > 0
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (unread > 0)
                              Container(
                                constraints: const BoxConstraints(minWidth: 20),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  unread > 99 ? '99+' : '$unread',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays == 0) return DateFormat.jm().format(dt);
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return DateFormat.E().format(dt);
    return DateFormat.MMMd().format(dt);
  }

  List<Color> _avatarColors(String uid) {
    const pairs = [
      [Color(0xFF667EEA), Color(0xFF764BA2)],
      [Color(0xFFF093FB), Color(0xFFF5576C)],
      [Color(0xFF4FACFE), Color(0xFF00F2FE)],
      [Color(0xFF43E97B), Color(0xFF38F9D7)],
      [Color(0xFFFA709A), Color(0xFFFEE140)],
      [Color(0xFFA18CD1), Color(0xFFFBC2EB)],
      [Color(0xFF6EE2F5), Color(0xFF6454F0)],
      [Color(0xFFFF9A9E), Color(0xFFFECFEF)],
    ];
    final hash = uid.codeUnits.fold<int>(0, (a, b) => a ^ (b * 31 + a));
    final pair = pairs[hash.abs() % pairs.length];
    return [pair[0], pair[1]];
  }

  void _showNewChatSheet(
    BuildContext context,
    AuthProvider authProvider,
    ChatProvider chatProvider,
  ) {
    final ctrlr = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? errorMsg;
    bool loading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => Padding(
          padding: EdgeInsets.fromLTRB(
              24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 32),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(ctx).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.person_search_rounded,
                          color: Theme.of(ctx).colorScheme.primary),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('New Message',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Find a user by @username',
                              style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: ctrlr,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    hintText: 'Enter exact @username',
                    prefixText: '@',
                    errorText: errorMsg,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter a username' : null,
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: loading ? null : () async {
                      if (!formKey.currentState!.validate()) return;
                      set(() { loading = true; errorMsg = null; });

                      try {
                        final target = await AuthService()
                            .getUserByUsername(ctrlr.text.trim().toLowerCase());

                        if (target == null) {
                          set(() { loading = false; errorMsg = 'User not found'; });
                          return;
                        }

                        if (target.uid == authProvider.user?.uid) {
                          set(() { loading = false; errorMsg = "That's your own username!"; });
                          return;
                        }

                        final chatId = await chatProvider.createOrGetChat(
                          authProvider.user!.uid,
                          target.uid,
                        );

                        UserCache.instance.prefetch([target.uid]);

                        if (ctx.mounted) Navigator.pop(ctx);
                        if (chatId != null && context.mounted) {
                          AppRouter.navigateTo(context, AppRouter.chat,
                              arguments: {
                                'chatId': chatId,
                                'otherUserId': target.uid,
                                'otherUsername': target.username,
                              });
                        }
                      } catch (e) {
                        set(() { loading = false; errorMsg = 'Something went wrong'; });
                      }
                    },
                    icon: loading
                        ? const SizedBox(width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_rounded),
                    label: Text(loading ? 'Searching…' : 'Start Conversation'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
