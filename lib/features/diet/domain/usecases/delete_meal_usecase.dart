import 'package:food_calorie_frontend/core/architecture/index.dart';

import '../repositories/diet_repository.dart';

/// UseCase to delete a meal
class DeleteMealUseCase implements UseCase<void, DeleteMealParams> {
  final DietRepository _repository;

  DeleteMealUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(DeleteMealParams params) {
    return _repository.deleteMeal(params.mealId);
  }
}

class DeleteMealParams {
  final String mealId;

  const DeleteMealParams(this.mealId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeleteMealParams &&
          runtimeType == other.runtimeType &&
          mealId == other.mealId;

  @override
  int get hashCode => mealId.hashCode;
}
