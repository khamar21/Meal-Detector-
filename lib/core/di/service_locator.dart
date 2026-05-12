/// Service Locator - Note: This app uses Riverpod for dependency injection
/// instead of GetIt. See the presentation/providers files for the actual setup.
/// Service Locator for dependency injection.
/// 
/// This app uses Riverpod for dependency management.
/// All dependencies are registered in their respective feature's providers.dart files.
/// 
/// Example:
/// - History dependencies: features/history/presentation/providers/history_providers.dart
/// - Diet dependencies: features/diet/presentation/providers/diet_providers.dart
/// 
/// Usage in your app:
/// ```dart
/// @override
/// Widget build(BuildContext context, WidgetRef ref) {
///   final useCase = ref.read(getHistoryUseCaseProvider);
///   // Use the usecase
/// }
/// ```

// Provider imports are handled in feature-specific provider files
// This file serves as documentation for the DI pattern
