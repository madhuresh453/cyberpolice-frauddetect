import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../themes/app_theme.dart';
import '../widgets/cyber_widgets.dart';

/// Live Call Analysis Screen - real-time voice monitoring during calls
class LiveCallAnalysisScreen extends ConsumerStatefulWidget {
  final String? phoneNumber;

  const LiveCallAnalysisScreen({super.key, this.phoneNumber});

  @override
  ConsumerState<LiveCallAnalysisScreen> createState() => _LiveCallAnalysisScreenState();
}

class _LiveCallAnalysisScreenState extends ConsumerState<LiveCallAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<String> _transcriptLines = [];
  int _riskScore = 15;
  bool _isAnalyzing = true;

  // Scam keywords that trigger alerts
  final List<String> _scamKeywords = [
    'OTP', 'KYC', 'Bank Account', 'UPI', 'Remote Access', 'AnyDesk',
    'ATM Card', 'Credit Card', 'Aadhaar', 'PAN Card', 'Net Banking',
    'Online Transaction', 'Customer Care', 'Refund', 'Loan Approval',
    'Prize Money', 'Gift Voucher', 'Free Offer',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _simulateCallAnalysis();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _simulateCallAnalysis() async {
    final simulatedTranscript = [
      'Hello, this is Ravi from customer support.',
      'I am calling regarding your bank account.',
      'We detected some suspicious activity on your account.',
      'To secure your account, please share your OTP.',
      'You need to verify your KYC immediately.',
      'Please install AnyDesk for remote assistance.',
      'Share your UPI PIN to reverse the transaction.',
      'I am from the cyber crime department.',
      'Your Aadhaar has been used for fraud.',
      'Please transfer money to this safe account.',
    ];

    for (int i = 0; i < simulatedTranscript.length; i++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 1200));

      final line = simulatedTranscript[i];
      setState(() {
        _transcriptLines.add(line);
        _riskScore = _calculateRisk(line, _riskScore);
      });

      // Check if any scam keyword is detected
      final matchedKeyword = _scamKeywords.firstWhere(
        (keyword) => line.toLowerCase().contains(keyword.toLowerCase()),
        orElse: () => '',
      );

      if (matchedKeyword.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _transcriptLines[_transcriptLines.length - 1] =
              '⚠️ $line (Scam Keyword: $matchedKeyword)';
        });

        // Trigger alert if risk is very high
        if (_riskScore >= 80) {
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            _showHighRiskAlert();
          }
        }
      }
    }

    if (mounted) {
      setState(() => _isAnalyzing = false);
    }
  }

  int _calculateRisk(String text, int currentScore) {
    int newScore = currentScore;
    for (final keyword in _scamKeywords) {
      if (text.toLowerCase().contains(keyword.toLowerCase())) {
        newScore += 15;
      }
    }

    // Urgency words increase risk
    if (text.toLowerCase().contains('urgent') ||
        text.toLowerCase().contains('immediately') ||
        text.toLowerCase().contains('action required')) {
      newScore += 10;
    }

    // Authority claims increase risk
    if (text.toLowerCase().contains('police') ||
        text.toLowerCase().contains('government') ||
        text.toLowerCase().contains('officer')) {
      newScore += 10;
    }

    return newScore.clamp(0, 100);
  }

  void _showHighRiskAlert() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.dangerRed, width: 2),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.dangerRed.withValues(alpha: 0.1),
              ),
              child: const Icon(Icons.warning_rounded, size: 48, color: AppTheme.dangerRed),
            ),
            const SizedBox(height: 20),
            const Text(
              'HIGH RISK CALL DETECTED',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.dangerRed,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Scam keywords detected in conversation. This appears to be a fraud call.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.dangerRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('End Call'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.warningOrange,
                      side: const BorderSide(color: AppTheme.warningOrange),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Continue Monitoring'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color get _riskColor {
    if (_riskScore < 25) return AppTheme.successGreen;
    if (_riskScore < 50) return AppTheme.warningOrange;
    return AppTheme.dangerRed;
  }

  String get _riskLabel {
    if (_riskScore < 25) return 'Safe';
    if (_riskScore < 50) return 'Suspicious';
    if (_riskScore < 75) return 'Risky';
    return 'DANGER';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with risk meter
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.cardBackground,
                    _riskColor.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border(
                  bottom: BorderSide(color: _riskColor.withValues(alpha: 0.3)),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.cardBackground,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.dangerRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.dangerRed.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.dangerRed,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'RECORDING',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.dangerRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        widget.phoneNumber ?? '+91 XXXXX XXXXX',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Risk meter
                  Row(
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: CircularProgressIndicator(
                                value: _riskScore / 100,
                                strokeWidth: 8,
                                backgroundColor: AppTheme.borderColor,
                                valueColor: AlwaysStoppedAnimation<Color>(_riskColor),
                              ),
                            ),
                            Text(
                              '$_riskScore',
                              style: GoogleFonts.inter(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _riskColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Risk Score',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _riskLabel,
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: _riskColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_scamKeywords.length} keywords monitored',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Scam keywords bar
                  SizedBox(
                    height: 28,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: _scamKeywords.take(8).map((keyword) {
                        return Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.dangerRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.dangerRed.withValues(alpha: 0.2)),
                          ),
                          child: Text(
                            keyword,
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.dangerRed,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Call transcript
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _transcriptLines.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Live Transcript',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    );
                  }

                  final line = _transcriptLines[index - 1];
                  final isScamDetected = line.startsWith('⚠️');

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isScamDetected
                          ? AppTheme.dangerRed.withValues(alpha: 0.08)
                          : AppTheme.cardBackground,
                      borderRadius: BorderRadius.circular(10),
                      border: isScamDetected
                          ? Border.all(color: AppTheme.dangerRed.withValues(alpha: 0.3))
                          : null,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isScamDetected
                                ? AppTheme.dangerRed.withValues(alpha: 0.2)
                                : AppTheme.primaryBlue.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              '$index',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isScamDetected ? AppTheme.dangerRed : AppTheme.primaryBlue,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            line.replaceAll('⚠️ ', ''),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: isScamDetected ? AppTheme.dangerRed : Colors.white,
                              height: 1.3,
                            ),
                          ),
                        ),
                        if (isScamDetected)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.dangerRed.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'SCAM',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.dangerRed,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                border: Border(
                  top: BorderSide(color: AppTheme.borderColor.withValues(alpha: 0.3)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CyberButton(
                      label: 'Block & End',
                      icon: Icons.block,
                      color: AppTheme.dangerRed,
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CyberButton(
                      label: _isAnalyzing ? 'Analyzing...' : 'Report',
                      icon: Icons.report,
                      color: AppTheme.warningOrange,
                      onPressed: _isAnalyzing ? null : () => context.push('/report'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}