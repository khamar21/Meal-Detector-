import 'package:food_calorie_frontend/core/architecture/index.dart';

import '../entities/meal_entity.dart';
import '../repositories/diet_repository.dart';

/// UseCase to add a new meal
class AddMealUseCase implements UseCase<void, AddMealParams> {
  final DietRepository _repository;

  AddMealUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(AddMealParams params) {
    return _repository.addMeal(params.meal);
  }
}

class AddMealParams {
  final Meal meal;

  const AddMealParams(this.meal);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddMealParams &&
          runtimeType == other.runtimeType &&
          meal == other.meal;

  @override
  int get hashCode => meal.hashCode;
}
