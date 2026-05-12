import 'package:food_calorie_frontend/core/architecture/index.dart';

import '../../domain/entities/meal_entity.dart';
import '../../domain/repositories/diet_repository.dart';
import '../datasources/diet_local_data_source.dart';
import '../models/meal_model.dart';

/// Implementation of DietRepository
/// Bridges domain layer and data layer
class DietRepositoryImpl implements DietRepository {
  final DietLocalDataSource _localDataSource;

  DietRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, List<Meal>>> getMeals(DateTime date) async {
    try {
      final models = await _localDataSource.getMealsForDate(date);
      final entities = models.map((m) => m.toEntity()).toList();
      return EitherFactories.right<Failure, List<Meal>>(entities);
    } on Failure catch (failure) {
      return EitherFactories.left<Failure, List<Meal>>(failure);
    } catch (e, stackTrace) {
      return EitherFactories.left<Failure, List<Meal>>(
        CacheFailure(
          message: 'Failed to get meals',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Meal>>> getAllMeals() async {
    try {
      final models = await _localDataSource.loadMeals();
      final entities = models.map((m) => m.toEntity()).toList();
      return EitherFactories.right<Failure, List<Meal>>(entities);
    } on Failure catch (failure) {
      return EitherFactories.left<Failure, List<Meal>>(failure);
    } catch (e, stackTrace) {
      return EitherFactories.left<Failure, List<Meal>>(
        CacheFailure(
          message: 'Failed to get all meals',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> addMeal(Meal meal) async {
    try {
      final model = MealModel.fromEntity(meal);
      await _localDataSource.addMeal(model);
      return EitherFactories.right<Failure, void>(null);
    } on Failure catch (failure) {
      return EitherFactories.left<Failure, void>(failure);
    } catch (e, stackTrace) {
      return EitherFactories.left<Failure, void>(
        CacheFailure(
          message: 'Failed to add meal',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateMeal(Meal meal) async {
    try {
      final model = MealModel.fromEntity(meal);
      await _localDataSource.updateMeal(model);
      return EitherFactories.right<Failure, void>(null);
    } on Failure catch (failure) {
      return EitherFactories.left<Failure, void>(failure);
    } catch (e, stackTrace) {
      return EitherFactories.left<Failure, void>(
        CacheFailure(
          message: 'Failed to update meal',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteMeal(String mealId) async {
    try {
      await _localDataSource.deleteMeal(mealId);
      return EitherFactories.right<Failure, void>(null);
    } on Failure catch (failure) {
      return EitherFactories.left<Failure, void>(failure);
    } catch (e, stackTrace) {
      return EitherFactories.left<Failure, void>(
        CacheFailure(
          message: 'Failed to delete meal',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> clearMealsForDate(DateTime date) async {
    try {
      await _localDataSource.clearMealsForDate(date);
      return EitherFactories.right<Failure, void>(null);
    } on Failure catch (failure) {
      return EitherFactories.left<Failure, void>(failure);
    } catch (e, stackTrace) {
      return EitherFactories.left<Failure, void>(
        CacheFailure(
          message: 'Failed to clear meals for date',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
