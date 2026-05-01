import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/diet_models.dart';
import '../repository/diet_repository.dart';

class DietState {
  const DietState({
    required this.entries,
    required this.isLoading,
    required this.dailyTargetCalories,
    this.profile,
    this.error,
  });

  final List<DietEntry> entries;
  final bool isLoading;
  final double dailyTargetCalories;
  final UserProfile? profile;
  final String? error;

  double get totalCalories =>
      entries.fold<double>(0, (sum, item) => sum + item.calories);
  double get remainingCalories => dailyTargetCalories - totalCalories;

  factory DietState.initial() {
    return const DietState(
      entries: [],
      isLoading: false,
      dailyTargetCalories: 2000,
    );
  }

  DietState copyWith({
    List<DietEntry>? entries,
    bool? isLoading,
    double? dailyTargetCalories,
    UserProfile? profile,
    String? error,
  }) {
    return DietState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      dailyTargetCalories: dailyTargetCalories ?? this.dailyTargetCalories,
      profile: profile ?? this.profile,
      error: error,
    );
  }
}

final dietRepositoryProvider = Provider<DietRepository>(
  (ref) => DietRepository(),
);

final dietViewModelProvider = StateNotifierProvider<DietViewModel, DietState>((
  ref,
) {
  return DietViewModel(ref.read(dietRepositoryProvider));
});

class DietViewModel extends StateNotifier<DietState> {
  DietViewModel(this.repository) : super(DietState.initial()) {
    load();
  }

  final DietRepository repository;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final entries = await repository.loadEntries();
      final profile = await repository.loadProfile();
      state = state.copyWith(
        entries: entries,
        profile: profile,
        dailyTargetCalories:
            profile?.estimatedCalories ?? state.dailyTargetCalories,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    await repository.saveProfile(profile);
    state = state.copyWith(
      profile: profile,
      dailyTargetCalories: profile.estimatedCalories,
    );
  }

  Future<void> addPrediction(DietEntry entry) async {
    final updated = [entry, ...state.entries];
    state = state.copyWith(entries: updated, error: null);
    await repository.saveEntries(updated);
  }

  Future<void> addManualFood({
    required String name,
    required double calories,
    required String mealType,
  }) async {
    await addPrediction(
      DietEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        calories: calories,
        loggedAt: DateTime.now(),
        mealType: mealType,
      ),
    );
  }

  Future<void> removeEntry(String id) async {
    final updated = state.entries
        .where((item) => item.id != id)
        .toList(growable: false);
    state = state.copyWith(entries: updated);
    await repository.saveEntries(updated);
  }
}
