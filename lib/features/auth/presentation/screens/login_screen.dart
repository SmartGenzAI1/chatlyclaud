// ============================================================================
// FILE: lib/features/auth/presentation/screens/login_screen.dart
// PURPOSE: User login screen
// ============================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/common/custom_button.dart';
import '../../../../core/widgets/common/custom_textfield.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../router/app_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                
                // Logo
                const Icon(
                  Icons.chat_bubble_rounded,
                  size: 80,
                  color: Colors.blue,
                ),
                
                const SizedBox(height: 24),
                
                // Title
                Text(
                  'Welcome Back!',
                  style: Theme.of(context).textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 48),
                
                // Email field
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email),
                  validator: Validators.validateEmail,
                ),
                
                const SizedBox(height: 16),
                
                // Password field
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 8),
                
                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      AppRouter.navigateTo(context, AppRouter.forgotPassword);
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Error message
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
                
                // Login button
                CustomButton(
                  text: 'Login',
                  onPressed: _handleLogin,
                  isLoading: authProvider.isLoading,
                  width: double.infinity,
                ),
                
                const SizedBox(height: 24),
                
                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    TextButton(
                      onPressed: () {
                        AppRouter.navigateAndReplace(context, AppRouter.signup);
                      },
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.signIn(
      _emailController.text.trim(),
      _passwordController.text,
    );
    
    if (success && mounted) {
      AppRouter.navigateAndRemoveUntil(context, AppRouter.home);
    }
  }
}
