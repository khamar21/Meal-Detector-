import 'package:food_calorie_frontend/core/architecture/index.dart';

import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../models/user_profile_model.dart';

/// Implementation of ProfileRepository
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource _localDataSource;

  ProfileRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, UserProfile?>> getProfile() async {
    try {
      final model = await _localDataSource.loadProfile();
      return EitherFactories.right<Failure, UserProfile?>(
        model?.toEntity(),
      );
    } on Failure catch (failure) {
      return EitherFactories.left<Failure, UserProfile?>(failure);
    } catch (e, stackTrace) {
      return EitherFactories.left<Failure, UserProfile?>(
        CacheFailure(
          message: 'Failed to get profile',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, UserProfile>> saveProfile(
    UserProfile profile,
  ) async {
    try {
      final model = UserProfileModel.fromEntity(profile);
      await _localDataSource.saveProfile(model);
      return EitherFactories.right<Failure, UserProfile>(profile);
    } on Failure catch (failure) {
      return EitherFactories.left<Failure, UserProfile>(failure);
    } catch (e, stackTrace) {
      return EitherFactories.left<Failure, UserProfile>(
        CacheFailure(
          message: 'Failed to save profile',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteProfile() async {
    try {
      await _localDataSource.deleteProfile();
      return EitherFactories.right<Failure, void>(null);
    } on Failure catch (failure) {
      return EitherFactories.left<Failure, void>(failure);
    } catch (e, stackTrace) {
      return EitherFactories.left<Failure, void>(
        CacheFailure(
          message: 'Failed to delete profile',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> profileExists() async {
    try {
      final exists = await _localDataSource.profileExists();
      return EitherFactories.right<Failure, bool>(exists);
    } on Failure catch (failure) {
      return EitherFactories.left<Failure, bool>(failure);
    } catch (e, stackTrace) {
      return EitherFactories.left<Failure, bool>(
        CacheFailure(
          message: 'Failed to check if profile exists',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateProfile({
    String? name,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? goal,
    String? activityLevel,
  }) async {
    try {
      // Get current profile
      final currentResult = await getProfile();

      return currentResult.fold(
        (failure) => EitherFactories.left<Failure, UserProfile>(failure),
        (currentProfile) async {
          if (currentProfile == null) {
            return EitherFactories.left<Failure, UserProfile>(
              NotFoundFailure(message: 'Profile not found'),
            );
          }

          // Create updated profile
          final updatedProfile = currentProfile.copyWith(
            name: name,
            age: age,
            gender: gender,
            heightCm: heightCm,
            weightKg: weightKg,
            goal: goal,
            activityLevel: activityLevel,
          );

          // Save updated profile
          return await saveProfile(updatedProfile);
        },
      );
    } on Failure catch (failure) {
      return EitherFactories.left<Failure, UserProfile>(failure);
    } catch (e, stackTrace) {
      return EitherFactories.left<Failure, UserProfile>(
        CacheFailure(
          message: 'Failed to update profile',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}

/// Extension method to make copyWith easier
extension UserProfileCopyWith on UserProfile {
  UserProfile copyWith({
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
    return UserProfile(
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
