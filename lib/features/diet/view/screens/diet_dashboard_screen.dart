import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/app_colors.dart';
import '../../../../core/ui/app_widgets.dart';
import '../../model/diet_models.dart';
import '../../viewmodel/diet_view_model.dart';

class DietDashboardScreen extends ConsumerWidget {
  const DietDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dietViewModelProvider);

    final consumed = state.totalCalories;
    final target = state.dailyTargetCalories <= 0
        ? 2000
        : state.dailyTargetCalories;
    final remaining = state.remainingCalories;
    final progress = consumed / target;

    final groupedMeals = _groupByMeal(state.entries);

    return Scaffold(
      appBar: AppBar(title: const Text('Diet Dashboard')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          AppCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${consumed.toStringAsFixed(0)} kcal',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Consumed of ${target.toStringAsFixed(0)} kcal goal',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${remaining.toStringAsFixed(0)} kcal remaining',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: remaining < 0
                                  ? AppColors.accent
                                  : AppColors.secondary,
                            ),
                      ),
                    ],
                  ),
                ),
                AnimatedCalorieRing(
                  progress: progress,
                  centerLabel:
                      '${(progress * 100).clamp(0, 999).toStringAsFixed(0)}%',
                  subLabel: 'Daily progress',
                  size: 128,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _ProfileSummaryCard(profile: state.profile),
          const SizedBox(height: 16),
          Text(
            'Meals',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ..._mealOrder.map((meal) {
            final entries = groupedMeals[meal] ?? const <DietEntry>[];
            return _MealSection(
              title: _capitalize(meal),
              icon: _mealIcon(meal),
              entries: entries,
              onRemove: (id) {
                ref.read(dietViewModelProvider.notifier).removeEntry(id);
              },
            );
          }),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => _showAddFoodDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Add manual food'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddFoodDialog(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final caloriesController = TextEditingController();
    var mealType = 'snack';

    await showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add food'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Food name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: caloriesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Calories'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: mealType,
                items: const [
                  DropdownMenuItem(
                    value: 'breakfast',
                    child: Text('Breakfast'),
                  ),
                  DropdownMenuItem(value: 'lunch', child: Text('Lunch')),
                  DropdownMenuItem(value: 'dinner', child: Text('Dinner')),
                  DropdownMenuItem(value: 'snack', child: Text('Snack')),
                ],
                onChanged: (value) =>
                    setState(() => mealType = value ?? 'snack'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final calories =
                    double.tryParse(caloriesController.text.trim()) ?? 0;
                await ref
                    .read(dietViewModelProvider.notifier)
                    .addManualFood(
                      name: nameController.text.trim().isEmpty
                          ? 'Manual food'
                          : nameController.text.trim(),
                      calories: calories,
                      mealType: mealType,
                    );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  static Map<String, List<DietEntry>> _groupByMeal(List<DietEntry> entries) {
    final grouped = <String, List<DietEntry>>{};
    for (final entry in entries) {
      grouped.putIfAbsent(entry.mealType.toLowerCase(), () => []).add(entry);
    }
    return grouped;
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  static IconData _mealIcon(String mealType) {
    switch (mealType) {
      case 'breakfast':
        return Icons.free_breakfast_outlined;
      case 'lunch':
        return Icons.lunch_dining_outlined;
      case 'dinner':
        return Icons.dinner_dining_outlined;
      default:
        return Icons.cookie_outlined;
    }
  }
}

const _mealOrder = ['breakfast', 'lunch', 'dinner', 'snack'];

class _MealSection extends StatelessWidget {
  const _MealSection({
    required this.title,
    required this.icon,
    required this.entries,
    required this.onRemove,
  });

  final String title;
  final IconData icon;
  final List<DietEntry> entries;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.secondary),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                '${entries.fold<double>(0, (sum, item) => sum + item.calories).toStringAsFixed(0)} kcal',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (entries.isEmpty)
            Text('No items yet', style: Theme.of(context).textTheme.bodyMedium)
          else
            ...entries.map(
              (entry) => FoodItemCard(
                title: entry.name,
                subtitle: entry.loggedAt.toLocal().toString().split('.').first,
                trailing: '${entry.calories.toStringAsFixed(0)} kcal',
                icon: icon,
                imagePath: entry.imagePath,
                key: ValueKey(entry.id),
              ),
            ),
          if (entries.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => onRemove(entries.first.id),
                icon: const Icon(Icons.remove_circle_outline),
                label: const Text('Remove latest'),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({required this.profile});

  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profile', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            profile == null
                ? 'No profile yet'
                : '${profile!.name} • ${profile!.goal}',
          ),
          const SizedBox(height: 4),
          Text(
            profile == null
                ? 'Add your age, height, weight, and goal in Profile tab.'
                : 'Estimated calories: ${profile!.estimatedCalories.toStringAsFixed(0)} kcal',
          ),
        ],
      ),
    );
  }
}
