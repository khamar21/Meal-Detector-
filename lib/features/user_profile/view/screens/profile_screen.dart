import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/profile_models.dart';
import '../../viewmodel/profile_view_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  String _gender = 'female';
  String _goal = 'maintain';
  String _activity = 'moderate';

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileViewModelProvider);
    final currentProfile = profileState.profile;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Set your calorie plan',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _age,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Age'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _height,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Height (cm)'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _weight,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Weight (kg)'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField(
            value: _gender,
            items: const [
              DropdownMenuItem(value: 'female', child: Text('Female')),
              DropdownMenuItem(value: 'male', child: Text('Male')),
            ],
            onChanged: (value) => setState(() => _gender = value.toString()),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField(
            value: _goal,
            items: const [
              DropdownMenuItem(value: 'lose', child: Text('Lose weight')),
              DropdownMenuItem(value: 'maintain', child: Text('Maintain')),
              DropdownMenuItem(value: 'gain', child: Text('Gain')),
            ],
            onChanged: (value) => setState(() => _goal = value.toString()),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField(
            value: _activity,
            items: const [
              DropdownMenuItem(value: 'low', child: Text('Low')),
              DropdownMenuItem(value: 'moderate', child: Text('Moderate')),
              DropdownMenuItem(value: 'high', child: Text('High')),
            ],
            onChanged: (value) => setState(() => _activity = value.toString()),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () async {
              final updated = ProfileFormData(
                name: _name.text.trim().isEmpty ? 'User' : _name.text.trim(),
                age: int.tryParse(_age.text.trim()) ?? 0,
                gender: _gender,
                heightCm: double.tryParse(_height.text.trim()) ?? 0,
                weightKg: double.tryParse(_weight.text.trim()) ?? 0,
                goal: _goal,
                activityLevel: _activity,
              );
              await ref
                  .read(profileViewModelProvider.notifier)
                  .saveProfile(updated);
            },
            child: const Text('Save profile'),
          ),
          if (currentProfile != null) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Profile saved for ${currentProfile.name}'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
