// ============================================================================
// FILE: lib/features/premium/presentation/screens/premium_screen.dart
// PURPOSE: Stunning premium subscription screen
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/subscription_provider.dart';
import '../../../../data/models/user_model.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  int _selectedTier = 1; // 0=free, 1=plus, 2=pro

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))
      ..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subProvider = Provider.of<SubscriptionProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverToBoxAdapter(
            child: Container(
              height: 280,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1A2E), Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  stops: [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -20,
                      bottom: 20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),

                    // Content
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        // Back button
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios_rounded,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),

                        // Crown icon
                        _buildAnimatedCrown(),
                        const SizedBox(height: 12),

                        const Text(
                          'Upgrade to Premium',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Get the best of Chatly',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Plan selector
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  // Toggle tabs
                  Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        _buildPlanTab(0, 'Free', colorScheme),
                        _buildPlanTab(1, 'Plus', colorScheme),
                        _buildPlanTab(2, 'Pro', colorScheme),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Plan card
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildPlanCard(context, colorScheme),
                  ),

                  const SizedBox(height: 24),

                  // Feature comparison table
                  Text(
                    'Full Comparison',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildFeatureTable(colorScheme),

                  const SizedBox(height: 32),

                  // CTA button
                  if (_selectedTier > 0)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _selectedTier == 2
                                ? [const Color(0xFFFF6B35), const Color(0xFFFF1493)]
                                : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: (_selectedTier == 2
                                      ? const Color(0xFFFF6B35)
                                      : const Color(0xFF6366F1))
                                  .withOpacity(0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () => _handleSubscribe(context, subProvider),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text(
                            'Get ${_selectedTier == 1 ? 'Plus' : 'Pro'} — ₹${_selectedTier == 1 ? '199' : '299'}/year',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      '7-day free trial · Cancel anytime',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCrown() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow ring
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        const Icon(Icons.workspace_premium_rounded,
            size: 52, color: Colors.amber),
      ],
    );
  }

  Widget _buildPlanTab(int index, String label, ColorScheme colorScheme) {
    final isSelected = _selectedTier == index;
    final colors = {
      0: [const Color(0xFF64748B), const Color(0xFF94A3B8)],
      1: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
      2: [const Color(0xFFFF6B35), const Color(0xFFFF1493)],
    };

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTier = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(colors: colors[index]!)
                : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : colorScheme.onSurface.withOpacity(0.5),
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, ColorScheme colorScheme) {
    final plans = [
      _PlanData(
        name: 'Free',
        price: '₹0',
        period: 'forever',
        color: const Color(0xFF64748B),
        features: ['200 msgs/day', '3 anon msgs/week', 'Basic encryption'],
      ),
      _PlanData(
        name: 'Plus',
        price: '₹199',
        period: '/year',
        color: const Color(0xFF6366F1),
        features: [
          '500 msgs/day',
          '10 anon msgs/week',
          '1 group (25 members)',
          'Custom themes',
          'Priority support',
        ],
        badge: 'Most Popular',
      ),
      _PlanData(
        name: 'Pro',
        price: '₹299',
        period: '/year',
        color: const Color(0xFFFF6B35),
        features: [
          '1000 msgs/day',
          'Unlimited anon msgs',
          '2 groups (25 members)',
          'All themes + wallpapers',
          'Priority support',
          'Early access to features',
        ],
        badge: 'Best Value',
      ),
    ];

    final plan = plans[_selectedTier];

    return Container(
      key: ValueKey(_selectedTier),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            plan.color.withOpacity(0.08),
            plan.color.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: plan.color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                plan.name,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: plan.color,
                ),
              ),
              const Spacer(),
              if (plan.badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: plan.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    plan.badge!,
                    style: TextStyle(
                      color: plan.color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                plan.price,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 6, left: 2),
                child: Text(
                  plan.period,
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...plan.features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: plan.color.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_rounded,
                          size: 14, color: plan.color),
                    ),
                    const SizedBox(width: 10),
                    Text(f,
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.85),
                          fontSize: 14,
                        )),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildFeatureTable(ColorScheme colorScheme) {
    final rows = [
      ['Daily messages', '200', '500', '1,000'],
      ['Anonymous msgs/week', '3', '10', 'Unlimited'],
      ['Groups', '❌', '1', '2'],
      ['Custom themes', '❌', '✅', '✅'],
      ['Message encryption', '✅', '✅', '✅'],
      ['Priority support', '❌', '✅', '✅'],
    ];

    final headers = ['Feature', 'Free', 'Plus', 'Pro'];
    final headerColors = [
      Colors.transparent,
      const Color(0xFF6366F1),
      const Color(0xFF6366F1),
      const Color(0xFFFF6B35),
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: colorScheme.outlineVariant.withOpacity(0.4)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header row
          Container(
            color: colorScheme.surfaceContainerHighest,
            child: Row(
              children: headers.asMap().entries.map((e) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 8),
                    child: Text(
                      e.value,
                      textAlign: e.key == 0
                          ? TextAlign.left
                          : TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: e.key == 0
                            ? colorScheme.onSurface
                            : Colors.white,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Data rows
          ...rows.asMap().entries.map((rowEntry) {
            final isEven = rowEntry.key % 2 == 0;
            return Container(
              color: isEven
                  ? Colors.transparent
                  : colorScheme.surfaceContainerHighest.withOpacity(0.3),
              child: Row(
                children: rowEntry.value.asMap().entries.map((cellEntry) {
                  final isSelected = (cellEntry.key == 1 &&
                          _selectedTier == 0) ||
                      (cellEntry.key == 2 && _selectedTier == 1) ||
                      (cellEntry.key == 3 && _selectedTier == 2);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 8),
                      child: Container(
                        decoration: isSelected && cellEntry.key > 0
                            ? BoxDecoration(
                                color: headerColors[cellEntry.key]
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              )
                            : null,
                        padding: isSelected && cellEntry.key > 0
                            ? const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 4)
                            : null,
                        child: Text(
                          cellEntry.value,
                          textAlign: cellEntry.key == 0
                              ? TextAlign.left
                              : TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected && cellEntry.key > 0
                                ? headerColors[cellEntry.key]
                                : colorScheme.onSurface
                                    .withOpacity(0.75),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _handleSubscribe(BuildContext context, SubscriptionProvider sub) {
    final tierName = _selectedTier == 1 ? 'Plus' : 'Pro';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.workspace_premium_rounded,
                color: _selectedTier == 2
                    ? const Color(0xFFFF6B35)
                    : const Color(0xFF6366F1)),
            const SizedBox(width: 8),
            Text('Chatly $tierName'),
          ],
        ),
        content: Text(
            'Payment integration coming soon!\n\nChatly $tierName at ₹${_selectedTier == 1 ? 199 : 299}/year will be available when we launch the full app.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Got it')),
        ],
      ),
    );
  }
}

class _PlanData {
  final String name;
  final String price;
  final String period;
  final Color color;
  final List<String> features;
  final String? badge;
  _PlanData({
    required this.name,
    required this.price,
    required this.period,
    required this.color,
    required this.features,
    this.badge,
  });
}
