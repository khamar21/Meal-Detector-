import 'either.dart';
import 'failure.dart';

/// Base class for all use cases.
/// Use cases contain the business logic and orchestrate data flow between repositories.
abstract class UseCase<Type, Params> {
  /// Execute the use case with the given parameters.
  /// Returns Either<Failure, Type> to handle errors and success uniformly.
  Future<Either<Failure, Type>> call(Params params);
}

/// Use case parameters for operations that don't require input.
class NoParams {
  const NoParams();

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => runtimeType.hashCode;
}
