// ============================================================================
// FILE: lib/features/premium/presentation/screens/premium_screen.dart
// PURPOSE: Premium subscription screen with tier comparison
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/theme_constants.dart';
import '../../../../core/widgets/common/custom_button.dart';
import '../../../../providers/subscription_provider.dart';
import '../../../../data/models/user_model.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade to Premium'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: ThemeConstants.premiumGradient,
                borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.workspace_premium,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Unlock Premium Features',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'More messages, better customization, no ads',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Plan cards
            _buildPlanCard(
              context,
              tier: UserTier.plus,
              name: 'Plus',
              price: AppConstants.plusYearlyPrice,
              color: ThemeConstants.plusBadge,
              features: [
                '10 anonymous messages per week',
                'Create 1 group',
                '15 themes & 50+ wallpapers',
                'No ads',
                'Smart notification timing',
                'Custom message retention',
              ],
              isCurrentPlan: subscriptionProvider.currentTier == UserTier.plus,
            ),
            
            const SizedBox(height: 16),
            
            _buildPlanCard(
              context,
              tier: UserTier.pro,
              name: 'Pro',
              price: AppConstants.proYearlyPrice,
              color: ThemeConstants.proBadge,
              features: [
                'Unlimited anonymous messages',
                'Create 2 groups',
                'Unlimited themes & animated wallpapers',
                'No ads + early feature access',
                'Advanced smart algorithms',
                'Conversation health scores',
                'Priority support',
              ],
              isRecommended: true,
              isCurrentPlan: subscriptionProvider.currentTier == UserTier.pro,
            ),
            
            const SizedBox(height: 32),
            
            // Feature comparison
            Text(
              'Feature Comparison',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            
            const SizedBox(height: 16),
            
            _buildComparisonTable(context),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlanCard(
    BuildContext context, {
    required UserTier tier,
    required String name,
    required int price,
    required Color color,
    required List<String> features,
    bool isRecommended = false,
    bool isCurrentPlan = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isRecommended ? color : Colors.grey.shade300,
          width: isRecommended ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConstants.borderRadiusMedium - 1),
                topRight: Radius.circular(AppConstants.borderRadiusMedium - 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.star, color: color),
                    const SizedBox(width: 8),
                    Text(
                      name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                if (isRecommended)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Recommended',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Price
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '₹',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  price.toString(),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '/year',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
          
          // Features
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: features
                  .map((feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: color,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                feature,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
          
          // Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomButton(
              text: isCurrentPlan ? 'Current Plan' : 'Choose $name',
              onPressed: isCurrentPlan
                  ? null
                  : () {
                      // TODO: Implement subscription purchase
                      _showPurchaseDialog(context, tier, name, price);
                    },
              backgroundColor: color,
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildComparisonTable(BuildContext context) {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      children: [
        _buildTableRow(
          context,
          feature: 'Feature',
          free: 'Free',
          plus: 'Plus',
          pro: 'Pro',
          isHeader: true,
        ),
        _buildTableRow(
          context,
          feature: 'Anonymous Messages',
          free: '3/week',
          plus: '10/week',
          pro: 'Unlimited',
        ),
        _buildTableRow(
          context,
          feature: 'Group Creation',
          free: 'No',
          plus: '1 group',
          pro: '2 groups',
        ),
        _buildTableRow(
          context,
          feature: 'Themes',
          free: '3',
          plus: '15',
          pro: 'Unlimited',
        ),
        _buildTableRow(
          context,
          feature: 'Ads',
          free: 'Yes',
          plus: 'No',
          pro: 'No',
        ),
        _buildTableRow(
          context,
          feature: 'Smart Algorithms',
          free: 'Basic',
          plus: 'Smart',
          pro: 'Advanced',
        ),
      ],
    );
  }
  
  TableRow _buildTableRow(
    BuildContext context, {
    required String feature,
    required String free,
    required String plus,
    required String pro,
    bool isHeader = false,
  }) {
    final style = isHeader
        ? Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            )
        : Theme.of(context).textTheme.bodySmall;
    
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(feature, style: style),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(free, style: style, textAlign: TextAlign.center),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(plus, style: style, textAlign: TextAlign.center),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(pro, style: style, textAlign: TextAlign.center),
        ),
      ],
    );
  }
  
  void _showPurchaseDialog(
    BuildContext context,
    UserTier tier,
    String name,
    int price,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Upgrade to $name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Price: ₹$price/year'),
            const SizedBox(height: 16),
            const Text(
              'Note: This is a demo. Real payment integration would be implemented using RevenueCat or In-App Purchase packages.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement actual purchase
              final subscriptionProvider = Provider.of<SubscriptionProvider>(
                context,
                listen: false,
              );
              subscriptionProvider.setTier(tier);
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Upgraded to $name! (Demo)'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }
}
