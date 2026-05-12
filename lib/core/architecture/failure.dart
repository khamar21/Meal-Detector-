/// Base class for all failures/errors in the application.
/// Follows a consistent error handling pattern across the app.
abstract class Failure {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const Failure({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() => message;
}

/// Failure when the API returns an error
class ApiFailure extends Failure {
  const ApiFailure({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Failure for local storage/cache issues
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Failure for network connectivity issues
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Failure for validation errors
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Generic failure for unexpected errors
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}

/// Failure for not found errors
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });
}
