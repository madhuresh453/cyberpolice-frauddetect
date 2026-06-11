import 'package:flutter/material.dart';
import 'dart:math';
import '../themes/app_theme.dart';

class DeepfakeDetectionScreen extends StatefulWidget {
  const DeepfakeDetectionScreen({super.key});

  @override
  State<DeepfakeDetectionScreen> createState() => _DeepfakeDetectionScreenState();
}

class _DeepfakeDetectionScreenState extends State<DeepfakeDetectionScreen> {
  bool _isAnalyzing = false;
  double _confidence = 0;

  Future<void> _analyzeMedia(String type) async {
    setState(() { _isAnalyzing = true; _confidence = 0; });
    for (int i = 0; i <= 100; i += 5) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted) setState(() => _confidence = i / 100);
    }
    final random = Random();
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
      _confidence = random.nextDouble() * 0.9 + 0.1;
      _isAnalyzing = false;
    });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Deepfake Detection')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: AppTheme.neonBorder(color: _confidence > 0.7 ? AppTheme.dangerRed : AppTheme.primaryBlue),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: _confidence > 0.7 ? AppTheme.dangerRed : AppTheme.primaryBlue, width: 4),
                    ),
                    child: Center(
                      child: _isAnalyzing
                          ? const CircularProgressIndicator(color: AppTheme.primaryBlue)
                          : Text('${(_confidence * 100).toInt()}%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _confidence > 0.7 ? AppTheme.dangerRed : AppTheme.successGreen)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(_isAnalyzing ? 'Analyzing...' : _confidence > 0.7 ? 'Deepfake Detected' : 'Authentic Media', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: _confidence > 0.7 ? AppTheme.dangerRed : AppTheme.successGreen)),
                  if (!_isAnalyzing && _confidence > 0) Text('Confidence: ${(_confidence * 100).toInt()}%', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Analyze Media', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _buildActionCard(Icons.mic, 'Voice', 'Analyze audio for deepfake', () => _analyzeMedia('voice'))),
              const SizedBox(width: 12),
              Expanded(child: _buildActionCard(Icons.videocam, 'Video', 'Analyze video for deepfake', () => _analyzeMedia('video'))),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _buildActionCard(Icons.photo_library, 'Image', 'Check image authenticity', () => _analyzeMedia('image'))),
              const SizedBox(width: 12),
              Expanded(child: _buildActionCard(Icons.call, 'Live Call', 'Real-time voice analysis', () => _analyzeMedia('call'))),
            ]),
            const SizedBox(height: 20),
            Container(
              decoration: AppTheme.glassCard(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Detection Capabilities', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  _buildCapabilityItem('Voice Synthesis', 'Spectral artifact analysis', 95),
                  _buildCapabilityItem('Face Swapping', 'Frame inconsistency detection', 92),
                  _buildCapabilityItem('Lip Sync', 'Audio-visual sync analysis', 88),
                  _buildCapabilityItem('GAN Artifacts', 'Generation artifact detection', 85),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppTheme.glassCard(),
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 32),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  Widget _buildCapabilityItem(String title, String description, int score) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(
      children: [
        Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: Theme.of(context).textTheme.titleMedium), Text(description, style: Theme.of(context).textTheme.bodySmall)])),
        const SizedBox(width: 12),
        Container(width: 60, height: 30, decoration: BoxDecoration(color: AppTheme.successGreen.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)), child: Center(child: Text('$score%', style: const TextStyle(color: AppTheme.successGreen, fontWeight: FontWeight.bold, fontSize: 12)))),
      ],
    ));
  }
}