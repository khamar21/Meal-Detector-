import 'dart:convert';

import 'package:food_calorie_frontend/core/architecture/index.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal_model.dart';

/// Local data source for diet data
/// Handles local storage operations (SharedPreferences, SQLite, etc.)
class DietLocalDataSource extends LocalDataSource {
  const DietLocalDataSource();

  static const String _mealsKey = 'diet_meals_v1';

  /// Load all meals from local storage
  Future<List<MealModel>> loadMeals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_mealsKey);

      if (raw == null || raw.trim().isEmpty) {
        return [];
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return [];
      }

      return decoded
          .whereType<Map>()
          .map((item) => MealModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (e) {
      throw CacheFailure(
        message: 'Failed to load meals from local storage',
        originalError: e,
      );
    }
  }

  /// Save meals to local storage
  Future<void> saveMeals(List<MealModel> meals) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(meals.map((m) => m.toJson()).toList());
      await prefs.setString(_mealsKey, encoded);
    } catch (e) {
      throw CacheFailure(
        message: 'Failed to save meals to local storage',
        originalError: e,
      );
    }
  }

  /// Get meals for a specific date
  Future<List<MealModel>> getMealsForDate(DateTime date) async {
    try {
      final allMeals = await loadMeals();
      final dateStr = date.toString().split(' ')[0]; // YYYY-MM-DD

      return allMeals
          .where((meal) => meal.date.toString().split(' ')[0] == dateStr)
          .toList();
    } catch (e) {
      throw CacheFailure(
        message: 'Failed to get meals for date',
        originalError: e,
      );
    }
  }

  /// Add a meal
  Future<void> addMeal(MealModel meal) async {
    try {
      final allMeals = await loadMeals();
      allMeals.add(meal);
      await saveMeals(allMeals);
    } catch (e) {
      throw CacheFailure(message: 'Failed to add meal', originalError: e);
    }
  }

  /// Update a meal
  Future<void> updateMeal(MealModel meal) async {
    try {
      final allMeals = await loadMeals();
      final index = allMeals.indexWhere((m) => m.id == meal.id);

      if (index >= 0) {
        allMeals[index] = meal;
        await saveMeals(allMeals);
      }
    } catch (e) {
      throw CacheFailure(message: 'Failed to update meal', originalError: e);
    }
  }

  /// Delete a meal by id
  Future<void> deleteMeal(String mealId) async {
    try {
      final allMeals = await loadMeals();
      allMeals.removeWhere((m) => m.id == mealId);
      await saveMeals(allMeals);
    } catch (e) {
      throw CacheFailure(message: 'Failed to delete meal', originalError: e);
    }
  }

  /// Clear all meals for a date
  Future<void> clearMealsForDate(DateTime date) async {
    try {
      final allMeals = await loadMeals();
      final dateStr = date.toString().split(' ')[0];

      allMeals.removeWhere((m) => m.date.toString().split(' ')[0] == dateStr);
      await saveMeals(allMeals);
    } catch (e) {
      throw CacheFailure(
        message: 'Failed to clear meals for date',
        originalError: e,
      );
    }
  }
}
