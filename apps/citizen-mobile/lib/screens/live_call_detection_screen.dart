import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../themes/app_theme.dart';
import '../widgets/cyber_widgets.dart';

/// Live Incoming Call Detection Screen - triggered when unknown call arrives
class LiveCallDetectionScreen extends ConsumerStatefulWidget {
  final String? phoneNumber;
  final String? callerName;

  const LiveCallDetectionScreen({
    super.key,
    this.phoneNumber,
    this.callerName,
  });

  @override
  ConsumerState<LiveCallDetectionScreen> createState() => _LiveCallDetectionScreenState();
}

class _LiveCallDetectionScreenState extends ConsumerState<LiveCallDetectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  String _analysisStatus = 'Analyzing caller...';
  double _riskScore = 0;
  bool _analysisComplete = false;
  String? _callerLocation;

  final List<String> _statusMessages = [
    'Checking caller reputation...',
    'Analyzing call patterns...',
    'Scanning fraud databases...',
    'Cross-referencing threat intelligence...',
    'Calculating risk score...',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _simulateAnalysis();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _simulateAnalysis() async {
    for (int i = 0; i < _statusMessages.length; i++) {
      if (!mounted) return;
      setState(() {
        _analysisStatus = _statusMessages[i];
        _riskScore = ((i + 1) / _statusMessages.length) * 100;
      });
      await Future.delayed(const Duration(milliseconds: 600));
    }

    if (!mounted) return;
    // Simulate final result
    final finalScore = 75.0 + (DateTime.now().millisecondsSinceEpoch % 25).toDouble();
    setState(() {
      _riskScore = finalScore.clamp(0, 100);
      _analysisComplete = true;
      _callerLocation = 'Mumbai, Maharashtra';
      _analysisStatus = _riskScore > 50
          ? '⚠️ High Risk Call Detected'
          : '✅ Call appears safe';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Live Detection',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
                        Text(
                          'LIVE',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.dangerRed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Animated call visualization
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Container(
                          width: 160 + (_pulseController.value * 30),
                          height: 160 + (_pulseController.value * 30),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _analysisComplete
                                ? (_riskScore > 50 ? AppTheme.dangerRed : AppTheme.successGreen)
                                    .withValues(alpha: 0.1)
                                : AppTheme.primaryBlue.withValues(alpha: 0.1),
                            boxShadow: [
                              BoxShadow(
                                color: (_analysisComplete
                                        ? (_riskScore > 50 ? AppTheme.dangerRed : AppTheme.successGreen)
                                        : AppTheme.primaryBlue)
                                    .withValues(alpha: 0.1 + (_pulseController.value * 0.2)),
                                blurRadius: 30 + (_pulseController.value * 20),
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _analysisComplete
                                  ? (_riskScore > 50 ? AppTheme.dangerRed : AppTheme.successGreen)
                                      .withValues(alpha: 0.15)
                                  : AppTheme.primaryBlue.withValues(alpha: 0.15),
                              border: Border.all(
                                color: (_analysisComplete
                                        ? (_riskScore > 50 ? AppTheme.dangerRed : AppTheme.successGreen)
                                        : AppTheme.primaryBlue)
                                    .withValues(alpha: 0.5),
                                width: 3,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _analysisComplete
                                      ? (_riskScore > 50 ? Icons.warning_rounded : Icons.check_circle)
                                      : Icons.phone_in_talk,
                                  size: 48,
                                  color: _analysisComplete
                                      ? (_riskScore > 50 ? AppTheme.dangerRed : AppTheme.successGreen)
                                      : AppTheme.primaryBlue,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _analysisComplete
                                      ? '${_riskScore.toInt()}%'
                                      : '...',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _analysisComplete
                                        ? (_riskScore > 50 ? AppTheme.dangerRed : AppTheme.successGreen)
                                        : AppTheme.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Caller info
                    CyberCard(
                      child: Column(
                        children: [
                          Text(
                            widget.phoneNumber ?? '+91 XXXXX XXXXX',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (widget.callerName != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.callerName!,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                          if (_callerLocation != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_on, size: 14, color: AppTheme.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  _callerLocation!,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Status
                    Text(
                      _analysisStatus,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _riskScore > 50 ? AppTheme.dangerRed : AppTheme.successGreen,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    if (!_analysisComplete) ...[
                      const SizedBox(height: 16),
                      const SizedBox(
                        width: 160,
                        child: LinearProgressIndicator(
                          backgroundColor: AppTheme.borderColor,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Action buttons
              if (_analysisComplete) ...[
                Row(
                  children: [
                    Expanded(
                      child: CyberButton(
                        label: 'Block',
                        icon: Icons.block,
                        color: AppTheme.dangerRed,
                        onPressed: () {
                          // Block number
                          context.pop();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CyberButton(
                        label: 'Report',
                        icon: Icons.report,
                        color: AppTheme.warningOrange,
                        onPressed: () {
                          context.push('/report');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CyberButton(
                        label: _riskScore > 50 ? 'End' : 'Answer',
                        icon: _riskScore > 50 ? Icons.call_end : Icons.call,
                        color: _riskScore > 50 ? AppTheme.dangerRed : AppTheme.successGreen,
                        onPressed: () {
                          context.pop();
                        },
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}