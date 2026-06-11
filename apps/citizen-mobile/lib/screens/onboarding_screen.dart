import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../themes/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.shield_outlined,
      title: 'Welcome to CyberShield',
      description: 'India\'s most advanced AI-powered fraud protection platform. Real-time detection of scams, deepfakes, and cyber threats.',
      color: AppTheme.primaryBlue,
      features: ['AI Fraud Detection', 'Real-Time Protection', 'Family Safety'],
    ),
    OnboardingPage(
      icon: Icons.phone_in_talk,
      title: 'Call & SMS Protection',
      description: 'Automatically detect scam calls and fraudulent SMS messages. Get instant alerts before you fall victim to fraud.',
      color: AppTheme.successGreen,
      features: ['Live Call Analysis', 'SMS Scanning', 'Spam Blocking'],
    ),
    OnboardingPage(
      icon: Icons.security,
      title: 'Privacy & Security',
      description: 'Your data is encrypted and stored securely. We use bank-grade security to protect your information.',
      color: AppTheme.warningOrange,
      features: ['End-to-End Encryption', 'Secure Storage', 'Privacy First'],
    ),
    OnboardingPage(
      icon: Icons.family_restroom,
      title: 'Protect Your Family',
      description: 'Add family members to your protection network. Get notified when they encounter potential threats.',
      color: const Color(0xFFEC4899),
      features: ['Family Network', 'Shared Alerts', 'Senior Mode'],
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go('/auth'),
                child: Text(
                  _currentPage < _pages.length - 1 ? 'Skip' : '',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ),
            ),
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemCount: _pages.length,
                itemBuilder: (context, index) => _buildPage(_pages[index]),
              ),
            ),
            // Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? AppTheme.primaryBlue : AppTheme.borderColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Action button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      context.go('/auth');
                    }
                  },
                  child: Text(
                    _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: page.color.withValues(alpha: 0.1),
              boxShadow: [
                BoxShadow(
                  color: page.color.withValues(alpha: 0.2),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(page.icon, size: 50, color: page.color),
          ),
          const SizedBox(height: 40),
          // Title
          Text(
            page.title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Features
          ...page.features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        color: page.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.check, color: page.color, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Text(feature, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final List<String> features;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.features,
  });
}