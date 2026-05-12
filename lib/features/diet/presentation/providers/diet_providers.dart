import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/diet_local_data_source.dart';
import '../../data/repositories/diet_repository_impl.dart';
import '../../domain/repositories/diet_repository.dart';
import '../../domain/usecases/add_meal_usecase.dart';
import '../../domain/usecases/delete_meal_usecase.dart';
import '../../domain/usecases/get_meals_usecase.dart';

// ============ Data Sources ============
final dietLocalDataSourceProvider = Provider<DietLocalDataSource>(
  (ref) => const DietLocalDataSource(),
);

// ============ Repositories ============
final dietRepositoryProvider = Provider<DietRepository>((ref) {
  return DietRepositoryImpl(ref.read(dietLocalDataSourceProvider));
});

// ============ Use Cases ============
final getMealsUseCaseProvider = Provider<GetMealsUseCase>((ref) {
  return GetMealsUseCase(ref.read(dietRepositoryProvider));
});

final addMealUseCaseProvider = Provider<AddMealUseCase>((ref) {
  return AddMealUseCase(ref.read(dietRepositoryProvider));
});

final deleteMealUseCaseProvider = Provider<DeleteMealUseCase>((ref) {
  return DeleteMealUseCase(ref.read(dietRepositoryProvider));
});
