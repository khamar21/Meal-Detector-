import 'package:food_calorie_frontend/core/architecture/index.dart';

import '../../domain/entities/meal_entity.dart';

/// Data model for Meal
/// Handles serialization/deserialization to/from JSON
class MealModel extends Model<Meal> {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String mealType;
  final DateTime date;

  const MealModel({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.mealType,
    required this.date,
  });

  @override
  Meal toEntity() => Meal(
    id: id,
    name: name,
    calories: calories,
    protein: protein,
    carbs: carbs,
    fat: fat,
    mealType: mealType,
    date: date,
  );

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'calories': calories,
    'protein': protein,
    'carbs': carbs,
    'fat': fat,
    'mealType': mealType,
    'date': date.toIso8601String(),
  };

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      mealType: json['mealType'] as String? ?? 'snack',
      date: json['date'] is String
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
    );
  }

  factory MealModel.fromEntity(Meal meal) {
    return MealModel(
      id: meal.id,
      name: meal.name,
      calories: meal.calories,
      protein: meal.protein,
      carbs: meal.carbs,
      fat: meal.fat,
      mealType: meal.mealType,
      date: meal.date,
    );
  }
}
