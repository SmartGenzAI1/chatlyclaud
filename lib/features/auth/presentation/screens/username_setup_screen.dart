// ============================================================================
// FILE: lib/features/auth/presentation/screens/username_setup_screen.dart
// PURPOSE: Username setup after registration
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/common/custom_button.dart';
import '../../../../core/widgets/common/custom_textfield.dart';
import '../../../../core/utils/validators.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../router/app_router.dart';

class UsernameSetupScreen extends StatefulWidget {
  const UsernameSetupScreen({super.key});

  @override
  State<UsernameSetupScreen> createState() => _UsernameSetupScreenState();
}

class _UsernameSetupScreenState extends State<UsernameSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  
  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Choose Your Username',
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  'This will be how other users find you',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                CustomTextField(
                  controller: _usernameController,
                  label: 'Username',
                  prefixIcon: const Icon(Icons.alternate_email),
                  validator: Validators.validateUsername,
                ),
                
                const SizedBox(height: 24),
                
                if (authProvider.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      authProvider.error!,
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),
                
                CustomButton(
                  text: 'Continue',
                  onPressed: _handleContinue,
                  isLoading: authProvider.isLoading,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.updateUsername(_usernameController.text.trim());
    
    if (success && mounted) {
      AppRouter.navigateAndRemoveUntil(context, AppRouter.home);
    }
  }
}
