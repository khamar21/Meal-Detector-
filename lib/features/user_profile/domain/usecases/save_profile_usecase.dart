import 'package:food_calorie_frontend/core/architecture/index.dart';

import '../entities/user_profile_entity.dart';
import '../repositories/profile_repository.dart';

/// UseCase to save or create a user profile
class SaveProfileUseCase implements UseCase<UserProfile, SaveProfileParams> {
  final ProfileRepository _repository;

  SaveProfileUseCase(this._repository);

  @override
  Future<Either<Failure, UserProfile>> call(SaveProfileParams params) {
    return _repository.saveProfile(params.profile);
  }
}

class SaveProfileParams {
  final UserProfile profile;

  const SaveProfileParams(this.profile);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaveProfileParams &&
          runtimeType == other.runtimeType &&
          profile == other.profile;

  @override
  int get hashCode => profile.hashCode;
}
