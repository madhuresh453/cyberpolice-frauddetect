import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../themes/app_theme.dart';
import '../providers/auth_provider.dart';

/// Authentication modes supported
enum AuthMode {
  login,
  register,
  otpLogin,
  phoneLogin,
  forgotPassword,
  resetPassword,
  mfaSetup,
  mfaVerify,
}

/// Provider-based authentication screen with multiple auth methods
class AuthScreen extends ConsumerStatefulWidget {
  final String? initialMode;
  const AuthScreen({super.key, this.initialMode});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  AuthMode _mode = AuthMode.login;

  // Controllers
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _otpController = TextEditingController();
  final _mfaCodeController = TextEditingController();
  final _recoveryCodeController = TextEditingController();

  // State
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;
  bool _rememberDevice = false;
  String _otpSentTo = '';
  bool _isOtpSent = false;
  int _otpCountdown = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialMode != null) {
      switch (widget.initialMode) {
        case 'register':
          _mode = AuthMode.register;
          break;
        case 'otp':
          _mode = AuthMode.otpLogin;
          break;
        case 'phone':
          _mode = AuthMode.phoneLogin;
          break;
        case 'forgot':
          _mode = AuthMode.forgotPassword;
          break;
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    _otpController.dispose();
    _mfaCodeController.dispose();
    _recoveryCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final loading = authState.status == AuthStatus.loading;
    final error = authState.error;

    // Navigate on successful auth
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.mfaRequired && mounted) {
        setState(() => _mode = AuthMode.mfaVerify);
      }
      if (next.status == AuthStatus.authenticated && mounted) {
        if (_rememberDevice) {
          ref.read(authProvider.notifier).rememberDevice();
        }
        context.go('/home');
      }
      if (next.status == AuthStatus.otpSent && mounted) {
        setState(() {
          _isOtpSent = true;
          _otpCountdown = 30;
          _otpSentTo = _phoneController.text;
        });
      }
      if (next.status == AuthStatus.passwordReset && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset instructions sent')),
        );
        setState(() => _mode = AuthMode.login);
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
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 32),
              if (error != null) _buildErrorBanner(error),
              const SizedBox(height: 16),
              _buildAuthForm(loading),
              const SizedBox(height: 16),
              _buildDivider(),
              const SizedBox(height: 16),
              _buildSocialLogins(loading),
              const SizedBox(height: 16),
              _buildBottomLinks(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryBlue.withValues(alpha: 0.2),
                AppTheme.primaryBlue.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: const Icon(Icons.shield_outlined, size: 40, color: AppTheme.primaryBlue),
        ),
        const SizedBox(height: 16),
        Text(
          _getTitle(),
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        Text(
          _getSubtitle(),
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getTitle() {
    switch (_mode) {
      case AuthMode.login:
        return 'Welcome Back';
      case AuthMode.register:
        return 'Create Account';
      case AuthMode.otpLogin:
        return 'OTP Login';
      case AuthMode.phoneLogin:
        return 'Phone Login';
      case AuthMode.forgotPassword:
        return 'Forgot Password';
      case AuthMode.resetPassword:
        return 'Reset Password';
      case AuthMode.mfaSetup:
        return 'Setup MFA';
      case AuthMode.mfaVerify:
        return 'Verify MFA';
    }
  }

  String _getSubtitle() {
    switch (_mode) {
      case AuthMode.login:
        return 'Sign in to your CYBERSHIELD account';
      case AuthMode.register:
        return 'Register for complete fraud protection';
      case AuthMode.otpLogin:
        return 'Enter OTP sent to your registered phone';
      case AuthMode.phoneLogin:
        return 'Login using your phone number';
      case AuthMode.forgotPassword:
        return 'Enter your email to reset password';
      case AuthMode.resetPassword:
        return 'Enter your new password';
      case AuthMode.mfaSetup:
        return 'Scan the QR code with your authenticator app';
      case AuthMode.mfaVerify:
        return 'Enter the code from your authenticator app';
    }
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.dangerRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dangerRed.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.dangerRed, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(color: AppTheme.dangerRed, fontSize: 13),
            ),
          ),
          GestureDetector(
            onTap: () => ref.read(authProvider.notifier).clearError(),
            child: const Icon(Icons.close, color: AppTheme.dangerRed, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthForm(bool loading) {
    switch (_mode) {
      case AuthMode.login:
        return _buildLoginForm(loading);
      case AuthMode.register:
        return _buildRegisterForm(loading);
      case AuthMode.otpLogin:
        return _buildOtpForm(loading);
      case AuthMode.phoneLogin:
        return _buildPhoneLoginForm(loading);
      case AuthMode.forgotPassword:
        return _buildForgotPasswordForm(loading);
      case AuthMode.resetPassword:
        return _buildResetPasswordForm(loading);
      case AuthMode.mfaSetup:
        return _buildMfaSetup(loading);
      case AuthMode.mfaVerify:
        return _buildMfaVerify(loading);
    }
  }

  Widget _buildLoginForm(bool loading) {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onSubmitted: loading ? null : (_) => _handleLogin(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _rememberDevice,
                    onChanged: (v) => setState(() => _rememberDevice = v ?? false),
                    fillColor: WidgetStateProperty.resolveWith(
                      (states) => states.contains(WidgetState.selected)
                          ? AppTheme.primaryBlue
                          : AppTheme.borderColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('Remember me', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
            TextButton(
              onPressed: () => setState(() => _mode = AuthMode.forgotPassword),
              child: const Text('Forgot Password?', style: TextStyle(fontSize: 12, color: AppTheme.primaryBlue)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: loading ? null : _handleLogin,
            child: loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Sign In'),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            _handleBiometricLogin();
          },
          icon: const Icon(Icons.fingerprint, size: 20),
          label: const Text('Use Biometric Login'),
        ),
      ],
    );
  }

  Widget _buildRegisterForm(bool loading) {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            prefixIcon: Icon(Icons.person_outlined),
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmPasswordController,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
          obscureText: _obscureConfirm,
          textInputAction: TextInputAction.done,
          onSubmitted: loading ? null : (_) => _handleRegister(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: _agreedToTerms,
                onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                fillColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? AppTheme.primaryBlue
                      : AppTheme.borderColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'I agree to the Terms of Service and Privacy Policy',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: loading ? null : _handleRegister,
            child: loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Create Account'),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpForm(bool loading) {
    return Column(
      children: [
        if (!_isOtpSent) ...[
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(Icons.phone_outlined),
              hintText: '+91 9876543210',
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: loading ? null : _sendOtp,
              child: loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Send OTP'),
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppTheme.successGreen, size: 18),
                const SizedBox(width: 8),
                Text('OTP sent to $_otpSentTo', style: const TextStyle(color: AppTheme.successGreen, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _otpController,
            decoration: const InputDecoration(
              labelText: 'Enter OTP',
              prefixIcon: Icon(Icons.pin_outlined),
              hintText: '6-digit code',
            ),
            keyboardType: TextInputType.number,
            maxLength: 6,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: _otpCountdown > 0 ? null : _resendOtp,
                child: Text(
                  _otpCountdown > 0 ? 'Resend in ${_otpCountdown}s' : 'Resend OTP',
                  style: TextStyle(
                    color: _otpCountdown > 0 ? AppTheme.textSecondary : AppTheme.primaryBlue,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _isOtpSent = false),
                child: const Text('Change Number', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: loading ? null : _verifyOtp,
              child: loading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Verify & Login'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPhoneLoginForm(bool loading) {
    return Column(
      children: [
        TextField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: Icon(Icons.phone_outlined),
            hintText: '+91 9876543210',
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: loading ? null : _handlePhoneLogin,
            child: loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Send OTP'),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordForm(bool loading) {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: loading ? null : _handleForgotPassword,
            child: loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Send Reset Link'),
          ),
        ),
      ],
    );
  }

  Widget _buildResetPasswordForm(bool loading) {
    return Column(
      children: [
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            labelText: 'New Password',
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          obscureText: _obscurePassword,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmPasswordController,
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
          obscureText: _obscureConfirm,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: loading ? null : _handleResetPassword,
            child: loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Reset Password'),
          ),
        ),
      ],
    );
  }

  Widget _buildMfaSetup(bool loading) {
    final authState = ref.watch(authProvider);
    return Column(
      children: [
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: authState.mfaQrCode != null
                ? Image.memory(authState.mfaQrCode!)
                : const Icon(Icons.qr_code, size: 150, color: Colors.black),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Or enter this code manually:',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            authState.mfaSecret ?? '------',
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 16,
              letterSpacing: 2,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _mfaCodeController,
          decoration: const InputDecoration(
            labelText: 'Verify Code',
            prefixIcon: Icon(Icons.pin),
            hintText: '6-digit code from authenticator',
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: loading ? null : _verifyMfa,
            child: loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Enable MFA'),
          ),
        ),
      ],
    );
  }

  Widget _buildMfaVerify(bool loading) {
    return Column(
      children: [
        TextField(
          controller: _mfaCodeController,
          decoration: const InputDecoration(
            labelText: 'Authentication Code',
            prefixIcon: Icon(Icons.pin),
            hintText: '6-digit code',
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        const SizedBox(height: 8),
        const Text(
          'Or use a recovery code:',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _recoveryCodeController,
          decoration: const InputDecoration(
            labelText: 'Recovery Code',
            prefixIcon: Icon(Icons.key),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: loading ? null : _handleMfaVerify,
            child: loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Verify'),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppTheme.borderColor)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
        ),
        Expanded(child: Divider(color: AppTheme.borderColor)),
      ],
    );
  }

  Widget _buildSocialLogins(bool loading) {
    return Column(
      children: [
        OutlinedButton.icon(
          onPressed: loading ? null : _handleGoogleLogin,
          icon: const Icon(Icons.g_mobiledata, size: 24, color: Colors.white),
          label: const Text('Continue with Google'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: loading ? null : _handlePhoneLogin,
          icon: const Icon(Icons.phone_android, size: 20),
          label: const Text('Continue with Phone'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomLinks() {
    return Column(
      children: [
        if (_mode == AuthMode.login)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account?"),
              TextButton(
                onPressed: () => setState(() => _mode = AuthMode.register),
                child: const Text('Register'),
              ),
            ],
          )
        else if (_mode == AuthMode.register)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Already have an account?'),
              TextButton(
                onPressed: () => setState(() => _mode = AuthMode.login),
                child: const Text('Sign In'),
              ),
            ],
          ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            // Quick login options
            showModalBottomSheet(
              context: context,
              backgroundColor: AppTheme.cardBackground,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.borderColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Quick Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 20),
                      ListTile(
                        leading: const Icon(Icons.fingerprint, color: AppTheme.primaryBlue),
                        title: const Text('Biometric Login'),
                        subtitle: const Text('Use fingerprint or face'),
                        onTap: () {
                          Navigator.pop(context);
                          _handleBiometricLogin();
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.smartphone, color: AppTheme.primaryBlue),
                        title: const Text('OTP Login'),
                        subtitle: const Text('Login via SMS OTP'),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _mode = AuthMode.otpLogin);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.phone, color: AppTheme.primaryBlue),
                        title: const Text('Phone Login'),
                        subtitle: const Text('Login with phone number'),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _mode = AuthMode.phoneLogin);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          child: const Text('More login options'),
        ),
      ],
    );
  }

  // ========== HANDLERS ==========

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty) {
      _showError('Please enter your email');
      return;
    }
    if (_passwordController.text.isEmpty) {
      _showError('Please enter your password');
      return;
    }
    await ref.read(authProvider.notifier).login(
      _emailController.text.trim(),
      _passwordController.text,
    );
  }

  /// Auto-format phone number to E.164 as the user types.
  /// Adds +91 prefix if no + is present (India default).
  void _onPhoneChanged(String value) {
    if (value.isEmpty) return;
    final lastChar = value[value.length - 1];
    // Only auto-format when user is not deleting
    if (RegExp(r'[0-9+]').hasMatch(lastChar) && !value.startsWith('+')) {
      // Auto-format only if they typed enough digits
      final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
      if (digits.length == 10 && !value.contains('+')) {
        _phoneController.value = TextEditingValue(
          text: '+91$digits',
          selection: const TextSelection.collapsed(offset: 13),
        );
      }
    }
  }

  /// Validate email format.
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  /// Validate phone number (at least 10 digits).
  bool _isValidPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length >= 10;
  }

  /// Validate password strength.
  String? _validatePassword(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain an uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain a lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain a number';
    }
    return null;
  }

  /// Normalize phone to E.164 format.
  String _normalizePhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.startsWith('+')) return cleaned;
    if (cleaned.length >= 10) return '+$cleaned';
    return phone;
  }

  Future<void> _handleRegister() async {
    // Validate name
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter your full name');
      return;
    }

    // Validate email
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError('Please enter your email address');
      return;
    }
    if (!_isValidEmail(email)) {
      _showError('Please enter a valid email address');
      return;
    }

    // Validate and auto-format phone
    final rawPhone = _phoneController.text.trim();
    if (rawPhone.isEmpty) {
      _showError('Please enter your phone number');
      return;
    }
    final normalizedPhone = _normalizePhone(rawPhone);
    if (!_isValidPhone(normalizedPhone)) {
      _showError('Please enter a valid phone number (at least 10 digits)');
      return;
    }

    // Validate password
    final password = _passwordController.text;
    final passwordError = _validatePassword(password);
    if (passwordError != null) {
      _showError(passwordError);
      return;
    }

    // Confirm password
    if (password != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }

    // Check terms
    if (!_agreedToTerms) {
      _showError('Please agree to the terms of service and privacy policy');
      return;
    }

    await ref.read(authProvider.notifier).register(
      email,
      normalizedPhone, // Send E.164 formatted number
      password,
      _nameController.text.trim(),
    );
  }

  Future<void> _sendOtp() async {
    if (_phoneController.text.isEmpty) {
      _showError('Please enter your phone number');
      return;
    }
    await ref.read(authProvider.notifier).sendOtp(_phoneController.text.trim());
  }

  Future<void> _resendOtp() async {
    await _sendOtp();
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length < 6) {
      _showError('Please enter the complete OTP');
      return;
    }
    await ref.read(authProvider.notifier).verifyOtp(
      _phoneController.text.trim(),
      _otpController.text.trim(),
    );
  }

  Future<void> _handlePhoneLogin() async {
    if (_phoneController.text.isEmpty) {
      _showError('Please enter your phone number');
      return;
    }
    await ref.read(authProvider.notifier).phoneLogin(_phoneController.text.trim());
  }

  Future<void> _handleGoogleLogin() async {
    await ref.read(authProvider.notifier).googleLogin();
  }

  Future<void> _handleBiometricLogin() async {
    await ref.read(authProvider.notifier).biometricLogin();
  }

  Future<void> _handleForgotPassword() async {
    if (_emailController.text.isEmpty) {
      _showError('Please enter your email');
      return;
    }
    await ref.read(authProvider.notifier).forgotPassword(_emailController.text.trim());
  }

  Future<void> _handleResetPassword() async {
    if (_passwordController.text.length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return;
    }
    // Token should be passed from email link
    await ref.read(authProvider.notifier).resetPassword('', _passwordController.text);
  }

  Future<void> _verifyMfa() async {
    if (_mfaCodeController.text.isEmpty) {
      _showError('Please enter the verification code');
      return;
    }
    await ref.read(authProvider.notifier).verifyMfa(_mfaCodeController.text.trim());
  }

  Future<void> _handleMfaVerify() async {
    final code = _mfaCodeController.text.trim();
    final recoveryCode = _recoveryCodeController.text.trim();
    if (code.isEmpty && recoveryCode.isEmpty) {
      _showError('Please enter a code');
      return;
    }
    await ref.read(authProvider.notifier).verifyMfaLogin(
      code.isNotEmpty ? code : null,
      recoveryCode.isNotEmpty ? recoveryCode : null,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.dangerRed,
      ),
    );
  }
}