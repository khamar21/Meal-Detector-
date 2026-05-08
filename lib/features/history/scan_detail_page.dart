import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ui/app_colors.dart';
import '../../core/ui/app_widgets.dart';
import '../diet/model/diet_models.dart';
import '../diet/viewmodel/diet_view_model.dart';
import '../home/providers.dart';

class ScanDetailPage extends StatelessWidget {
  const ScanDetailPage({required this.result, super.key});

  final PredictionResult result;

  @override
  Widget build(BuildContext context) {
    final image = result.source != null ? File(result.source!) : null;
    final hasImage = image != null && image.existsSync();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Result'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF6FFF8), Color(0xFFF8FBF9), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            children: [
              _HeroSummary(
                image: image,
                hasImage: hasImage,
                title: result.food,
                caloriesLabel: result.caloriesLabel,
                confidenceLabel: result.confidenceLabel,
                timestamp: _formatTimestamp(result.timestamp),
              ),
              const SizedBox(height: 18),
              _QuickStats(
                primaryValue: result.caloriesLabel,
                primaryLabel: 'Calories',
                confidenceLabel: result.confidenceLabel,
                accentColor: colorScheme.primary,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: NutritionCard(
                      title: 'Protein',
                      value:
                          '${(result.nutrition.protein ?? 0).toStringAsFixed(0)} g',
                      icon: Icons.fitness_center,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NutritionCard(
                      title: 'Carbs',
                      value:
                          '${(result.nutrition.carbs ?? 0).toStringAsFixed(0)} g',
                      icon: Icons.grain,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NutritionCard(
                      title: 'Fat',
                      value:
                          '${(result.nutrition.fat ?? 0).toStringAsFixed(0)} g',
                      icon: Icons.water_drop_outlined,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (result.ingredients.isNotEmpty)
                _SectionCard(
                  title: 'Ingredients',
                  icon: Icons.ramen_dining_outlined,
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: result.ingredients
                        .map(
                          (ingredient) =>
                              _PillTag(label: ingredient, icon: Icons.circle),
                        )
                        .toList(),
                  ),
                ),
              if (result.ingredients.isNotEmpty &&
                  result.ingredientDetails.isNotEmpty)
                const SizedBox(height: 18),
              if (result.ingredientDetails.isNotEmpty)
                _SectionCard(
                  title: 'Ingredient confidence',
                  icon: Icons.fact_check_outlined,
                  child: Column(
                    children: result.ingredientDetails
                        .map(
                          (detail) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.55),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      detail.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                  _ConfidenceBadge(
                                    label: detail.confidenceLabel,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              if (result.ingredientDetails.isNotEmpty &&
                  result.alternatives.isNotEmpty)
                const SizedBox(height: 18),
              if (result.alternatives.isNotEmpty)
                _SectionCard(
                  title: 'Healthier alternatives',
                  icon: Icons.eco_outlined,
                  child: Column(
                    children: result.alternatives
                        .map(
                          (item) => Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.08,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary.withValues(
                                      alpha: 0.12,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.eco_outlined,
                                    color: AppColors.secondary,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'A lighter choice with ${item.reductionLabel} fewer calories',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              const SizedBox(height: 22),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {
                  final entry = DietEntry.fromPrediction(result);
                  ProviderScope.containerOf(
                    context,
                  ).read(dietViewModelProvider.notifier).addPrediction(entry);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Added to today\'s diet log.'),
                    ),
                  );
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Add to Diet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSummary extends StatelessWidget {
  const _HeroSummary({
    required this.image,
    required this.hasImage,
    required this.title,
    required this.caloriesLabel,
    required this.confidenceLabel,
    required this.timestamp,
  });

  final File? image;
  final bool hasImage;
  final String title;
  final String caloriesLabel;
  final String confidenceLabel;
  final String timestamp;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      radius: 28,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: SizedBox(
          width: double.infinity,
          child: Stack(
            children: [
              SizedBox(
                height: 300,
                width: double.infinity,
                child: hasImage
                    ? Image.file(image!, fit: BoxFit.cover)
                    : DecoratedBox(
                        decoration: const BoxDecoration(
                          gradient: AppColors.headerGradient,
                        ),
                        child: const Icon(
                          Icons.restaurant_outlined,
                          color: Colors.white,
                          size: 64,
                        ),
                      ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.08),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.72),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: _ConfidenceBadge(label: confidenceLabel),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.24),
                            ),
                          ),
                          child: Text(
                            caloriesLabel,
                            style: textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Scanned on $timestamp',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  const _QuickStats({
    required this.primaryValue,
    required this.primaryLabel,
    required this.confidenceLabel,
    required this.accentColor,
  });

  final String primaryValue;
  final String primaryLabel;
  final String confidenceLabel;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: accentColor.withValues(alpha: 0.08),
              border: Border.all(color: accentColor.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  primaryLabel,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  primaryValue,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.52),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Confidence',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  confidenceLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _PillTag extends StatelessWidget {
  const _PillTag({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 8, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  const _ConfidenceBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.secondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _formatTimestamp(DateTime timestamp) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${timestamp.year}-${two(timestamp.month)}-${two(timestamp.day)} ${two(timestamp.hour)}:${two(timestamp.minute)}';
}
