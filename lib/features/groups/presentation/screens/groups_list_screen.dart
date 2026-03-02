// ============================================================================
// FILE: lib/features/groups/presentation/screens/groups_list_screen.dart
// PURPOSE: Groups list with working create group dialog
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/subscription_provider.dart';

class GroupsListScreen extends StatefulWidget {
  const GroupsListScreen({super.key});

  @override
  State<GroupsListScreen> createState() => _GroupsListScreenState();
}

class _GroupsListScreenState extends State<GroupsListScreen> {
  final List<_GroupData> _groups = [];

  @override
  Widget build(BuildContext context) {
    final subProvider = Provider.of<SubscriptionProvider>(context);
    final canCreate = subProvider.canCreateGroups();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
      ),
      body: _groups.isEmpty
          ? _buildEmptyState(context, canCreate, colorScheme)
          : _buildGroupList(context, colorScheme),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (canCreate) {
            _showCreateGroupDialog(context);
          } else {
            _showUpgradeDialog(context);
          }
        },
        backgroundColor:
            canCreate ? colorScheme.primary : Colors.grey,
        icon: Icon(canCreate ? Icons.add_rounded : Icons.lock_outline),
        label: Text(canCreate ? 'Create Group' : 'Upgrade Required'),
      ),
    );
  }

  Widget _buildEmptyState(
      BuildContext context, bool canCreate, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.group_outlined,
                size: 60,
                color: colorScheme.primary.withOpacity(0.5)),
          ),
          const SizedBox(height: 24),
          Text(
            'No groups yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            canCreate
                ? 'Create your first group!'
                : 'Upgrade to Plus or Pro to create groups',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.4),
                ),
            textAlign: TextAlign.center,
          ),
          if (!canCreate) ...[
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/premium'),
              icon: const Icon(Icons.workspace_premium),
              label: const Text('View Plans'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGroupList(BuildContext context, ColorScheme colorScheme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _groups.length,
      itemBuilder: (ctx, i) {
        final group = _groups[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: colorScheme.outlineVariant.withOpacity(0.4)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  colorScheme.primary,
                  colorScheme.tertiary,
                ]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  group.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
            ),
            title: Text(group.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${group.memberCount} member${group.memberCount == 1 ? '' : 's'}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        );
      },
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Form(
          key: formKey,
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
              const SizedBox(height: 20),
              const Text('Create Group',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Group Name',
                  hintText: 'Enter a group name',
                  prefixIcon: Icon(Icons.group_add_outlined),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name required' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    setState(() {
                      _groups.add(_GroupData(
                        name: nameController.text.trim(),
                        memberCount: 1,
                      ));
                    });
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Group created! ✓'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Create Group'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Groups Require Plus'),
        content: const Text(
            'Upgrade to Plus to create and manage groups with your friends.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Later')),
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
}

class _GroupData {
  final String name;
  final int memberCount;
  _GroupData({required this.name, required this.memberCount});
}
