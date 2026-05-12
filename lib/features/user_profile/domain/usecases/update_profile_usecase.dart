import 'package:food_calorie_frontend/core/architecture/index.dart';

import '../entities/user_profile_entity.dart';
import '../repositories/profile_repository.dart';

/// UseCase to update specific profile fields
class UpdateProfileUseCase
    implements UseCase<UserProfile, UpdateProfileParams> {
  final ProfileRepository _repository;

  UpdateProfileUseCase(this._repository);

  @override
  Future<Either<Failure, UserProfile>> call(UpdateProfileParams params) {
    return _repository.updateProfile(
      name: params.name,
      age: params.age,
      gender: params.gender,
      heightCm: params.heightCm,
      weightKg: params.weightKg,
      goal: params.goal,
      activityLevel: params.activityLevel,
    );
  }
}

class UpdateProfileParams {
  final String? name;
  final int? age;
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  final String? goal;
  final String? activityLevel;

  const UpdateProfileParams({
    this.name,
    this.age,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.goal,
    this.activityLevel,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateProfileParams &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          age == other.age &&
          gender == other.gender &&
          heightCm == other.heightCm &&
          weightKg == other.weightKg &&
          goal == other.goal &&
          activityLevel == other.activityLevel;

  @override
  int get hashCode =>
      name.hashCode ^
      age.hashCode ^
      gender.hashCode ^
      heightCm.hashCode ^
      weightKg.hashCode ^
      goal.hashCode ^
      activityLevel.hashCode;
}
