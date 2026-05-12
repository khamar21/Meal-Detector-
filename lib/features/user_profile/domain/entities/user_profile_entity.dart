import 'package:food_calorie_frontend/core/architecture/index.dart';

/// Domain entity representing a user profile
class UserProfile extends Entity {
  final String id;
  final String name;
  final int age;
  final String gender; // 'male' or 'female'
  final double heightCm;
  final double weightKg;
  final String goal; // 'lose', 'maintain', 'gain'
  final String activityLevel; // 'low', 'moderate', 'high'
  final double? dailyCalorieGoal;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.goal,
    required this.activityLevel,
    this.dailyCalorieGoal,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculate BMI (Body Mass Index)
  double get bmi => weightKg / ((heightCm / 100) * (heightCm / 100));

  /// Estimate BMR (Basal Metabolic Rate) using Mifflin-St Jeor equation
  double get bmr {
    if (gender == 'male') {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5;
    } else {
      return (10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161;
    }
  }

  /// Calculate daily calorie goal based on activity level
  double calculateDailyCalories() {
    const activityFactors = {'low': 1.2, 'moderate': 1.55, 'high': 1.9};

    final factor = activityFactors[activityLevel] ?? 1.2;
    final tdee = bmr * factor;

    // Adjust based on goal
    switch (goal) {
      case 'lose':
        return tdee - 500; // 500 calorie deficit
      case 'gain':
        return tdee + 300; // 300 calorie surplus
      default:
        return tdee; // maintain
    }
  }

  /// Get BMI category
  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          age == other.age &&
          gender == other.gender &&
          heightCm == other.heightCm &&
          weightKg == other.weightKg &&
          goal == other.goal &&
          activityLevel == other.activityLevel &&
          dailyCalorieGoal == other.dailyCalorieGoal &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      age.hashCode ^
      gender.hashCode ^
      heightCm.hashCode ^
      weightKg.hashCode ^
      goal.hashCode ^
      activityLevel.hashCode ^
      dailyCalorieGoal.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
}
