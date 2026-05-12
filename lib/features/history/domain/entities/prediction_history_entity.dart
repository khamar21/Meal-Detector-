import 'package:food_calorie_frontend/core/architecture/index.dart';

/// Domain entity representing a prediction result from food scanning
class PredictionHistory extends Entity {
  final String id;
  final String foodName;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String? imagePath;
  final DateTime createdAt;

  const PredictionHistory({
    required this.id,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.imagePath,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PredictionHistory &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          foodName == other.foodName &&
          calories == other.calories &&
          protein == other.protein &&
          carbs == other.carbs &&
          fat == other.fat &&
          imagePath == other.imagePath &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      foodName.hashCode ^
      calories.hashCode ^
      protein.hashCode ^
      carbs.hashCode ^
      fat.hashCode ^
      imagePath.hashCode ^
      createdAt.hashCode;
}
