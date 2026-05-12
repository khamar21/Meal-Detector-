import 'package:food_calorie_frontend/core/architecture/index.dart';

/// Domain entity representing a Meal
class Meal extends Entity {
  final String id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String mealType; // breakfast, lunch, dinner, snack
  final DateTime date;

  const Meal({
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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Meal &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          calories == other.calories &&
          protein == other.protein &&
          carbs == other.carbs &&
          fat == other.fat &&
          mealType == other.mealType &&
          date == other.date;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      calories.hashCode ^
      protein.hashCode ^
      carbs.hashCode ^
      fat.hashCode ^
      mealType.hashCode ^
      date.hashCode;
}
