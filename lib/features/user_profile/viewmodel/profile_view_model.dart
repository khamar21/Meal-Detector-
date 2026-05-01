import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../diet/model/diet_models.dart';
import '../../diet/viewmodel/diet_view_model.dart';
import '../model/profile_models.dart';

class ProfileState {
  const ProfileState({this.profile});

  final ProfileFormData? profile;
}

final profileViewModelProvider =
    StateNotifierProvider<ProfileViewModel, ProfileState>((ref) {
      return ProfileViewModel(ref.read(dietViewModelProvider.notifier));
    });

class ProfileViewModel extends StateNotifier<ProfileState> {
  ProfileViewModel(this._dietViewModel) : super(const ProfileState());

  final DietViewModel _dietViewModel;

  Future<void> saveProfile(ProfileFormData profile) async {
    final userProfile = UserProfile(
      name: profile.name,
      age: profile.age,
      gender: profile.gender,
      heightCm: profile.heightCm,
      weightKg: profile.weightKg,
      goal: profile.goal,
      activityLevel: profile.activityLevel,
    );
    await _dietViewModel.saveProfile(userProfile);
    state = ProfileState(profile: profile);
  }
}
