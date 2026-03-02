// ============================================================================
// FILE: lib/features/chat/presentation/screens/home_screen.dart
// PURPOSE: Main home screen — Material 3 nav bar with live unread badge
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/chat_provider.dart';
import 'chat_list_screen.dart';
import '../../../anonymous/presentation/screens/anonymous_feed_screen.dart';
import '../../../groups/presentation/screens/groups_list_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _badgeAnim;

  @override
  void initState() {
    super.initState();
    _badgeAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeData());
  }

  void _initializeData() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final chat = Provider.of<ChatProvider>(context, listen: false);
    if (auth.user != null) {
      chat.loadUserChats(auth.user!.uid);
    }
  }

  @override
  void dispose() {
    _badgeAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final chat = Provider.of<ChatProvider>(context);
    final uid = auth.user?.uid ?? '';
    final colorScheme = Theme.of(context).colorScheme;

    // Total unread across all chats
    final totalUnread = chat.chats
        .fold<int>(0, (sum, c) => sum + c.getUnreadCount(uid));

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          ChatListScreen(),
          AnonymousFeedScreen(),
          GroupsListScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => setState(() => _selectedIndex = i),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        elevation: 3,
        destinations: [
          // Chats with unread badge
          NavigationDestination(
            icon: Badge(
              isLabelVisible: totalUnread > 0 && _selectedIndex != 0,
              label: Text(totalUnread > 99 ? '99+' : '$totalUnread',
                  style: const TextStyle(fontSize: 10)),
              child: const Icon(Icons.chat_bubble_outline_rounded),
            ),
            selectedIcon: const Icon(Icons.chat_bubble_rounded),
            label: 'Chats',
          ),
          const NavigationDestination(
            icon: Icon(Icons.masks_outlined),
            selectedIcon: Icon(Icons.masks_rounded),
            label: 'Anonymous',
          ),
          const NavigationDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group_rounded),
            label: 'Groups',
          ),
          // Settings with avatar
          NavigationDestination(
            icon: _buildSettingsIcon(auth, colorScheme, false),
            selectedIcon: _buildSettingsIcon(auth, colorScheme, true),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsIcon(
      AuthProvider auth, ColorScheme colorScheme, bool selected) {
    final username = auth.userModel?.username ?? '';
    if (username.isEmpty) {
      return Icon(selected ? Icons.person_rounded : Icons.person_outlined);
    }
    return CircleAvatar(
      radius: 12,
      backgroundColor:
          selected ? colorScheme.primary : colorScheme.primaryContainer,
      child: Text(
        username[0].toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: selected ? Colors.white : colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
