import 'package:flutter/material.dart';
import 'app_theme.dart';

// ============================================================================
// CORE REUSABLE WIDGETS LIBRARY
// ============================================================================

/// CyberShield styled card with glassmorphism
class CyberCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final double borderRadius;

  const CyberCard({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
    this.gradient,
    this.onTap,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient ??
              LinearGradient(
                colors: [
                  AppTheme.cardBg,
                  AppTheme.cardBg.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: (borderColor ?? AppTheme.borderColor).withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: (borderColor ?? AppTheme.cyberBlue).withValues(alpha: 0.08),
              blurRadius: 16,
              spreadRadius: 0,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// Neon glowing button
class CyberButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool loading;
  final bool disabled;
  final VoidCallback? onPressed;
  final double height;
  final double width;

  const CyberButton({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.loading = false,
    this.disabled = false,
    this.onPressed,
    this.height = 52,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? AppTheme.cyberBlue;
    final isEnabled = onPressed != null && !loading && !disabled;
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          disabledBackgroundColor: bgColor.withValues(alpha: 0.3),
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: bgColor.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: loading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
                  Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              ),
      ),
    );
  }
}

/// Risk score meter - circular with color gradient
class RiskMeter extends StatelessWidget {
  final double score;
  final double size;
  final bool showLabel;

  const RiskMeter({super.key, required this.score, this.size = 120, this.showLabel = true});

  Color get color {
    if (score <= 20) return AppTheme.safeGreen;
    if (score <= 40) return AppTheme.warningOrange;
    if (score <= 60) return AppTheme.warningAmber;
    if (score <= 80) return AppTheme.dangerRed;
    return AppTheme.dangerRed2;
  }

  String get label {
    if (score <= 20) return 'Safe';
    if (score <= 40) return 'Low Risk';
    if (score <= 60) return 'Medium Risk';
    if (score <= 80) return 'High Risk';
    return 'Critical';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size, height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(width: size, height: size,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 10,
                  backgroundColor: AppTheme.borderColor,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${score.toInt()}', style: TextStyle(fontSize: size * 0.3, fontWeight: FontWeight.bold, color: color)),
                  if (showLabel) Text('/100', style: TextStyle(fontSize: size * 0.1, color: AppTheme.textSecondary)),
                ],
              ),
            ],
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
        ],
      ],
    );
  }
}

/// Status badge chip
class StatusBadge extends StatelessWidget {
  final String label;
  final Color? color;

  const StatusBadge({super.key, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ??
        (label.toLowerCase().contains('safe') || label.toLowerCase().contains('green')
            ? AppTheme.safeGreen
            : label.toLowerCase().contains('risk') || label.toLowerCase().contains('danger') || label.toLowerCase().contains('red')
                ? AppTheme.dangerRed
                : label.toLowerCase().contains('warn') || label.toLowerCase().contains('orange')
                    ? AppTheme.warningOrange
                    : AppTheme.cyberBlue);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withValues(alpha: 0.3)),
      ),
      child: Text(label.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: c, letterSpacing: 0.5)),
    );
  }
}

/// Animated shield icon
class ShieldIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final bool glow;

  const ShieldIcon({super.key, this.size = 60, this.color, this.glow = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (color ?? AppTheme.cyberBlue).withValues(alpha: 0.1),
        boxShadow: glow
            ? [BoxShadow(color: (color ?? AppTheme.cyberBlue).withValues(alpha: 0.2), blurRadius: 30, spreadRadius: 10)]
            : null,
      ),
      child: Icon(Icons.shield_outlined, size: size * 0.55, color: color ?? AppTheme.cyberBlue),
    );
  }
}

/// Feature row with icon
class FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const FeatureRow({super.key, required this.icon, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: (color ?? AppTheme.cyberBlue).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: color ?? AppTheme.cyberBlue),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary))),
        ],
      ),
    );
  }
}

/// Section header with optional action
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Text(actionLabel!, style: const TextStyle(fontSize: 13, color: AppTheme.cyberBlue, fontWeight: FontWeight.w600)),
          ),
      ],
    );
  }
}

/// Empty state widget
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const EmptyState({super.key, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.cardBg, border: Border.all(color: AppTheme.borderColor)),
            child: Icon(icon, size: 36, color: AppTheme.textDim),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

/// Animated pulse container
class PulseContainer extends StatefulWidget {
  final Widget child;
  final Color color;
  final double size;

  const PulseContainer({super.key, required this.child, this.color = AppTheme.cyberBlue, this.size = 120});

  @override
  State<PulseContainer> createState() => _PulseContainerState();
}

class _PulseContainerState extends State<PulseContainer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.size + (_controller.value * 20),
          height: widget.size + (_controller.value * 20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.1 + (_controller.value * 0.2)),
                blurRadius: 20 + (_controller.value * 20),
                spreadRadius: 5,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Animated processing indicator
class ProcessingIndicator extends StatefulWidget {
  final String message;
  final List<String> steps;
  final int currentStep;

  const ProcessingIndicator({super.key, required this.message, required this.steps, this.currentStep = 0});

  @override
  State<ProcessingIndicator> createState() => _ProcessingIndicatorState();
}

class _ProcessingIndicatorState extends State<ProcessingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.cyberBlue.withValues(alpha: 0.3 + (_controller.value * 0.7)), width: 3),
                boxShadow: [BoxShadow(color: AppTheme.cyberBlue.withValues(alpha: 0.1 * _controller.value), blurRadius: 20 + (_controller.value * 20))],
              ),
              child: const Icon(Icons.psychology_outlined, size: 36, color: AppTheme.cyberBlue),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(widget.message, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
        const SizedBox(height: 16),
        ...widget.steps.asMap().entries.map((entry) {
          final idx = entry.key;
          final step = entry.value;
          final isComplete = idx < widget.currentStep;
          final isCurrent = idx == widget.currentStep;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  isComplete ? Icons.check_circle : isCurrent ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  size: 18,
                  color: isComplete ? AppTheme.safeGreen : isCurrent ? AppTheme.cyberBlue : AppTheme.textDim,
                ),
                const SizedBox(width: 10),
                Text(step, style: TextStyle(
                  fontSize: 13,
                  color: isComplete ? AppTheme.safeGreen : isCurrent ? AppTheme.textPrimary : AppTheme.textDim,
                )),
              ],
            ),
          );
        }),
      ],
    );
  }
}

/// Bottom navigation bar
class CyberBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CyberBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppTheme.darkNavy, border: Border(top: BorderSide(color: AppTheme.borderColor.withValues(alpha: 0.3)))),
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          final isSelected = index == currentIndex;
          return GestureDetector(
            onTap: () => onTap(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon, color: isSelected ? AppTheme.cyberBlue : AppTheme.textDim, size: 22),
                const SizedBox(height: 4),
                Text(item.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isSelected ? AppTheme.cyberBlue : AppTheme.textDim)),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

const List<_NavItem> _items = [
  _NavItem(Icons.home_rounded, 'Home'),
  _NavItem(Icons.shield_rounded, 'Protect'),
  _NavItem(Icons.assessment_rounded, 'Reports'),
  _NavItem(Icons.history_rounded, 'History'),
  _NavItem(Icons.person_rounded, 'Profile'),
];

/// Animated counter
class AnimatedCount extends StatelessWidget {
  final int value;
  final String label;
  final Color? color;

  const AnimatedCount({super.key, required this.value, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$value', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color ?? AppTheme.cyberBlue)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ],
    );
  }
}

/// Dialog helper
class CyberDialog {
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    Color? confirmColor,
    IconData? icon,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: (confirmColor ?? AppTheme.cyberBlue).withValues(alpha: 0.3)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(shape: BoxShape.circle, color: (confirmColor ?? AppTheme.cyberBlue).withValues(alpha: 0.1)),
                child: Icon(icon, size: 30, color: confirmColor ?? AppTheme.cyberBlue),
              ),
              const SizedBox(height: 16),
            ],
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.4), textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(cancelLabel, style: const TextStyle(color: AppTheme.textSecondary))),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor ?? AppTheme.cyberBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}