// ============================================================================
// FILE: lib/features/auth/presentation/screens/username_setup_screen.dart
// PURPOSE: Premium username selection screen shown after email signup
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/validators.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../router/app_router.dart';

class UsernameSetupScreen extends StatefulWidget {
  const UsernameSetupScreen({super.key});

  @override
  State<UsernameSetupScreen> createState() => _UsernameSetupScreenState();
}

class _UsernameSetupScreenState extends State<UsernameSetupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _ctrl = TextEditingController();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  String _preview = '';
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            slivers: [
              // Hero header
              SliverToBoxAdapter(
                child: Container(
                  height: 250,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1A1A2E),
                        colorScheme.primary,
                        colorScheme.tertiary,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.alternate_email_rounded,
                              color: Colors.white, size: 36),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Choose Your Username',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'How others will find and message you',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Form
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),

                        // Preview card
                        if (_preview.isNotEmpty) ...[
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: colorScheme.primary.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: colorScheme.primary,
                                  child: Text(
                                    _preview[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('@$_preview',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        )),
                                    Text('This is how you\'ll appear',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: colorScheme.onSurface
                                              .withOpacity(0.5),
                                        )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Username field
                        TextFormField(
                          controller: _ctrl,
                          autofocus: true,
                          onChanged: (v) => setState(
                              () => _preview = v.trim().toLowerCase()),
                          decoration: InputDecoration(
                            labelText: 'Username',
                            hintText: 'e.g. cooluser123',
                            prefixText: '@',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14)),
                            helperText:
                                'Letters, numbers, underscores. 3–20 characters.',
                            helperMaxLines: 2,
                          ),
                          textInputAction: TextInputAction.done,
                          validator: Validators.validateUsername,
                        ),

                        const SizedBox(height: 12),

                        // Username rules
                        _buildRuleChips(),

                        const SizedBox(height: 24),

                        // Error
                        if (auth.error != null)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.red, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    auth.error!,
                                    style: TextStyle(color: Colors.red.shade800),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Continue button
                        SizedBox(
                          height: 54,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.tertiary,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: auth.isLoading ? null : _handleContinue,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              child: auth.isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white))
                                  : const Text(
                                      'Set Username & Continue →',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Skip (not recommended)
                        Center(
                          child: TextButton(
                            onPressed: () => AppRouter.navigateAndRemoveUntil(
                                context, AppRouter.home),
                            child: Text(
                              'Skip for now',
                              style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRuleChips() {
    final text = _ctrl.text.trim();
    final rules = [
      _RuleChip(
          '3+ chars', text.length >= 3, Icons.text_fields_rounded),
      _RuleChip(
          'Max 20', text.length <= 20, Icons.check_circle_outline_rounded),
      _RuleChip('No spaces', !text.contains(' '),
          Icons.space_bar_rounded),
    ];
    return Row(
      children: rules
          .map((r) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Chip(
                  avatar: Icon(r.icon,
                      size: 14,
                      color: r.satisfied ? Colors.green : Colors.grey),
                  label: Text(r.label,
                      style: TextStyle(
                        fontSize: 11,
                        color: r.satisfied ? Colors.green : Colors.grey,
                      )),
                  backgroundColor: r.satisfied
                      ? Colors.green.withOpacity(0.08)
                      : Colors.grey.withOpacity(0.08),
                  side: BorderSide(
                      color: r.satisfied
                          ? Colors.green.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.2)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 0),
                  visualDensity: VisualDensity.compact,
                ),
              ))
          .toList(),
    );
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.updateUsername(_ctrl.text.trim());
    if (success && mounted) {
      AppRouter.navigateAndRemoveUntil(context, AppRouter.home);
    }
  }
}

class _RuleChip {
  final String label;
  final bool satisfied;
  final IconData icon;
  const _RuleChip(this.label, this.satisfied, this.icon);
}
