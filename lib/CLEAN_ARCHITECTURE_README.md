/// # Food Calorie Tracker - Clean Architecture Implementation
///
/// ## Project Structure
///
/// ```
/// lib/
/// ├── core/
/// │   ├── architecture/           # Core architecture classes
/// │   │   ├── base_entity.dart
/// │   │   ├── base_model.dart
/// │   │   ├── datasource.dart
/// │   │   ├── either.dart
/// │   │   ├── failure.dart
/// │   │   ├── repository.dart
/// │   │   ├── usecase.dart
/// │   │   ├── index.dart
/// │   │   └── CLEAN_ARCHITECTURE_GUIDE.md
/// │   ├── di/
/// │   │   └── service_locator.dart  # Dependency injection setup
/// │   ├── api_service.dart
/// │   ├── error/
/// │   └── ui/
/// │       ├── palette.dart
/// │       ├── app_colors.dart
/// │       └── app_widgets.dart
/// │
/// ├── features/
/// │   ├── diet/
/// │   │   ├── domain/              # Pure business logic
/// │   │   │   ├── entities/
/// │   │   │   │   └── meal_entity.dart
/// │   │   │   ├── repositories/
/// │   │   │   │   └── diet_repository.dart
/// │   │   │   └── usecases/
/// │   │   │       ├── get_meals_usecase.dart
/// │   │   │       ├── add_meal_usecase.dart
/// │   │   │       └── delete_meal_usecase.dart
/// │   │   ├── data/                # Data layer
/// │   │   │   ├── datasources/
/// │   │   │   │   └── diet_local_data_source.dart
/// │   │   │   ├── models/
/// │   │   │   │   └── meal_model.dart
/// │   │   │   └── repositories/
/// │   │   │       └── diet_repository_impl.dart
/// │   │   └── presentation/        # UI layer
/// │   │       ├── screens/
/// │   │       ├── widgets/
/// │   │       └── providers/
/// │   │           └── diet_providers.dart
/// │   │
/// │   ├── history/                 # Similar structure
/// │   │   ├── domain/
/// │   │   ├── data/
/// │   │   └── presentation/
/// │   │
/// │   ├── food_scan/               # Similar structure
/// │   ├── user_profile/            # Similar structure
/// │   └── home/
/// │
/// └── main.dart
/// ```
///
/// ## Key Design Patterns
///
/// ### 1. Clean Architecture Layers
///
/// ```
/// ┌─────────────────────────────────────────────┐
/// │         PRESENTATION LAYER (UI)             │
/// │  - Screens, Widgets, Providers               │
/// │  - No business logic                         │
/// └────────────┬────────────────────────────────┘
///              │ depends on
/// ┌────────────▼────────────────────────────────┐
/// │          USE CASES (Orchestration)          │
/// │  - Business logic                           │
/// │  - Framework independent                    │
/// └────────────┬────────────────────────────────┘
///              │ depends on
/// ┌────────────▼────────────────────────────────┐
/// │     DOMAIN LAYER (Entities/Contracts)       │
/// │  - Business entities                        │
/// │  - Repository interfaces                    │
/// └────────────┬────────────────────────────────┘
///              │ depends on
/// ┌────────────▼────────────────────────────────┐
/// │         DATA LAYER (Implementation)         │
/// │  - Data sources (API, DB, Cache)            │
/// │  - Models, Repository implementations       │
/// │  - External service integration             │
/// └─────────────────────────────────────────────┘
/// ```
///
/// ### 2. Data Flow Example
///
/// Request: User taps "Add Meal" button
/// ```
/// 1. UI Screen calls AddMealUseCase
///    |
/// 2. UseCase validates data and calls Repository.addMeal()
///    |
/// 3. Repository (impl) catches exceptions, converts to Either<Failure, void>
///    |
/// 4. Repository calls DataSource.addMeal()
///    |
/// 5. DataSource handles actual storage (SharedPreferences/API)
///    |
/// 6. Success/Failure bubbles back through chain
///    |
/// 7. UI observes change via Riverpod provider
///    |
/// 8. UI rebuilds with new data
/// ```
///
/// ### 3. Error Handling Pattern
///
/// All operations return `Either<Failure, T>`:
/// - Left side: Failure with error details
/// - Right side: Success with data
///
/// Example:
/// ```dart
/// final result = await addMealUseCase(params);
/// result.fold(
///   (failure) => showError(failure.message),
///   (success) => showSuccess(),
/// );
/// ```
///
/// ### 4. Dependency Injection
///
/// All dependencies are managed by `ServiceLocator` (GetIt):
/// - Centralized setup in `core/di/service_locator.dart`
/// - Initialize once in main()
/// - Access anywhere via `GetIt.instance`
///
/// Example:
/// ```dart
/// void main() {
///   setupServiceLocator();
///   runApp(const MyApp());
/// }
/// ```
///
/// ## Implementation Examples
///
/// ### Creating a New Feature
///
/// 1. **Create Domain Layer**
///    ```dart
///    // entities/product_entity.dart
///    import 'package:food_calorie_frontend/core/architecture/index.dart';
///    
///    class Product extends Entity {
///      final String id;
///      final String name;
///      
///      const Product({required this.id, required this.name});
///    }
///    ```
///
/// 2. **Create Domain Repository**
///    ```dart
///    // repositories/product_repository.dart
///    abstract class ProductRepository extends Repository {
///      Future<Either<Failure, List<Product>>> getProducts();
///    }
///    ```
///
/// 3. **Create UseCases**
///    ```dart
///    // usecases/get_products_usecase.dart
///    class GetProductsUseCase implements UseCase<List<Product>, NoParams> {
///      final ProductRepository _repository;
///      
///      GetProductsUseCase(this._repository);
///      
///      @override
///      Future<Either<Failure, List<Product>>> call(NoParams params) =>
///        _repository.getProducts();
///    }
///    ```
///
/// 4. **Create Data Layer**
///    ```dart
///    // data/models/product_model.dart
///    class ProductModel extends Model<Product> {
///      final String id;
///      final String name;
///      
///      @override
///      Product toEntity() => Product(id: id, name: name);
///      
///      @override
///      Map<String, dynamic> toJson() => {'id': id, 'name': name};
///      
///      factory ProductModel.fromJson(Map<String, dynamic> json) =>
///        ProductModel(id: json['id'], name: json['name']);
///    }
///    ```
///
/// 5. **Create DataSource**
///    ```dart
///    // data/datasources/product_local_data_source.dart
///    class ProductLocalDataSource extends LocalDataSource {
///      Future<List<ProductModel>> getProducts() async {
///        // Implementation
///      }
///    }
///    ```
///
/// 6. **Create Repository Implementation**
///    ```dart
///    // data/repositories/product_repository_impl.dart
///    class ProductRepositoryImpl implements ProductRepository {
///      final ProductLocalDataSource _dataSource;
///      
///      ProductRepositoryImpl(this._dataSource);
///      
///      @override
///      Future<Either<Failure, List<Product>>> getProducts() async {
///        try {
///          final models = await _dataSource.getProducts();
///          return Either.right(models.map((m) => m.toEntity()).toList());
///        } catch (e) {
///          return Either.left(CacheFailure(message: 'Error: $e'));
///        }
///      }
///    }
///    ```
///
/// 7. **Create Riverpod Providers**
///    ```dart
///    // presentation/providers/product_providers.dart
///    final productDataSourceProvider = Provider((ref) =>
///      const ProductLocalDataSource());
///    
///    final productRepositoryProvider = Provider((ref) =>
///      ProductRepositoryImpl(ref.read(productDataSourceProvider)));
///    
///    final getProductsUseCaseProvider = Provider((ref) =>
///      GetProductsUseCase(ref.read(productRepositoryProvider)));
///    ```
///
/// 8. **Use in UI**
///    ```dart
///    // presentation/screens/products_screen.dart
///    class ProductsScreen extends ConsumerWidget {
///      @override
///      Widget build(BuildContext context, WidgetRef ref) {
///        final useCase = ref.read(getProductsUseCaseProvider);
///        
///        return FutureBuilder(
///          future: useCase(NoParams()),
///          builder: (context, snapshot) {
///            return snapshot.data?.fold(
///              (failure) => ErrorWidget(failure.message),
///              (products) => ListView(
///                children: products.map((p) => Text(p.name)).toList(),
///              ),
///            ) ?? LoadingWidget();
///          },
///        );
///      }
///    }
///    ```
///
/// ## Best Practices
///
/// ✅ **Do:**
/// - Keep domain layer framework-independent
/// - Use Either<Failure, T> for error handling
/// - Separate concerns into layers
/// - Make entities immutable
/// - Test business logic in domain layer
/// - Use Riverpod for state management
/// - Create specific UseCase classes
///
/// ❌ **Don't:**
/// - Put UI logic in domain layer
/// - Import flutter in domain layer (except entities)
/// - Mix data and business logic
/// - Throw exceptions across layer boundaries
/// - Create god repositories
/// - Skip error handling
/// - Make entities mutable
///
