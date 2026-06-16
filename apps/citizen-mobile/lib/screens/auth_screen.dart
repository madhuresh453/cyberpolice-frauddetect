import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

/// RAKSAAR Auth Screen — Login, Register, OTP
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});
  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();
  
  AuthMode _mode = AuthMode.login;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final theme = Theme.of(context);

    // Navigate based on auth status
    if (auth.status == AuthStatus.authenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      });
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.colorScheme.primary.withValues(alpha: 0.15), theme.colorScheme.surface],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  // Logo
                  Icon(Icons.shield, size: 72, color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text('RAKSAAR', textAlign: TextAlign.center, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 8),
                  Text('CyberShield AI', textAlign: TextAlign.center, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary)),
                  const SizedBox(height: 40),

                  // Auth mode tabs
                  SegmentedButton<AuthMode>(
                    segments: const [
                      ButtonSegment(value: AuthMode.login, label: Text('Login')),
                      ButtonSegment(value: AuthMode.register, label: Text('Register')),
                      ButtonSegment(value: AuthMode.otpLogin, label: Text('OTP')),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (v) => setState(() => _mode = v.first),
                  ),
                  const SizedBox(height: 24),

                  // Login form
                  if (_mode == AuthMode.login) ...[
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                      validator: (v) => v?.contains('@') != true ? 'Enter valid email' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outlined)),
                    ),
                    const SizedBox(height: 8),
                    TextButton(onPressed: () => setState(() => _mode = AuthMode.forgotPassword), child: const Text('Forgot Password?')),
                  ],

                  // Register form
                  if (_mode == AuthMode.register) ...[
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outlined)),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined)),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outlined)),
                    ),
                  ],

                  // OTP form
                  if (_mode == AuthMode.otpLogin) ...[
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_outlined)),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'OTP Code', prefixIcon: Icon(Icons.pin_outlined)),
                    ),
                  ],

                  // Forgot password
                  if (_mode == AuthMode.forgotPassword) ...[
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Error message
                  if (auth.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(auth.error!, style: TextStyle(color: theme.colorScheme.error, fontSize: 13)),
                    ),

                  // Submit button
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: auth.status == AuthStatus.loading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: auth.status == AuthStatus.loading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(_getButtonText(), style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text('A Government of India Initiative', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getButtonText() {
    switch (_mode) {
      case AuthMode.login: return 'Login';
      case AuthMode.register: return 'Create Account';
      case AuthMode.otpLogin: return 'Send OTP';
      case AuthMode.phoneLogin: return 'Login with Phone';
      case AuthMode.forgotPassword: return 'Reset Password';
      case AuthMode.resetPassword: return 'Set New Password';
      case AuthMode.mfaSetup: return 'Setup MFA';
    }
  }

  void _handleSubmit() {
    final auth = ref.read(authProvider.notifier);
    switch (_mode) {
      case AuthMode.login:
        auth.login(email: _emailController.text, password: _passwordController.text);
        break;
      case AuthMode.register:
        auth.register(
          email: _emailController.text,
          password: _passwordController.text,
          fullName: _nameController.text,
          phoneNumber: _phoneController.text,
        );
        break;
      case AuthMode.otpLogin:
        if (_otpController.text.isEmpty) {
          auth.sendOtp(phoneNumber: _phoneController.text);
        } else {
          auth.verifyOtp(phoneNumber: _phoneController.text, otp: _otpController.text);
        }
        break;
      default:
        break;
    }
  }
}

enum AuthMode { login, register, otpLogin, phoneLogin, forgotPassword, resetPassword, mfaSetup }