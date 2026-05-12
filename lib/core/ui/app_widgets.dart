import 'dart:io';

import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.radius = 20,
    this.gradient,
    this.accentBorder = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final LinearGradient? gradient;
  final bool accentBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: gradient == null ? AppColors.card : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: AppColors.elevatedShadow,
        border: Border.all(
          color: accentBorder
              ? AppColors.secondaryLight.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.08),
          width: accentBorder ? 1.5 : 0.8,
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class GradientHeader extends StatelessWidget {
  const GradientHeader({
    required this.title,
    required this.subtitle,
    super.key,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.vibrantGreenGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppColors.elevatedShadow,
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.98),
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class NutritionCard extends StatelessWidget {
  const NutritionCard({
    required this.title,
    required this.value,
    required this.icon,
    super.key,
    this.color,
    this.useGradient = true,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final bool useGradient;

  @override
  Widget build(BuildContext context) {
    final tone = color ?? Theme.of(context).colorScheme.primary;

    // Create gradient backgrounds based on the tone color
    LinearGradient? cardGradient;
    if (useGradient) {
      if (tone == AppColors.secondary) {
        cardGradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.secondaryExtraLight, AppColors.card],
        );
      } else if (tone == AppColors.primary) {
        cardGradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryExtraLight, AppColors.card],
        );
      }
    }

    return AppCard(
      radius: 18,
      padding: const EdgeInsets.all(16),
      gradient: cardGradient,
      accentBorder: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tone.withValues(alpha: 0.15),
                  tone.withValues(alpha: 0.08),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: tone, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: tone,
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedCalorieRing extends StatelessWidget {
  const AnimatedCalorieRing({
    required this.progress,
    required this.centerLabel,
    required this.subLabel,
    super.key,
    this.size = 180,
  });

  final double progress;
  final String centerLabel;
  final String subLabel;
  final double size;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: clamped),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return SizedBox(
          height: size,
          width: size,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background circle with gradient
              CustomPaint(
                painter: GradientCirclePainter(
                  gradient: AppColors.softGreenGradient,
                ),
              ),
              CircularProgressIndicator(
                value: 1,
                strokeWidth: 14,
                valueColor: AlwaysStoppedAnimation(
                  AppColors.secondaryExtraLight,
                ),
              ),
              CircularProgressIndicator(
                value: value,
                strokeWidth: 14,
                strokeCap: StrokeCap.round,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      centerLabel,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class GradientCirclePainter extends CustomPainter {
  final LinearGradient gradient;

  GradientCirclePainter({required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = 1
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.08, paint);
  }

  @override
  bool shouldRepaint(GradientCirclePainter oldDelegate) {
    return oldDelegate.gradient != gradient;
  }
}

class FoodItemCard extends StatelessWidget {
  const FoodItemCard({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.icon,
    super.key,
    this.imagePath,
  });

  final String title;
  final String subtitle;
  final String trailing;
  final IconData icon;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final image = imagePath == null ? null : File(imagePath!);
    final hasImage = image != null && image.existsSync();

    return AppCard(
      radius: 16,
      margin: const EdgeInsets.only(bottom: 10),
      accentBorder: true,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 52,
              height: 52,
              child: hasImage
                  ? Image.file(image, fit: BoxFit.cover)
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.secondaryExtraLight,
                            AppColors.primaryExtraLight,
                          ],
                        ),
                      ),
                      child: Icon(icon, color: AppColors.secondary),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Text(
            trailing,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressSummaryCard extends StatelessWidget {
  const ProgressSummaryCard({
    required this.title,
    required this.subtitle,
    required this.progress,
    super.key,
  });

  final String title;
  final String subtitle;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);

    return AppCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.primaryExtraLight, AppColors.card],
      ),
      accentBorder: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: clamped),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            builder: (context, value, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Stack(
                  children: [
                    LinearProgressIndicator(
                      minHeight: 10,
                      value: 1,
                      backgroundColor: AppColors.secondaryExtraLight,
                      valueColor: const AlwaysStoppedAnimation(
                        Colors.transparent,
                      ),
                    ),
                    LinearProgressIndicator(
                      minHeight: 10,
                      value: value,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.primary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
