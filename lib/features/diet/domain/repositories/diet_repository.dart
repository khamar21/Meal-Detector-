import 'package:food_calorie_frontend/core/architecture/index.dart';

import '../entities/meal_entity.dart';

/// Abstract repository for diet operations
/// This defines the contract that data layer must implement
abstract class DietRepository extends Repository {
  /// Get all meals for a specific date
  Future<Either<Failure, List<Meal>>> getMeals(DateTime date);

  /// Get all meals
  Future<Either<Failure, List<Meal>>> getAllMeals();

  /// Add a new meal
  Future<Either<Failure, void>> addMeal(Meal meal);

  /// Update an existing meal
  Future<Either<Failure, void>> updateMeal(Meal meal);

  /// Delete a meal by id
  Future<Either<Failure, void>> deleteMeal(String mealId);

  /// Clear all meals for a date
  Future<Either<Failure, void>> clearMealsForDate(DateTime date);
}
