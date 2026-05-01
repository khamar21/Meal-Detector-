import 'package:food_calorie_frontend/features/home/providers.dart';

class DietEntry {
  const DietEntry({
    required this.id,
    required this.name,
    required this.calories,
    required this.loggedAt,
    required this.mealType,
    this.imagePath,
  });

  final String id;
  final String name;
  final double calories;
  final DateTime loggedAt;
  final String mealType;
  final String? imagePath;

  factory DietEntry.fromPrediction(
    PredictionResult result, {
    String mealType = 'snack',
  }) {
    return DietEntry(
      id: result.id,
      name: result.food,
      calories: result.adjustedCaloriesKcal ?? result.caloriesKcal ?? 0,
      loggedAt: DateTime.now(),
      mealType: mealType,
      imagePath: result.source,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'loggedAt': loggedAt.toIso8601String(),
      'mealType': mealType,
      'imagePath': imagePath,
    };
  }

  factory DietEntry.fromJson(Map<String, dynamic> json) {
    return DietEntry(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      calories: (json['calories'] as num?)?.toDouble() ?? 0,
      loggedAt:
          DateTime.tryParse((json['loggedAt'] ?? '').toString()) ??
          DateTime.now(),
      mealType: (json['mealType'] ?? 'snack').toString(),
      imagePath: json['imagePath']?.toString(),
    );
  }
}

class UserProfile {
  const UserProfile({
    required this.name,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.goal,
    required this.activityLevel,
  });

  final String name;
  final int age;
  final String gender;
  final double heightCm;
  final double weightKg;
  final String goal;
  final String activityLevel;

  double get estimatedCalories {
    final base =
        10 * weightKg +
        6.25 * heightCm -
        5 * age +
        (gender.toLowerCase() == 'male' ? 5 : -161);
    if (goal == 'lose') return base - 300;
    if (goal == 'gain') return base + 300;
    return base;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'goal': goal,
      'activityLevel': activityLevel,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: (json['name'] ?? '').toString(),
      age: (json['age'] as num?)?.toInt() ?? 0,
      gender: (json['gender'] ?? 'female').toString(),
      heightCm: (json['heightCm'] as num?)?.toDouble() ?? 0,
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0,
      goal: (json['goal'] ?? 'maintain').toString(),
      activityLevel: (json['activityLevel'] ?? 'moderate').toString(),
    );
  }
}
