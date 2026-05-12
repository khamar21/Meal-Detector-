import 'package:food_calorie_frontend/core/architecture/index.dart';

import '../repositories/profile_repository.dart';

/// UseCase to delete user profile
class DeleteProfileUseCase implements UseCase<void, NoParams> {
  final ProfileRepository _repository;

  DeleteProfileUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return _repository.deleteProfile();
  }
}
