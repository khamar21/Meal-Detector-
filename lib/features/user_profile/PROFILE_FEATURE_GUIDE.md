/// Profile Feature - Clean Architecture Complete Implementation
/// 
/// ## Overview
/// 
/// The Profile feature implements a complete clean architecture for managing user
/// health and fitness profile data including personal metrics and dietary goals.
/// 
/// ## Domain Layer Features
/// 
/// **UserProfile Entity:**
/// - Personal: name, age, gender, height, weight
/// - Goals: weight goal (lose/maintain/gain), activity level
/// - Computed metrics:
///   - BMI (Body Mass Index)
///   - BMR (Basal Metabolic Rate)
///   - Daily calorie goal calculation
///   - BMI category classification
/// 
/// **Use Cases:**
/// 1. GetProfileUseCase - Retrieve current user profile
/// 2. SaveProfileUseCase - Create or save complete profile
/// 3. UpdateProfileUseCase - Update specific fields
/// 4. DeleteProfileUseCase - Remove profile data
/// 
/// ## Data Layer
/// 
/// **UserProfileModel:**
/// - JSON serialization/deserialization
/// - Factory methods for creation and copying
/// - ID generation for unique identification
/// 
/// **ProfileLocalDataSource:**
/// - SharedPreferences storage backend
/// - CRUD operations for profile persistence
/// 
/// **ProfileRepositoryImpl:**
/// - Bridges domain and data layers
/// - Implements error handling with Either type
/// - Manages profile lifecycle
/// 
/// ## Presentation Layer
/// 
/// **Riverpod Providers:**
/// - profileLocalDataSourceProvider
/// - profileRepositoryProvider
/// - getProfileUseCaseProvider
/// - saveProfileUseCaseProvider
/// - updateProfileUseCaseProvider
/// - deleteProfileUseCaseProvider
/// 
/// ## Usage Examples
/// 
/// ### Load Current Profile
/// ```dart
/// final getProfileUseCase = ref.read(getProfileUseCaseProvider);
/// final result = await getProfileUseCase(NoParams());
/// 
/// result.fold(
///   (failure) => showError(failure.message),
///   (profile) {
///     if (profile != null) {
///       print('User: ${profile.name}');
///       print('BMI: ${profile.bmi}');
///       print('Daily Calories: ${profile.calculateDailyCalories()}');
///     }
///   },
/// );
/// ```
/// 
/// ### Create New Profile
/// ```dart
/// final saveUseCase = ref.read(saveProfileUseCaseProvider);
/// 
/// final newProfile = UserProfile(
///   id: 'profile_1',
///   name: 'John Doe',
///   age: 30,
///   gender: 'male',
///   heightCm: 180,
///   weightKg: 75,
///   goal: 'lose',
///   activityLevel: 'moderate',
///   createdAt: DateTime.now(),
///   updatedAt: DateTime.now(),
/// );
/// 
/// final result = await saveUseCase(SaveProfileParams(newProfile));
/// result.fold(
///   (failure) => showError(failure.message),
///   (savedProfile) => showSuccess('Profile saved'),
/// );
/// ```
/// 
/// ### Update Profile Fields
/// ```dart
/// final updateUseCase = ref.read(updateProfileUseCaseProvider);
/// 
/// final result = await updateUseCase(
///   UpdateProfileParams(
///     weightKg: 72.5,
///     goal: 'maintain',
///   ),
/// );
/// 
/// result.fold(
///   (failure) => showError(failure.message),
///   (updatedProfile) => setState(() { profile = updatedProfile; }),
/// );
/// ```
/// 
/// ### Calculate Health Metrics
/// ```dart
/// // Assuming profile is loaded
/// print('BMI: ${profile.bmi.toStringAsFixed(1)}'); // e.g., 23.1
/// print('BMI Category: ${profile.bmiCategory}'); // e.g., Normal
/// print('BMR: ${profile.bmr.toStringAsFixed(0)} kcal/day'); // Basal Metabolic Rate
/// print('Daily Goal: ${profile.calculateDailyCalories().toStringAsFixed(0)} kcal');
/// ```
/// 
/// ## File Structure
/// 
/// ```
/// features/user_profile/
/// ├── domain/
/// │   ├── entities/
/// │   │   └── user_profile_entity.dart
/// │   ├── repositories/
/// │   │   └── profile_repository.dart
/// │   ├── usecases/
/// │   │   ├── get_profile_usecase.dart
/// │   │   ├── save_profile_usecase.dart
/// │   │   ├── update_profile_usecase.dart
/// │   │   └── delete_profile_usecase.dart
/// │   └── index.dart
/// ├── data/
/// │   ├── datasources/
/// │   │   └── profile_local_data_source.dart
/// │   ├── models/
/// │   │   └── user_profile_model.dart
/// │   └── repositories/
/// │       └── profile_repository_impl.dart
/// └── presentation/
///     ├── screens/
///     │   └── profile_screen.dart
///     ├── widgets/
///     │   ├── profile_metrics_card.dart
///     │   ├── profile_form.dart
///     │   └── bmi_indicator.dart
///     └── providers/
///         └── profile_providers.dart
/// ```
/// 
/// ## Key Metrics Calculations
/// 
/// ### BMI Formula
/// ```
/// BMI = Weight (kg) / (Height (m) ^ 2)
/// 
/// Categories:
/// - Underweight: < 18.5
/// - Normal: 18.5 - 24.9
/// - Overweight: 25 - 29.9
/// - Obese: >= 30
/// ```
/// 
/// ### BMR Formula (Mifflin-St Jeor)
/// ```
/// For Men:
/// BMR = (10 × weight_kg) + (6.25 × height_cm) - (5 × age_years) + 5
/// 
/// For Women:
/// BMR = (10 × weight_kg) + (6.25 × height_cm) - (5 × age_years) - 161
/// ```
/// 
/// ### TDEE (Total Daily Energy Expenditure)
/// ```
/// TDEE = BMR × Activity Factor
/// 
/// Activity Factors:
/// - Low (sedentary): 1.2
/// - Moderate: 1.55
/// - High (very active): 1.9
/// ```
/// 
/// ### Daily Calorie Goal
/// ```
/// - Lose weight: TDEE - 500 (calorie deficit)
/// - Maintain: TDEE
/// - Gain weight: TDEE + 300 (calorie surplus)
/// ```
///
