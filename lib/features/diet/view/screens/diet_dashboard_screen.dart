import 'dart:io';

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
    final dietState = ref.watch(dietViewModelProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Diet'),
        centerTitle: false,
        elevation: 0,
      ),
      body: Builder(
        builder: (context) {
          final state = dietState;
          final mealGroups = _groupByMeal(state.entries);
          final totalCals = state.totalCalories;
          final goal = state.dailyTargetCalories;
          final progress = (totalCals / goal).clamp(0.0, 1.0);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Ring
                Center(
                  child: AnimatedCalorieRing(
                    progress: progress,
                    centerLabel: '${(progress * 100).toInt()}%',
                    subLabel: 'Daily progress',
                    size: 140,
                  ),
                ),
                const SizedBox(height: 24),

                // Meal Sections
                ...mealGroups.entries.map((entry) {
                  final mealType = entry.key;
                  final items = entry.value;
                  final mealCals = items.fold<double>(
                    0,
                    (sum, item) => sum + item.calories,
                  );

                  return _MealSection(
                    mealType: mealType,
                    items: items,
                    totalCalories: mealCals,
                  );
                }),

                const SizedBox(height: 20),

                // Summary
                if (state.entries.isNotEmpty)
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Daily Summary', style: textTheme.titleMedium),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Consumed', style: textTheme.bodyMedium),
                            Text(
                              '${totalCals.toStringAsFixed(0)} kcal',
                              style: textTheme.titleMedium?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Remaining', style: textTheme.bodyMedium),
                            Text(
                              '${(goal - totalCals).toStringAsFixed(0)} kcal',
                              style: textTheme.titleMedium?.copyWith(
                                color: totalCals > goal
                                    ? const Color(0xFFC0392B)
                                    : AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                if (state.entries.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Column(
                        children: [
                          Icon(
                            Icons.restaurant_outlined,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No meals logged yet',
                            style: textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<String, List<DietEntry>> _groupByMeal(List<DietEntry> entries) {
    final groups = <String, List<DietEntry>>{
      'breakfast': [],
      'lunch': [],
      'dinner': [],
      'snack': [],
    };

    for (final entry in entries) {
      final meal = entry.mealType.toLowerCase();
      if (groups.containsKey(meal)) {
        groups[meal]!.add(entry);
      }
    }

    return groups..removeWhere((_, items) => items.isEmpty);
  }
}

class _MealSection extends StatelessWidget {
  const _MealSection({
    required this.mealType,
    required this.items,
    required this.totalCalories,
  });

  final String mealType;
  final List<DietEntry> items;
  final double totalCalories;

  IconData _getMealIcon(String type) {
    return switch (type.toLowerCase()) {
      'breakfast' => Icons.sunny,
      'lunch' => Icons.light_mode,
      'dinner' => Icons.dark_mode,
      'snack' => Icons.bakery_dining,
      _ => Icons.restaurant,
    };
  }

  String _getMealLabel(String type) {
    return '${type[0].toUpperCase()}${type.substring(1)}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getMealIcon(mealType),
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getMealLabel(mealType),
                        style: textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${items.length} item${items.length != 1 ? 's' : ''}',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${totalCalories.toStringAsFixed(0)} kcal',
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              return Padding(
                padding: EdgeInsets.only(top: index > 0 ? 8 : 0),
                child: _FoodItem(entry: item),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class _FoodItem extends StatelessWidget {
  const _FoodItem({required this.entry});

  final DietEntry entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final image = entry.imagePath != null ? File(entry.imagePath!) : null;
    final hasImage = image != null && image.existsSync();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 50,
              height: 50,
              child: hasImage
                  ? Image.file(image, fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.restaurant,
                        color: Colors.grey[400],
                        size: 24,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  entry.loggedAt.toString().split('.')[0],
                  style: textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Text(
            '${entry.calories.toStringAsFixed(0)} kcal',
            style: textTheme.titleSmall?.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
