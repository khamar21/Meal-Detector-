import 'base_entity.dart';

/// Base class for all data models.
/// Models are responsible for converting between external data (API, DB) and entities.
abstract class Model<T extends Entity> {
  const Model();

  /// Convert the model to an entity (data layer -> domain layer)
  T toEntity();

  /// Convert JSON to a model (typically used with fromJson factory)
  /// This is a template method that should be implemented by subclasses
  factory Model.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('Subclasses must implement fromJson');
  }

  /// Convert the model to JSON (domain -> data layer for transmission)
  Map<String, dynamic> toJson();
}
