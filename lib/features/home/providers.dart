import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/api_service.dart';

class IngredientDetail {
  const IngredientDetail({required this.name, this.calories});

  final String name;
  final String? calories;

  String get displayLabel {
    if (calories == null || calories!.isEmpty) {
      return name;
    }
    return '$name (${calories!})';
  }
}

class PredictionResult {
  const PredictionResult({
    required this.food,
    required this.timestamp,
    this.calories,
    this.confidence,
    this.ingredients = const [],
    this.ingredientDetails = const [],
    this.source,
  });

  final String food;
  final String? calories;
  final String? confidence;
  final List<String> ingredients;
  final List<IngredientDetail> ingredientDetails;
  final String? source;
  final DateTime timestamp;

  String get summary {
    final lines = <String>['Food: $food'];

    if (calories != null && calories!.isNotEmpty) {
      lines.add('Calories: $calories');
    }

    if (confidence != null && confidence!.isNotEmpty) {
      lines.add('Confidence: $confidence');
    }

    if (ingredients.isNotEmpty) {
      lines.add('Ingredients: ${ingredients.join(', ')}');
    }

    if (ingredientDetails.isNotEmpty) {
      lines.add(
        'Ingredient calories: ${ingredientDetails.map((item) => item.displayLabel).join(', ')}',
      );
    }

    return lines.join('\n');
  }
}

// State providers
final imageProvider = StateProvider<File?>((ref) => null);
final resultProvider = StateProvider<PredictionResult?>((ref) => null);
final errorProvider = StateProvider<String?>((ref) => null);
final loadingProvider = StateProvider<bool>((ref) => false);
final predictionHistoryProvider = StateProvider<List<PredictionResult>>(
  (ref) => const [],
);

// Notifier for image picking and prediction
class PredictNotifier extends StateNotifier<void> {
  PredictNotifier(this.ref) : super(null);

  final Ref ref;
  final ImagePicker picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    ref.read(imageProvider.notifier).state = File(picked.path);
    ref.read(resultProvider.notifier).state = null;
    ref.read(errorProvider.notifier).state = null;
  }

  void clearSelection() {
    ref.read(imageProvider.notifier).state = null;
    ref.read(resultProvider.notifier).state = null;
    ref.read(errorProvider.notifier).state = null;
  }

  Future<void> predict() async {
    final image = ref.read(imageProvider);
    if (image == null) return;

    ref.read(loadingProvider.notifier).state = true;
    try {
      final data = await ApiService.predictFood(image);
      final payload = _resolvePredictionPayload(data);
      final food =
          _readValue(payload, const ['food', 'label', 'class', 'prediction']) ??
          'Unknown';
      final calories = _formatCalories(
        _readValue(payload, const ['calories', 'calorie', 'kcal']),
      );
      final confidence = _formatConfidence(
        _readValue(payload, const ['confidence', 'probability', 'score']),
      );
      final ingredientDetails = _parseIngredientDetails(payload);
      final ingredients = ingredientDetails.isNotEmpty
          ? ingredientDetails.map((item) => item.name).toList(growable: false)
          : _formatIngredients(
              payload['ingredients'] ??
                  payload['ingredient'] ??
                  payload['items'],
            );

      final result = PredictionResult(
        food: food,
        calories: calories,
        confidence: confidence,
        ingredients: ingredients,
        ingredientDetails: ingredientDetails,
        source: image.path,
        timestamp: DateTime.now(),
      );

      ref.read(resultProvider.notifier).state = result;
      ref.read(errorProvider.notifier).state = null;

      final history = <PredictionResult>[
        result,
        ...ref.read(predictionHistoryProvider),
      ];
      ref.read(predictionHistoryProvider.notifier).state = history
          .take(5)
          .toList();
    } catch (e) {
      ref.read(errorProvider.notifier).state = e.toString();
      ref.read(resultProvider.notifier).state = null;
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }

  Map<String, dynamic> _resolvePredictionPayload(Map<String, dynamic> data) {
    final nestedCandidates = [
      data['data'],
      data['result'],
      data['prediction'],
      data['output'],
    ];

    for (final candidate in nestedCandidates) {
      if (candidate is Map<String, dynamic>) {
        return candidate;
      }
      if (candidate is Map) {
        return Map<String, dynamic>.from(candidate);
      }
    }

    return data;
  }

  String? _readValue(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }

  String? _formatCalories(String? value) {
    if (value == null) return null;

    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return trimmed.toLowerCase().contains('cal') ? trimmed : '$trimmed cal';
  }

  String? _formatConfidence(String? value) {
    if (value == null) return null;

    final parsed = double.tryParse(value.replaceAll('%', '').trim());
    if (parsed == null) return value;

    final percent = parsed <= 1 ? parsed * 100 : parsed;
    final formatted = percent.toStringAsFixed(percent % 1 == 0 ? 0 : 1);
    return '$formatted%';
  }

  List<String> _formatIngredients(dynamic value) {
    if (value == null) {
      return const [];
    }

    if (value is Map) {
      return value.values
          .map((item) => item.toString().trim())
          .map(_stripWrapperCharacters)
          .where((item) => item.isNotEmpty)
          .toList();
    }

    if (value is Iterable) {
      return value
          .map((item) => item.toString().trim())
          .map(_stripWrapperCharacters)
          .where((item) => item.isNotEmpty)
          .toList();
    }

    final text = _stripWrapperCharacters(value.toString().trim());
    if (text.isEmpty) {
      return const [];
    }

    return text
        .split(RegExp(r'[\n,;•]+'))
        .map((item) => item.trim())
        .map(_stripWrapperCharacters)
        .where((item) => item.isNotEmpty)
        .toList();
  }

  String _stripWrapperCharacters(String value) {
    return value
        .replaceAll(RegExp(r'^[\[{(\s]+'), '')
        .replaceAll(RegExp(r'[\]})\s]+$'), '')
        .replaceAll(RegExp(r'^"|"$'), '')
        .replaceAll(RegExp(r"^'|'$"), '')
        .trim();
  }

  List<IngredientDetail> _parseIngredientDetails(Map<String, dynamic> data) {
    final result = <IngredientDetail>[];

    void addDetail(String rawName, dynamic rawCalories) {
      final name = _stripWrapperCharacters(rawName);
      if (name.isEmpty) {
        return;
      }

      result.add(
        IngredientDetail(
          name: name,
          calories: _formatCalories(rawCalories?.toString()),
        ),
      );
    }

    final ingredientsRaw = data['ingredients'];
    if (ingredientsRaw is Iterable) {
      for (final item in ingredientsRaw) {
        if (item is Map) {
          final name = _readFirstMapValue(item, const [
            'name',
            'ingredient',
            'item',
            'food',
            'label',
          ]);
          final calories = _readFirstMapValue(item, const [
            'calories',
            'calorie',
            'kcal',
            'energy',
          ]);

          if (name != null) {
            addDetail(name, calories);
          }
        } else {
          addDetail(item.toString(), null);
        }
      }
    }

    final mapCandidates = [
      data['ingredient_calories'],
      data['ingredients_calories'],
      data['ingredients_with_calories'],
    ];

    for (final candidate in mapCandidates) {
      if (candidate is Map) {
        candidate.forEach((key, value) {
          final keyName = key.toString();
          if (keyName.trim().isEmpty) {
            return;
          }

          final existingIndex = result.indexWhere(
            (item) => item.name.toLowerCase() == keyName.toLowerCase(),
          );

          final parsedCalories = _formatCalories(value?.toString());
          if (existingIndex >= 0) {
            final existing = result[existingIndex];
            result[existingIndex] = IngredientDetail(
              name: existing.name,
              calories: existing.calories ?? parsedCalories,
            );
          } else {
            addDetail(keyName, value);
          }
        });
      }
    }

    return result;
  }

  String? _readFirstMapValue(Map map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }
    return null;
  }
}

// Notifier provider
final predictNotifierProvider = StateNotifierProvider<PredictNotifier, void>(
  (ref) => PredictNotifier(ref),
);
