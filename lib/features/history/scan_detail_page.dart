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

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Result')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
        children: [
          _TopImage(image: image, hasImage: hasImage),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  result.food,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _ConfidenceBadge(label: result.confidenceLabel),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            result.caloriesLabel,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scanned on ${_formatTimestamp(result.timestamp)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
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
                  value: '${(result.nutrition.fat ?? 0).toStringAsFixed(0)} g',
                  icon: Icons.water_drop_outlined,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (result.ingredients.isNotEmpty)
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ingredients',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...result.ingredients.map(
                    (ingredient) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, size: 8),
                          const SizedBox(width: 10),
                          Expanded(child: Text(ingredient)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (result.ingredientDetails.isNotEmpty) ...[
            const SizedBox(height: 18),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ingredient confidence',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...result.ingredientDetails.map(
                    (detail) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(child: Text(detail.name)),
                          Text(detail.confidenceLabel),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (result.alternatives.isNotEmpty) ...[
            const SizedBox(height: 18),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Healthier alternatives',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...result.alternatives.map(
                    (item) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.eco_outlined,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(item.name)),
                          Text('${item.reductionLabel} off'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () {
              final entry = DietEntry.fromPrediction(result);
              ProviderScope.containerOf(
                context,
              ).read(dietViewModelProvider.notifier).addPrediction(entry);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to today\'s diet log.')),
              );
            },
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Add to Diet'),
          ),
        ],
      ),
    );
  }
}

class _TopImage extends StatelessWidget {
  const _TopImage({required this.image, required this.hasImage});

  final File? image;
  final bool hasImage;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 280,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            hasImage
                ? Image.file(image!, fit: BoxFit.cover)
                : DecoratedBox(
                    decoration: const BoxDecoration(
                      gradient: AppColors.headerGradient,
                    ),
                    child: const Icon(
                      Icons.restaurant_outlined,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
            if (hasImage)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.12),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
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
