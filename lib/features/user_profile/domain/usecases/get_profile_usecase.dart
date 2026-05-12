import 'package:food_calorie_frontend/core/architecture/index.dart';

import '../entities/user_profile_entity.dart';
import '../repositories/profile_repository.dart';

/// UseCase to get the current user profile
class GetProfileUseCase implements UseCase<UserProfile?, NoParams> {
  final ProfileRepository _repository;

  GetProfileUseCase(this._repository);

  @override
  Future<Either<Failure, UserProfile?>> call(NoParams params) {
    return _repository.getProfile();
  }
}
