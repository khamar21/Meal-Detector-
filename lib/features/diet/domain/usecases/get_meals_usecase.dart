import 'package:food_calorie_frontend/core/architecture/index.dart';

import '../entities/meal_entity.dart';
import '../repositories/diet_repository.dart';

/// UseCase to get meals for a specific date
class GetMealsUseCase implements UseCase<List<Meal>, GetMealsParams> {
  final DietRepository _repository;

  GetMealsUseCase(this._repository);

  @override
  Future<Either<Failure, List<Meal>>> call(GetMealsParams params) {
    return _repository.getMeals(params.date);
  }
}

class GetMealsParams {
  final DateTime date;

  const GetMealsParams(this.date);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetMealsParams &&
          runtimeType == other.runtimeType &&
          date == other.date;

  @override
  int get hashCode => date.hashCode;
}
