import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/app_colors.dart';
import '../../../../core/ui/app_widgets.dart';
import '../../../../core/ui/palette.dart';
import '../../../diet/viewmodel/diet_view_model.dart';
import '../../../home/providers.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({required this.onScanTap, super.key});

  final VoidCallback onScanTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dietState = ref.watch(dietViewModelProvider);
    final scanHistory = ref.watch(predictionHistoryProvider);

    final consumed = dietState.totalCalories;
    final goal = dietState.dailyTargetCalories <= 0
        ? 2000
        : dietState.dailyTargetCalories;
    final progress = consumed / goal;
    final name = dietState.profile?.name.trim().isNotEmpty == true
        ? dietState.profile!.name
        : 'User';

    final protein = _macroTotal(scanHistory.map((it) => it.nutrition.protein));
    final carbs = _macroTotal(scanHistory.map((it) => it.nutrition.carbs));
    final fat = _macroTotal(scanHistory.map((it) => it.nutrition.fat));

    return Scaffold(
      backgroundColor: Palette.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            GradientHeader(
              title: 'Hi, $name 👋',
              subtitle: 'Track smarter. Eat better. Stay energized today.',
              trailing: IconButton.filled(
                onPressed: onScanTap,
                icon: const Icon(Icons.camera_alt_outlined),
                style: IconButton.styleFrom(
                  backgroundColor: Palette.surface.withValues(alpha: 0.2),
                  foregroundColor: Palette.surface,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ProgressSummaryCard(
              title:
                  '${consumed.toStringAsFixed(0)} / ${goal.toStringAsFixed(0)} kcal',
              subtitle: 'Calories consumed today',
              progress: progress,
            ),
            const SizedBox(height: 16),
            Text(
              'Macro nutrients',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: NutritionCard(
                    title: 'Protein',
                    value: '${protein.toStringAsFixed(0)} g',
                    icon: Icons.fitness_center,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: NutritionCard(
                    title: 'Carbs',
                    value: '${carbs.toStringAsFixed(0)} g',
                    icon: Icons.grain,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: NutritionCard(
                    title: 'Fat',
                    value: '${fat.toStringAsFixed(0)} g',
                    icon: Icons.water_drop_outlined,
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Recent meals',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: onScanTap,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Scan food'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (dietState.entries.isEmpty)
              const AppCard(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'No meals logged yet. Tap Scan Food to add your first meal.',
                  ),
                ),
              )
            else
              ...dietState.entries.take(5).map((entry) {
                return FoodItemCard(
                  title: entry.name,
                  subtitle: '${_capitalize(entry.mealType)} meal',
                  trailing: '${entry.calories.toStringAsFixed(0)} kcal',
                  icon: _mealIcon(entry.mealType),
                  imagePath: entry.imagePath,
                );
              }),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onScanTap,
        backgroundColor: Palette.primary,
        foregroundColor: Palette.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.document_scanner_outlined),
        label: const Text('Scan Food'),
      ),
    );
  }

  static double _macroTotal(Iterable<double?> values) {
    return values.whereType<double>().fold(0.0, (sum, item) => sum + item);
  }

  static IconData _mealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
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

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
