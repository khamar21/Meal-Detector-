/// Either type representing a value of one of two possible types (a disjoint union).
/// Instances of Either are either an instance of Left or Right.
/// Left is used for failure/error states, Right for success states.
abstract class Either<L, R> {
  const Either();

  /// Map over the right value
  Either<L, T> map<T>(T Function(R) f);

  /// Map over the left value
  Either<T, R> mapLeft<T>(T Function(L) f);

  /// Fold the either into a single value based on which side it is
  T fold<T>(T Function(L) ifLeft, T Function(R) ifRight);

  /// Check if this is a Left (failure)
  bool get isLeft => this is _Left<L, R>;

  /// Check if this is a Right (success)
  bool get isRight => this is _Right<L, R>;
}

/// Left side of Either - represents failure state
class _Left<L, R> extends Either<L, R> {
  final L value;

  const _Left(this.value);

  @override
  Either<L, T> map<T>(T Function(R) f) => _Left<L, T>(value);

  @override
  Either<T, R> mapLeft<T>(T Function(L) f) => _Left<T, R>(f(value));

  @override
  T fold<T>(T Function(L) ifLeft, T Function(R) ifRight) => ifLeft(value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _Left<L, R> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

/// Right side of Either - represents success state
class _Right<L, R> extends Either<L, R> {
  final R value;

  const _Right(this.value);

  @override
  Either<L, T> map<T>(T Function(R) f) => _Right<L, T>(f(value));

  @override
  Either<T, R> mapLeft<T>(T Function(L) f) => _Right<T, R>(value);

  @override
  T fold<T>(T Function(L) ifLeft, T Function(R) ifRight) => ifRight(value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _Right<L, R> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

/// Factory constructors for Either
extension EitherFactories<L, R> on Either<L, R> {
  /// Create a Left (failure) instance
  static Either<L, R> left<L, R>(L value) => _Left<L, R>(value);

  /// Create a Right (success) instance
  static Either<L, R> right<L, R>(R value) => _Right<L, R>(value);
}
