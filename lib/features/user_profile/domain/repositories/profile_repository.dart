import 'package:food_calorie_frontend/core/architecture/index.dart';

import '../entities/user_profile_entity.dart';

/// Abstract repository for user profile operations
abstract class ProfileRepository extends Repository {
  /// Get the current user profile
  Future<Either<Failure, UserProfile?>> getProfile();

  /// Save or update user profile
  Future<Either<Failure, UserProfile>> saveProfile(UserProfile profile);

  /// Delete user profile
  Future<Either<Failure, void>> deleteProfile();

  /// Check if profile exists
  Future<Either<Failure, bool>> profileExists();

  /// Update specific profile fields
  Future<Either<Failure, UserProfile>> updateProfile({
    String? name,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? goal,
    String? activityLevel,
  });
}
