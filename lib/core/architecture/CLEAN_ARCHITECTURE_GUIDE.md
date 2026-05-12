/// Clean Architecture Documentation & Guidelines
/// 
/// This document outlines the clean architecture structure used in this app.
/// 
/// ## Architecture Layers
/// 
/// ### 1. Presentation Layer (UI)
/// - **Location**: `lib/features/{feature}/presentation/`
/// - **Responsibility**: Display UI, handle user interactions, manage UI state
/// - **Components**:
///   - `screens/`: Full screen widgets
///   - `widgets/`: Reusable UI components
///   - `providers/`: Riverpod providers for state management
///   - `viewmodels/`: State holders (if not using Riverpod StateNotifier)
/// 
/// **Example Structure**:
/// ```
/// features/
///   diet/
///     presentation/
///       screens/
///         diet_dashboard_screen.dart
///       widgets/
///         meal_card.dart
///       providers/
///         diet_providers.dart
/// ```
/// 
/// ### 2. Domain Layer (Business Logic)
/// - **Location**: `lib/features/{feature}/domain/`
/// - **Responsibility**: Contains pure business logic, independent of any framework
/// - **Components**:
///   - `entities/`: Pure Dart classes representing core business objects
///   - `repositories/`: Abstract repository interfaces
///   - `usecases/`: Orchestrate data flow and business logic
/// 
/// **Entity Example**:
/// ```dart
/// import 'package:equatable/equatable.dart';
/// 
/// class Meal extends Equatable {
///   final String id;
///   final String name;
///   final double calories;
///   
///   const Meal({
///     required this.id,
///     required this.name,
///     required this.calories,
///   });
///   
///   @override
///   List<Object?> get props => [id, name, calories];
/// }
/// ```
/// 
/// **Repository Interface Example**:
/// ```dart
/// abstract class DietRepository {
///   Future<Either<Failure, List<Meal>>> getMeals(String date);
///   Future<Either<Failure, void>> addMeal(Meal meal);
/// }
/// ```
/// 
/// **UseCase Example**:
/// ```dart
/// import 'package:food_calorie_frontend/core/architecture/index.dart';
/// 
/// class GetMealsUseCase implements UseCase<List<Meal>, GetMealsParams> {
///   final DietRepository repository;
///   
///   GetMealsUseCase(this.repository);
///   
///   @override
///   Future<Either<Failure, List<Meal>>> call(GetMealsParams params) {
///     return repository.getMeals(params.date);
///   }
/// }
/// 
/// class GetMealsParams {
///   final String date;
///   GetMealsParams(this.date);
/// }
/// ```
/// 
/// ### 3. Data Layer
/// - **Location**: `lib/features/{feature}/data/`
/// - **Responsibility**: Handle data operations (API calls, local storage)
/// - **Components**:
///   - `datasources/`: 
///     - `remote/`: API calls
///     - `local/`: Database, SharedPreferences
///   - `models/`: Data models (JSON serializable)
///   - `repositories/`: Repository implementations
/// 
/// **Model Example**:
/// ```dart
/// import 'package:food_calorie_frontend/core/architecture/index.dart';
/// 
/// class MealModel extends Model<Meal> {
///   final String id;
///   final String name;
///   final double calories;
///   
///   MealModel({
///     required this.id,
///     required this.name,
///     required this.calories,
///   });
///   
///   @override
///   Meal toEntity() => Meal(
///     id: id,
///     name: name,
///     calories: calories,
///   );
///   
///   @override
///   Map<String, dynamic> toJson() => {
///     'id': id,
///     'name': name,
///     'calories': calories,
///   };
///   
///   factory MealModel.fromJson(Map<String, dynamic> json) {
///     return MealModel(
///       id: json['id'] as String,
///       name: json['name'] as String,
///       calories: json['calories'] as double,
///     );
///   }
/// }
/// ```
/// 
/// **DataSource Example**:
/// ```dart
/// class DietLocalDataSource extends LocalDataSource {
///   const DietLocalDataSource();
///   
///   Future<List<MealModel>> getMeals(String date) async {
///     // Implementation
///   }
/// }
/// ```
/// 
/// **Repository Implementation Example**:
/// ```dart
/// class DietRepositoryImpl implements DietRepository {
///   final DietLocalDataSource _localDataSource;
///   
///   DietRepositoryImpl(this._localDataSource);
///   
///   @override
///   Future<Either<Failure, List<Meal>>> getMeals(String date) async {
///     try {
///       final models = await _localDataSource.getMeals(date);
///       return Either.right(models.map((m) => m.toEntity()).toList());
///     } catch (e, stackTrace) {
///       return Either.left(CacheFailure(
///         message: 'Failed to load meals',
///         originalError: e,
///         stackTrace: stackTrace,
///       ));
///     }
///   }
/// }
/// ```
/// 
/// ## Data Flow
/// 
/// ```
/// UI (Screen/Widget)
///   ↓
/// Riverpod Provider
///   ↓
/// UseCase
///   ↓
/// Repository
///   ↓
/// DataSource (Local/Remote)
///   ↓
/// Local Storage / API
/// ```
/// 
/// ## Error Handling
/// 
/// Use the `Either<Failure, T>` type for error handling:
/// 
/// ```dart
/// // In your provider
/// final myDataProvider = FutureProvider((ref) async {
///   final result = await useCase(params);
///   
///   return result.fold(
///     (failure) => throw Exception(failure.message),
///     (data) => data,
///   );
/// });
/// ```
/// 
/// ## Dependency Injection
/// 
/// Use the `ServiceLocator` to register and retrieve dependencies:
/// 
/// ```dart
/// // In main.dart
/// void main() {
///   setupServiceLocator();
///   runApp(const MyApp());
/// }
/// 
/// // In your feature
/// final getIt = GetIt.instance;
/// final useCase = getIt<YourUseCase>();
/// ```
/// 
/// ## Feature Folder Structure
/// 
/// ```
/// features/
///   diet/
///     presentation/
///       screens/
///       widgets/
///       providers/
///     domain/
///       entities/
///       repositories/
///       usecases/
///     data/
///       datasources/
///       models/
///       repositories/
/// ```
/// 
/// ## Key Principles
/// 
/// 1. **Separation of Concerns**: Each layer has a specific responsibility
/// 2. **Dependency Rule**: Outer layers depend on inner layers, never the reverse
/// 3. **Testability**: Pure domain layer code with no framework dependencies
/// 4. **Reusability**: Business logic is separate from UI frameworks
/// 5. **Maintainability**: Clear structure makes code easier to maintain
///
