// ============================================================================
// FILE: lib/features/settings/presentation/screens/settings_screen.dart
// PURPOSE: App settings - fully functional with all options working
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/user_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/theme_provider.dart';
import '../../../../providers/subscription_provider.dart';
import '../../../../router/app_router.dart';
import '../../../../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _privacyExpanded = false;
  bool _storageExpanded = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final subProvider = Provider.of<SubscriptionProvider>(context);
    final user = authProvider.userModel;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // ── Profile Header ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.tertiary,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      // Avatar
                      GestureDetector(
                        onTap: () => _showEditUsernameDialog(context, authProvider),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 44,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              child: Text(
                                (user?.username ?? '?').substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.edit, size: 14, color: colorScheme.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '@${user?.username ?? 'unknown'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user?.email ?? '',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13,
                        ),
                      ),
                      if (subProvider.isPremium) ...[
                        const SizedBox(height: 8),
                        _buildPremiumBadge(subProvider.isPro),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Content ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Upgrade banner
                  if (!subProvider.isPremium) _buildUpgradeBanner(context, colorScheme),

                  _sectionLabel('Preferences'),
                  _card([
                    // Theme
                    ListTile(
                      leading: Icon(Icons.palette_outlined, color: colorScheme.primary),
                      title: const Text('Appearance'),
                      subtitle: Text(_themeName(themeProvider.themeMode)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showThemeSheet(context, themeProvider),
                    ),
                    _divider(),

                    // Notifications
                    ListTile(
                      leading: Icon(Icons.notifications_outlined, color: colorScheme.primary),
                      title: const Text('Notifications'),
                      subtitle: Text(
                        (user?.settings.notificationsEnabled ?? true)
                            ? 'Enabled'
                            : 'Disabled',
                      ),
                      trailing: Switch.adaptive(
                        value: user?.settings.notificationsEnabled ?? true,
                        onChanged: (val) => _updateSetting(
                          context,
                          authProvider,
                          user?.settings.copyWith(notificationsEnabled: val) ??
                              UserSettings(notificationsEnabled: val),
                        ),
                      ),
                    ),
                  ]),

                  _sectionLabel('Privacy & Security'),
                  _card([
                    ListTile(
                      leading:
                          Icon(Icons.lock_outline, color: colorScheme.primary),
                      title: const Text('Privacy & Security'),
                      trailing: Icon(
                        _privacyExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                      ),
                      onTap: () =>
                          setState(() => _privacyExpanded = !_privacyExpanded),
                    ),
                    if (_privacyExpanded) ...[
                      _divider(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Column(
                          children: [
                            _toggleRow(
                              label: 'Show online status',
                              subtitle: 'Let others see when you\'re active',
                              value: user?.settings.showOnline ?? true,
                              onChanged: (val) => _updateSetting(
                                context,
                                authProvider,
                                user?.settings.copyWith(showOnline: val) ??
                                    UserSettings(showOnline: val),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _toggleRow(
                              label: 'Allow contact sync',
                              subtitle: 'Find people from your contacts',
                              value:
                                  user?.settings.allowContactsSync ?? false,
                              onChanged: (val) => _updateSetting(
                                context,
                                authProvider,
                                user?.settings.copyWith(
                                        allowContactsSync: val) ??
                                    UserSettings(allowContactsSync: val),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ]),

                  _sectionLabel('Storage & Data'),
                  _card([
                    ListTile(
                      leading: Icon(Icons.storage_outlined,
                          color: colorScheme.primary),
                      title: const Text('Storage & Data'),
                      subtitle: Text(
                          'Messages delete after ${user?.settings.retentionDays ?? 7} days'),
                      trailing: Icon(
                        _storageExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                      ),
                      onTap: () => setState(
                          () => _storageExpanded = !_storageExpanded),
                    ),
                    if (_storageExpanded) ...[
                      _divider(),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Auto-delete messages after',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                              children: [7, 14, 30].map((days) {
                                final isSelected =
                                    (user?.settings.retentionDays ?? 7) ==
                                        days;
                                return GestureDetector(
                                  onTap: () => _updateSetting(
                                    context,
                                    authProvider,
                                    user?.settings.copyWith(
                                            retentionDays: days) ??
                                        UserSettings(retentionDays: days),
                                  ),
                                  child: AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? colorScheme.primary
                                          : colorScheme
                                              .surfaceContainerHighest,
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '$days days',
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : colorScheme.onSurface,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ]),

                  _sectionLabel('Support'),
                  _card([
                    ListTile(
                      leading: Icon(Icons.help_outline,
                          color: colorScheme.primary),
                      title: const Text('Help & Support'),
                      subtitle: const Text('Get help or report issues'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showHelpDialog(context),
                    ),
                    _divider(),
                    ListTile(
                      leading: Icon(Icons.info_outline,
                          color: colorScheme.primary),
                      title: const Text('About Chatly'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showAboutDialog(context),
                    ),
                  ]),

                  _sectionLabel('Account'),
                  _card([
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.orange),
                      title: const Text('Logout',
                          style: TextStyle(color: Colors.orange)),
                      onTap: () =>
                          _showLogoutDialog(context, authProvider),
                    ),
                    _divider(),
                    ListTile(
                      leading:
                          const Icon(Icons.delete_forever, color: Colors.red),
                      title: const Text('Delete Account',
                          style: TextStyle(color: Colors.red)),
                      subtitle: const Text('Permanently remove your account'),
                      onTap: () =>
                          _showDeleteDialog(context, authProvider),
                    ),
                  ]),

                  const SizedBox(height: 32),
                  Center(
                    child: Text(
                      '${AppConstants.appName} v${AppConstants.appVersion}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.4),
                          ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 20, 0, 8),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );

  Widget _card(List<Widget> children) => Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(children: children),
        ),
      );

  Widget _divider() => Divider(
      height: 1,
      indent: 56,
      color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3));

  Widget _toggleRow({
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) =>
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6))),
              ],
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      );

  Widget _buildPremiumBadge(bool isPro) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          gradient: isPro
              ? const LinearGradient(
                  colors: [Color(0xFFFF6B35), Color(0xFFFF1493)])
              : const LinearGradient(
                  colors: [Color(0xFF9B59B6), Color(0xFF3498DB)]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(
              isPro ? 'PRO' : 'PLUS',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12),
            ),
          ],
        ),
      );

  Widget _buildUpgradeBanner(
      BuildContext context, ColorScheme colorScheme) =>
      GestureDetector(
        onTap: () => AppRouter.navigateTo(context, AppRouter.premium),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF9B59B6), Color(0xFF3498DB)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.workspace_premium,
                  color: Colors.white, size: 32),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Upgrade to Premium',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    Text('Unlock exclusive features',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.white, size: 16),
            ],
          ),
        ),
      );

  String _themeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System default';
    }
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _updateSetting(
    BuildContext context,
    AuthProvider authProvider,
    UserSettings newSettings,
  ) async {
    if (authProvider.user == null) return;
    try {
      await AuthService()
          .updateUserSettings(authProvider.user!.uid, newSettings);
      await authProvider.refreshUserData();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showThemeSheet(BuildContext context, ThemeProvider themeProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
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
            Text('Choose Theme',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            ...ThemeMode.values.map((mode) {
              final icons = {
                ThemeMode.light: Icons.light_mode_outlined,
                ThemeMode.dark: Icons.dark_mode_outlined,
                ThemeMode.system: Icons.phone_android_outlined,
              };
              return RadioListTile<ThemeMode>(
                value: mode,
                groupValue: themeProvider.themeMode,
                title: Text(_themeName(mode)),
                secondary: Icon(icons[mode]),
                onChanged: (v) {
                  themeProvider.setThemeMode(v!);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showEditUsernameDialog(
      BuildContext context, AuthProvider authProvider) {
    final controller = TextEditingController(
        text: authProvider.userModel?.username ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Username'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            prefixText: '@',
            hintText: 'new_username',
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success =
                  await authProvider.updateUsername(controller.text.trim());
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(success
                      ? 'Username updated!'
                      : authProvider.error ?? 'Failed'),
                  backgroundColor: success ? Colors.green : Colors.red,
                ));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help? Here\'s how to reach us:'),
            SizedBox(height: 16),
            Row(children: [
              Icon(Icons.email_outlined, size: 18),
              SizedBox(width: 8),
              Text('support@chatly.app'),
            ]),
            SizedBox(height: 8),
            Row(children: [
              Icon(Icons.bug_report_outlined, size: 18),
              SizedBox(width: 8),
              Flexible(child: Text('Report bugs via the contact above')),
            ]),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close')),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.tertiary],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.chat_bubble_rounded,
                    size: 36, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(AppConstants.appName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  )),
              const SizedBox(height: 4),
              Text('Version ${AppConstants.appVersion}',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurface.withOpacity(0.5),
                  )),
              const SizedBox(height: 12),
              Text(
                'Smart. Private. Connected.\nEnd-to-end encrypted messaging with privacy-first features.',
                style: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  height: 1.5,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Divider(color: colorScheme.outlineVariant.withOpacity(0.4)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Privacy Policy'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Terms of Use'),
                  ),
                ],
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 44)),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton.tonal(
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.pop(ctx);
                AppRouter.navigateAndRemoveUntil(context, AppRouter.login);
              }
            },
            style: FilledButton.styleFrom(
                backgroundColor: Colors.orange.shade100),
            child: const Text('Logout',
                style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'This will permanently delete your account and all data. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              try {
                await authProvider.deleteAccount();
                if (context.mounted) {
                  Navigator.pop(ctx);
                  AppRouter.navigateAndRemoveUntil(context, AppRouter.login);
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Failed: $e'),
                    backgroundColor: Colors.red,
                  ));
                }
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );
  }
}
