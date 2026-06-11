import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../themes/app_theme.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLogin = true;
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final notifier = ref.read(authProvider.notifier);
    if (_isLogin) {
      await notifier.login(_emailController.text.trim(), _passwordController.text);
    } else {
      await notifier.register(
        _emailController.text.trim(),
        _phoneController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final loading = authState.status == AuthStatus.loading;
    final error = authState.error;

    // Navigate on successful auth
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated && mounted) {
        context.go('/home');
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.shield_outlined, size: 60, color: AppTheme.primaryBlue),
              const SizedBox(height: 16),
              Text(_isLogin ? 'Welcome Back' : 'Create Account',
                  style: Theme.of(context).textTheme.displaySmall, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(_isLogin ? 'Sign in to continue' : 'Register for protection',
                  style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
              if (error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppTheme.dangerRed.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [const Icon(Icons.error, color: AppTheme.dangerRed, size: 18), const SizedBox(width: 8), Expanded(child: Text(error, style: const TextStyle(color: AppTheme.dangerRed, fontSize: 13)))]),
                ),
              ],
              const SizedBox(height: 32),
              if (!_isLogin) ...[
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person))),
                const SizedBox(height: 16),
                TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone)), keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
              ],
              TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)), keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)), obscureText: true),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: loading ? null : _submit,
                  child: loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(_isLogin ? 'Sign In' : 'Register'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(_isLogin ? "Don't have an account? Register" : 'Already have an account? Sign In'),
              ),
              const SizedBox(height: 24),
              const Row(children: [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('OR')), Expanded(child: Divider())]),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.fingerprint),
                label: const Text('Use Biometric Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
