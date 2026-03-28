import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../core/theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // Logo / Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryOrange.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.question_mark_rounded,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // App Name
              Text(
                'AskMe',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppTheme.primaryOrange,
                  fontSize: 48,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Tagline
              Text(
                'Ask anything, learn everything',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              
              const Spacer(),
              
              // Sign In Buttons
              _SignInButton(
                icon: Icons.g_mobiledata,
                label: 'Continue with Google',
                color: Colors.white,
                textColor: Colors.black87,
                onPressed: () => _signInWithGoogle(context),
              ),
              
              const SizedBox(height: 16),
              
              _SignInButton(
                icon: Icons.apple,
                label: 'Continue with Apple',
                color: Colors.black,
                textColor: Colors.white,
                onPressed: () => _signInWithApple(context),
              ),
              
              const SizedBox(height: 48),
              
              // Footer
              Text(
                'By continuing, you agree to our Terms of Service',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    final authService = context.read<AuthService>();
    final user = await authService.signInWithGoogle();
    if (user == null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google sign in failed. Please try again.')),
      );
    }
  }

  Future<void> _signInWithApple(BuildContext context) async {
    final authService = context.read<AuthService>();
    final user = await authService.signInWithApple();
    if (user == null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Apple sign in failed. Please try again.')),
      );
    }
  }
}

class _SignInButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;

  const _SignInButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: textColor),
        label: Text(
          label,
          style: TextStyle(color: textColor, fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
