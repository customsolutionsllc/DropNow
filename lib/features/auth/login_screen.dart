import 'package:flutter/material.dart';
import 'package:drop_now/core/constants/constants.dart';
import 'package:drop_now/core/services/auth_service.dart';

/// First-launch login screen: Google, Facebook, or Guest.
class LoginScreen extends StatefulWidget {
  final AuthService authService;
  final VoidCallback onComplete;

  const LoginScreen({
    super.key,
    required this.authService,
    required this.onComplete,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

  Future<void> _signInGoogle() async {
    setState(() => _loading = true);
    final user = await widget.authService.signInWithGoogle();
    if (!mounted) return;
    setState(() => _loading = false);
    if (user != null) {
      widget.onComplete();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google sign-in failed. Try again.')),
      );
    }
  }

  Future<void> _signInFacebook() async {
    setState(() => _loading = true);
    final user = await widget.authService.signInWithFacebook();
    if (!mounted) return;
    setState(() => _loading = false);
    if (user != null) {
      widget.onComplete();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Facebook sign-in failed. Try again.')),
      );
    }
  }

  Future<void> _continueAsGuest() async {
    await widget.authService.markLoginSkipped();
    if (!mounted) return;
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  color: AppColors.accent,
                  size: 40,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Title
              Text(
                'Join the DropNow Squad',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Sign in to sync progress, challenge friends, and track your streak across devices.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 2),

              // Loading indicator
              if (_loading) ...[
                const CircularProgressIndicator(color: AppColors.accent),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Google button
              _SocialButton(
                label: 'Continue with Google',
                icon: Icons.g_mobiledata_rounded,
                color: const Color(0xFF4285F4),
                onPressed: _loading ? null : _signInGoogle,
              ),
              const SizedBox(height: AppSpacing.md),

              // Facebook button
              _SocialButton(
                label: 'Continue with Facebook',
                icon: Icons.facebook_rounded,
                color: const Color(0xFF1877F2),
                onPressed: _loading ? null : _signInFacebook,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Guest
              TextButton(
                onPressed: _loading ? null : _continueAsGuest,
                child: Text(
                  'Continue as Guest',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.textSecondary,
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.withValues(alpha: 0.4),
          disabledForegroundColor: Colors.white54,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
