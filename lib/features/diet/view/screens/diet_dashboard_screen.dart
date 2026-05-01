import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/diet_models.dart';
import '../../viewmodel/diet_view_model.dart';

class DietDashboardScreen extends ConsumerWidget {
  const DietDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dietViewModelProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Diet Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SummaryCard(
            title: 'Today',
            calories: state.totalCalories,
            target: state.dailyTargetCalories,
            remaining: state.remainingCalories,
          ),
          const SizedBox(height: 16),
          _ProfileCard(profile: state.profile),
          const SizedBox(height: 16),
          Text('Today\'s food log', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          if (state.entries.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No foods logged yet. Add scan results or manual foods.',
              ),
            )
          else
            ...state.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _DietEntryTile(entry: entry),
              ),
            ),
          const SizedBox(height: 16),
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
                value: mealType,
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
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.calories,
    required this.target,
    required this.remaining,
  });

  final String title;
  final double calories;
  final double target;
  final double remaining;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text('Consumed: ${calories.toStringAsFixed(0)} kcal'),
            Text('Target: ${target.toStringAsFixed(0)} kcal'),
            Text('Remaining: ${remaining.toStringAsFixed(0)} kcal'),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile});

  final UserProfile? profile;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
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
            Text(
              profile == null
                  ? 'Add your height, weight, age and goal in Profile.'
                  : 'Estimated calories: ${profile!.estimatedCalories.toStringAsFixed(0)} kcal',
            ),
          ],
        ),
      ),
    );
  }
}

class _DietEntryTile extends StatelessWidget {
  const _DietEntryTile({required this.entry});

  final DietEntry entry;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Theme.of(
        context,
      ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(entry.name),
      subtitle: Text(
        '${entry.mealType} • ${entry.loggedAt.toLocal().toString().split('.').first}',
      ),
      trailing: Text('${entry.calories.toStringAsFixed(0)} kcal'),
    );
  }
}
