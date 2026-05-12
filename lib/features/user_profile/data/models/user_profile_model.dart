import 'package:food_calorie_frontend/core/architecture/index.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/user_profile_entity.dart';

/// Data model for UserProfile
class UserProfileModel extends Model<UserProfile> {
  final String id;
  final String name;
  final int age;
  final String gender;
  final double heightCm;
  final double weightKg;
  final String goal;
  final String activityLevel;
  final double? dailyCalorieGoal;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfileModel({
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

  @override
  UserProfile toEntity() => UserProfile(
    id: id,
    name: name,
    age: age,
    gender: gender,
    heightCm: heightCm,
    weightKg: weightKg,
    goal: goal,
    activityLevel: activityLevel,
    dailyCalorieGoal: dailyCalorieGoal,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'age': age,
    'gender': gender,
    'heightCm': heightCm,
    'weightKg': weightKg,
    'goal': goal,
    'activityLevel': activityLevel,
    'dailyCalorieGoal': dailyCalorieGoal,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      gender: json['gender'] as String? ?? 'female',
      heightCm: (json['heightCm'] as num?)?.toDouble() ?? 0.0,
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0.0,
      goal: json['goal'] as String? ?? 'maintain',
      activityLevel: json['activityLevel'] as String? ?? 'moderate',
      dailyCalorieGoal: (json['dailyCalorieGoal'] as num?)?.toDouble(),
      createdAt: json['createdAt'] is String
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] is String
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      id: profile.id,
      name: profile.name,
      age: profile.age,
      gender: profile.gender,
      heightCm: profile.heightCm,
      weightKg: profile.weightKg,
      goal: profile.goal,
      activityLevel: profile.activityLevel,
      dailyCalorieGoal: profile.dailyCalorieGoal,
      createdAt: profile.createdAt,
      updatedAt: profile.updatedAt,
    );
  }

  /// Create a new profile model with a generated ID
  factory UserProfileModel.create({
    required String name,
    required int age,
    required String gender,
    required double heightCm,
    required double weightKg,
    required String goal,
    required String activityLevel,
  }) {
    final now = DateTime.now();
    return UserProfileModel(
      id: const Uuid().v4(),
      name: name,
      age: age,
      gender: gender,
      heightCm: heightCm,
      weightKg: weightKg,
      goal: goal,
      activityLevel: activityLevel,
      dailyCalorieGoal: null,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Create a copy with updated fields
  UserProfileModel copyWith({
    String? id,
    String? name,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? goal,
    String? activityLevel,
    double? dailyCalorieGoal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      goal: goal ?? this.goal,
      activityLevel: activityLevel ?? this.activityLevel,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
