import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final textTheme = Theme.of(context).textTheme;

    final sourceLabel = result.sourceType == PredictionSource.voice
        ? 'Voice input'
        : 'Image upload';
    final sourceIcon = result.sourceType == PredictionSource.voice
        ? Icons.mic_rounded
        : Icons.image_outlined;

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Details')),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.18),
              colorScheme.surface,
              colorScheme.surface,
            ],
            stops: const [0, 0.24, 1],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
          children: [
            _HeroPreview(
              image: image,
              hasImage: hasImage,
              fallbackIcon: sourceIcon,
              sourceLabel: sourceLabel,
              caloriesLabel: result.caloriesLabel,
              confidenceLabel: result.confidenceLabel,
            ),
            const SizedBox(height: 16),
            Text(result.food, style: textTheme.headlineSmall),
            const SizedBox(height: 6),
            Text(
              'Scanned on ${_formatTimestamp(result.timestamp)}',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Tag(label: 'Calories ${result.caloriesLabel}'),
                _Tag(label: 'Confidence ${result.confidenceLabel}'),
                _Tag(label: sourceLabel),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
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
                label: const Text('Add to diet log'),
              ),
            ),
            const SizedBox(height: 14),
            _DetailPanel(
              children: [
                _DetailRow(
                  icon: Icons.schedule_rounded,
                  label: 'Scanned at',
                  value: _formatTimestamp(result.timestamp),
                ),
                const SizedBox(height: 10),
                _DetailRow(
                  icon: sourceIcon,
                  label: 'Source type',
                  value: sourceLabel,
                ),
                if (result.source != null &&
                    result.source!.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _DetailRow(
                    icon: Icons.link_rounded,
                    label: 'Source path',
                    value: result.source!,
                  ),
                ],
              ],
            ),
            if (result.voiceInput != null &&
                result.voiceInput!.trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              _SectionCard(
                title: 'Voice query',
                child: Text('"${result.voiceInput}"'),
              ),
            ],
            if (result.nutrition.hasData) ...[
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Nutrition breakdown',
                child: _NutritionSection(result: result),
              ),
            ],
            if (result.ingredients.isNotEmpty) ...[
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Ingredients',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: result.ingredients
                      .map((item) => _Tag(label: item))
                      .toList(growable: false),
                ),
              ),
            ],
            if (result.hasAdjustedData) ...[
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Portion adjusted calories',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.adjustedCaloriesLabel,
                      style: textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      result.adjustedNutrition.hasData
                          ? 'Adjusted nutrition data is available from the backend.'
                          : 'Only the adjusted calorie estimate was returned.',
                    ),
                  ],
                ),
              ),
            ],
            if (result.ingredientDetails.isNotEmpty) ...[
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Ingredient details',
                child: Column(
                  children: result.ingredientDetails
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _IngredientTile(detail: item),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
            ],
            if (result.alternatives.isNotEmpty) ...[
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Healthier alternatives',
                child: Column(
                  children: result.alternatives
                      .map(
                        (alternative) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _AlternativeTile(alternative: alternative),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HeroPreview extends StatelessWidget {
  const _HeroPreview({
    required this.image,
    required this.hasImage,
    required this.fallbackIcon,
    required this.sourceLabel,
    required this.caloriesLabel,
    required this.confidenceLabel,
  });

  final File? image;
  final bool hasImage;
  final IconData fallbackIcon;
  final String sourceLabel;
  final String caloriesLabel;
  final String confidenceLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Stack(
        children: [
          SizedBox(
            height: 260,
            width: double.infinity,
            child: hasImage
                ? Image.file(image!, fit: BoxFit.cover)
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primaryContainer,
                          colorScheme.secondaryContainer,
                        ],
                      ),
                    ),
                    child: Icon(fallbackIcon, size: 64),
                  ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.06),
                    Colors.black.withValues(alpha: 0.34),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Row(
              children: [
                Expanded(
                  child: _MiniStat(label: 'Calories', value: caloriesLabel),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniStat(label: 'Confidence', value: confidenceLabel),
                ),
              ],
            ),
          ),
          Positioned(top: 16, left: 16, child: _Tag(label: sourceLabel)),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 2),
              Text(value),
            ],
          ),
        ),
      ],
    );
  }
}

class _NutritionSection extends StatelessWidget {
  const _NutritionSection({required this.result});

  final PredictionResult result;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Bar(
          label: 'Protein',
          icon: Icons.fitness_center,
          value: result.nutrition.protein,
          max: 60,
        ),
        const SizedBox(height: 8),
        _Bar(
          label: 'Carbs',
          icon: Icons.grain,
          value: result.nutrition.carbs,
          max: 120,
        ),
        const SizedBox(height: 8),
        _Bar(
          label: 'Fat',
          icon: Icons.opacity,
          value: result.nutrition.fat,
          max: 45,
        ),
      ],
    );
  }
}

class _IngredientTile extends StatelessWidget {
  const _IngredientTile({required this.detail});

  final IngredientDetail detail;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.local_dining_outlined, color: colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (detail.calories != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    detail.calories!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  'Confidence: ${detail.confidenceLabel}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlternativeTile extends StatelessWidget {
  const _AlternativeTile({required this.alternative});

  final HealthierAlternative alternative;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  alternative.name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              _Tag(label: '${alternative.caloriesLabel} kcal'),
            ],
          ),
          const SizedBox(height: 6),
          Text('Reduction: ${alternative.reductionLabel}'),
          if (alternative.benefit != null &&
              alternative.benefit!.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              alternative.benefit!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.label,
    required this.icon,
    required this.value,
    required this.max,
  });

  final String label;
  final IconData icon;
  final double? value;
  final double max;

  @override
  Widget build(BuildContext context) {
    final amount = value ?? 0;
    final progress = (amount / max).clamp(0, 1).toDouble();

    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(label)),
            Text('${amount.toStringAsFixed(amount % 1 == 0 ? 0 : 1)} g'),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(value: progress, minHeight: 8),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.secondaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}

String _formatTimestamp(DateTime timestamp) {
  final local = timestamp.toLocal();
  return local.toString().split('.').first;
}
