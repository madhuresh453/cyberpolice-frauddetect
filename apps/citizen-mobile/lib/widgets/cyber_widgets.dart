import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../themes/app_theme.dart';

// ============================================================================
// CORE REUSABLE CYBERSHIELD WIDGETS
// ============================================================================

/// Animated shield icon with glow effect
class CyberShieldIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final bool animate;

  const CyberShieldIcon({
    super.key,
    this.size = 40,
    this.color,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (color ?? AppTheme.primaryBlue).withValues(alpha: 0.15),
        boxShadow: animate
            ? [
                BoxShadow(
                  color: (color ?? AppTheme.primaryBlue).withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ]
            : null,
      ),
      child: Icon(
        Icons.shield_outlined,
        size: size * 0.6,
        color: color ?? AppTheme.primaryBlue,
      ),
    );
  }
}

/// Glowing cyber card with neon border
class CyberCard extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Gradient? gradient;

  const CyberCard({
    super.key,
    required this.child,
    this.borderColor,
    this.borderRadius = 16,
    this.padding,
    this.margin,
    this.onTap,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin ?? EdgeInsets.zero,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient ??
            LinearGradient(
              colors: [
                AppTheme.cardBackground,
                (borderColor ?? AppTheme.primaryBlue).withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: (borderColor ?? AppTheme.primaryBlue).withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (borderColor ?? AppTheme.primaryBlue).withValues(alpha: 0.15),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}

/// Gradient action button with cyber styling
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
    final isEnabled = onPressed != null && !loading && !disabled;
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppTheme.primaryBlue,
          disabledBackgroundColor: (color ?? AppTheme.primaryBlue).withValues(alpha: 0.3),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Outlined cyber button with neon effect
class CyberOutlinedButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? color;
  final bool loading;
  final VoidCallback? onPressed;

  const CyberOutlinedButton({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.loading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: color ?? AppTheme.primaryBlue,
          side: BorderSide(color: color ?? AppTheme.primaryBlue),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(label),
                ],
              ),
      ),
    );
  }
}

/// Cyber text input with glowing focus
class CyberTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;
  final String? hintText;
  final int? maxLength;
  final bool enabled;

  const CyberTextField({
    super.key,
    required this.controller,
    required this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.onSubmitted,
    this.hintText,
    this.maxLength,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      enabled: enabled,
      maxLength: maxLength,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppTheme.cardBackground,
        counterStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.dangerRed),
        ),
        labelStyle: const TextStyle(color: AppTheme.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

/// Animated risk meter (0-100) with color gradient
class RiskMeter extends StatelessWidget {
  final double score;
  final double size;
  final bool showLabel;

  const RiskMeter({
    super.key,
    required this.score,
    this.size = 120,
    this.showLabel = true,
  });

  Color get _color {
    if (score < 20) return AppTheme.successGreen;
    if (score < 50) return AppTheme.warningOrange;
    return AppTheme.dangerRed;
  }

  String get _label {
    if (score < 20) return 'Safe';
    if (score < 50) return 'Low Risk';
    if (score < 80) return 'Medium Risk';
    return 'High Risk';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 10,
                  backgroundColor: AppTheme.borderColor,
                  valueColor: AlwaysStoppedAnimation<Color>(_color),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${score.toInt()}',
                    style: TextStyle(
                      fontSize: size * 0.3,
                      fontWeight: FontWeight.bold,
                      color: _color,
                    ),
                  ),
                  if (showLabel)
                    Text(
                      _label,
                      style: TextStyle(
                        fontSize: size * 0.1,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Animated processing indicator for AI analysis
class AiAnalysisIndicator extends StatefulWidget {
  final String statusMessage;

  const AiAnalysisIndicator({
    super.key,
    this.statusMessage = 'Analyzing...',
  });

  @override
  State<AiAnalysisIndicator> createState() => _AiAnalysisIndicatorState();
}

class _AiAnalysisIndicatorState extends State<AiAnalysisIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryBlue.withValues(
                    alpha: 0.3 + (_controller.value * 0.7),
                  ),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(
                      alpha: 0.1 * _controller.value,
                    ),
                    blurRadius: 20 + (_controller.value * 20),
                  ),
                ],
              ),
              child: const Icon(
                Icons.psychology_outlined,
                size: 36,
                color: AppTheme.primaryBlue,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        Text(
          widget.statusMessage,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        const SizedBox(
          width: 120,
          child: LinearProgressIndicator(
            backgroundColor: AppTheme.borderColor,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
          ),
        ),
      ],
    );
  }
}

/// Status badge with color coded severity
class StatusBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.label,
    this.color,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ??
        (label.toLowerCase().contains('safe') || label.toLowerCase().contains('active')
            ? AppTheme.successGreen
            : label.toLowerCase().contains('risk') || label.toLowerCase().contains('danger')
                ? AppTheme.dangerRed
                : label.toLowerCase().contains('warn') || label.toLowerCase().contains('medium')
                    ? AppTheme.warningOrange
                    : AppTheme.primaryBlue);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          color: c,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Quick action tile for home dashboard
class QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final String? subtitle;

  const QuickActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Empty state widget with illustration
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.cardBackground,
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Icon(icon, size: 36, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              CyberButton(
                label: actionLabel!,
                icon: Icons.add,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading shimmer for cards
class CyberShimmer extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;

  const CyberShimmer({
    super.key,
    this.height = 100,
    this.width = double.infinity,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.cardBackground,
      highlightColor: AppTheme.borderColor,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Section header with optional action
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? actionIcon;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Row(
              children: [
                if (actionIcon != null) ...[
                  Icon(actionIcon, size: 14, color: AppTheme.primaryBlue),
                  const SizedBox(width: 4),
                ],
                Text(
                  actionLabel!,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Info row with label and value
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final IconData? icon;
  final Widget? trailing;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon!, size: 16, color: AppTheme.textSecondary),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const Spacer(),
          if (trailing != null)
            trailing!
          else
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}

/// Cyber dialog with glow effect
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
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: (confirmColor ?? AppTheme.primaryBlue).withValues(alpha: 0.3),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (confirmColor ?? AppTheme.primaryBlue).withValues(alpha: 0.1),
                ),
                child: Icon(icon, size: 30, color: confirmColor ?? AppTheme.primaryBlue),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              cancelLabel,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}

/// Animated shield pulse for protection status
class ShieldStatusWidget extends StatefulWidget {
  final bool isProtected;
  final double size;

  const ShieldStatusWidget({
    super.key,
    this.isProtected = true,
    this.size = 100,
  });

  @override
  State<ShieldStatusWidget> createState() => _ShieldStatusWidgetState();
}

class _ShieldStatusWidgetState extends State<ShieldStatusWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
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
                color: (widget.isProtected ? AppTheme.successGreen : AppTheme.dangerRed)
                    .withValues(alpha: 0.2 * _controller.value),
                blurRadius: 20 + (_controller.value * 20),
                spreadRadius: 5,
              ),
            ],
          ),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isProtected
                  ? AppTheme.successGreen.withValues(alpha: 0.15)
                  : AppTheme.dangerRed.withValues(alpha: 0.15),
              border: Border.all(
                color: widget.isProtected
                    ? AppTheme.successGreen.withValues(alpha: 0.5)
                    : AppTheme.dangerRed.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Icon(
              widget.isProtected ? Icons.shield : Icons.shield_outlined,
              size: widget.size * 0.5,
              color: widget.isProtected ? AppTheme.successGreen : AppTheme.dangerRed,
            ),
          ),
        );
      },
    );
  }
}

/// Threat level indicator bar
class ThreatLevelBar extends StatelessWidget {
  final double level; // 0-100

  const ThreatLevelBar({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 6,
            child: Row(
              children: [
                Expanded(
                  flex: 33,
                  child: Container(
                    color: level <= 33
                        ? AppTheme.successGreen.withValues(alpha: 0.8)
                        : AppTheme.successGreen.withValues(alpha: 0.2),
                  ),
                ),
                Expanded(
                  flex: 33,
                  child: Container(
                    color: level > 33 && level <= 66
                        ? AppTheme.warningOrange.withValues(alpha: 0.8)
                        : AppTheme.warningOrange.withValues(alpha: 0.2),
                  ),
                ),
                Expanded(
                  flex: 34,
                  child: Container(
                    color: level > 66
                        ? AppTheme.dangerRed
                        : AppTheme.dangerRed.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Safe', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
            Text('Moderate', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
            Text('Critical', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          ],
        ),
      ],
    );
  }
}

/// Animated counter widget
class AnimatedCounter extends StatelessWidget {
  final int value;
  final String label;
  final Color? color;
  final double fontSize;

  const AnimatedCounter({
    super.key,
    required this.value,
    required this.label,
    this.color,
    this.fontSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formatCount(value),
          style: GoogleFonts.inter(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: color ?? AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  String formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

/// Horizontal scrollable action row for dashboard
class ActionRow extends StatelessWidget {
  final List<_ActionItem> actions;

  const ActionRow({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final action = actions[index];
          return GestureDetector(
            onTap: action.onTap,
            child: Container(
              width: 72,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: action.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: action.color.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(action.icon, color: action.color, size: 24),
                  const SizedBox(height: 6),
                  Text(
                    action.label,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: action.color,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

/// Helper to create action items
ActionItem createAction({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return ActionItem(icon: icon, label: label, color: color, onTap: onTap);
}

class ActionItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  ActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

/// Cyber switch with neon styling
class CyberSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  final String? subtitle;

  const CyberSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primaryBlue,
            activeTrackColor: AppTheme.primaryBlue.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

/// Animated typing indicator for AI chatbot
class AiTypingIndicator extends StatefulWidget {
  const AiTypingIndicator({super.key});

  @override
  State<AiTypingIndicator> createState() => _AiTypingIndicatorState();
}

class _AiTypingIndicatorState extends State<AiTypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryBlue.withValues(
                    alpha: 0.3 + (_controller.value * 0.7),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// Loading overlay for full-screen loading states
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final bool visible;

  const LoadingOverlay({
    super.key,
    this.message,
    this.visible = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Container(
      color: Colors.black54,
      child: Center(
        child: CyberCard(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  color: AppTheme.primaryBlue,
                  strokeWidth: 3,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Return to safe area bottom nav wrapper
class BottomNavWrapper extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavWrapper({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        border: Border(
          top: BorderSide(
            color: AppTheme.borderColor.withValues(alpha: 0.3),
          ),
        ),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          _navItems.length,
          (index) => _buildNavItem(index),
        ),
      ),
    );
  }

  static const _navItems = [
    _NavItem(Icons.home_rounded, 'Home'),
    _NavItem(Icons.shield_rounded, 'Protect'),
    _NavItem(Icons.assessment_rounded, 'Reports'),
    _NavItem(Icons.history_rounded, 'History'),
    _NavItem(Icons.person_rounded, 'Profile'),
  ];

  Widget _buildNavItem(int index) {
    final item = _navItems[index];
    final isSelected = index == currentIndex;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBlue.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}

/// Permission request card with status
class PermissionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isGranted;
  final VoidCallback onRequest;

  const PermissionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.isGranted,
    required this.onRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isGranted
              ? AppTheme.successGreen.withValues(alpha: 0.3)
              : AppTheme.borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isGranted
                  ? AppTheme.successGreen.withValues(alpha: 0.1)
                  : AppTheme.warningOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isGranted ? AppTheme.successGreen : AppTheme.warningOrange,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isGranted
                  ? AppTheme.successGreen.withValues(alpha: 0.1)
                  : AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isGranted ? 'Granted' : 'Allow',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isGranted ? AppTheme.successGreen : AppTheme.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}