/// Base class for all domain entities.
/// Entities are pure Dart objects that represent core business logic.
abstract class Entity {
  const Entity();

  /// Override this method to provide equality comparison based on entity properties
  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => runtimeType.hashCode;
}
