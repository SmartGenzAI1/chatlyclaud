// ============================================================================
// FILE: lib/features/groups/presentation/screens/groups_list_screen.dart
// PURPOSE: List of user's groups
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../providers/subscription_provider.dart';
import '../../../premium/presentation/screens/premium_screen.dart';

class GroupsListScreen extends StatelessWidget {
  const GroupsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);
    final canCreate = subscriptionProvider.canCreateGroups();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No groups yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              canCreate
                  ? 'Create a group to get started'
                  : 'Upgrade to Plus to create groups',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (canCreate) {
            // TODO: Show create group dialog
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PremiumScreen()),
            );
          }
        },
        icon: Icon(canCreate ? Icons.add : Icons.lock),
        label: Text(canCreate ? 'Create Group' : 'Upgrade'),
      ),
    );
  }
}
