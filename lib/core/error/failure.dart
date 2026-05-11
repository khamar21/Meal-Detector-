abstract class Failure {
  const Failure([this.message = '']);

  final String message;

  @override
  String toString() => message.isEmpty ? runtimeType.toString() : message;
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local cache operation failed.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Validation failed.']);
}
