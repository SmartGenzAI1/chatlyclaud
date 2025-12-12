// ============================================================================
// FILE: lib/features/auth/presentation/screens/forgot_password_screen.dart
// PURPOSE: Password reset screen
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/common/custom_button.dart';
import '../../../../core/widgets/common/custom_textfield.dart';
import '../../../../core/utils/validators.dart';
import '../../../../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                
                Text(
                  'Enter your email address and we\'ll send you a link to reset your password.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email),
                  validator: Validators.validateEmail,
                ),
                
                const SizedBox(height: 24),
                
                CustomButton(
                  text: 'Send Reset Link',
                  onPressed: _handleResetPassword,
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
  
  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.resetPassword(_emailController.text.trim());
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }
}
