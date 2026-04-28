import 'dart:io';

import 'package:flutter/material.dart';

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
      appBar: AppBar(title: const Text('Scan Details')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: hasImage
                ? Image.file(image, height: 240, fit: BoxFit.cover)
                : Container(
                    height: 240,
                    color: colorScheme.surfaceContainerHighest,
                    child: Icon(
                      result.sourceType == PredictionSource.voice
                          ? Icons.mic
                          : Icons.image,
                      size: 56,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Text(result.food, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Tag(label: 'Calories: ${result.caloriesLabel}'),
              _Tag(label: 'Confidence: ${result.confidenceLabel}'),
              _Tag(
                label: result.sourceType == PredictionSource.voice
                    ? 'Voice'
                    : 'Image',
              ),
            ],
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
                icon: result.sourceType == PredictionSource.voice
                    ? Icons.mic_rounded
                    : Icons.image_outlined,
                label: 'Source type',
                value: result.sourceType == PredictionSource.voice
                    ? 'Voice input'
                    : 'Image upload',
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
            Text('Voice query: "${result.voiceInput}"'),
          ],
          const SizedBox(height: 16),
          if (result.nutrition.hasData) _NutritionSection(result: result),
          if (result.ingredients.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Ingredients', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: result.ingredients
                  .map((item) => _Tag(label: item))
                  .toList(growable: false),
            ),
          ],
          if (result.ingredientDetails.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Ingredient details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ...result.ingredientDetails.map(
              (item) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.local_dining_outlined),
                title: Text(item.name),
                subtitle: item.calories == null ? null : Text(item.calories!),
              ),
            ),
          ],
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nutrition breakdown',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
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
