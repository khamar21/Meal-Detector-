import 'dart:convert';
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/api_service.dart';

enum PredictionSource { image, voice }

class NutritionBreakdown {
  const NutritionBreakdown({this.protein, this.carbs, this.fat});
  
  final double? protein;
  final double? carbs;
  final double? fat;

  bool get hasData => protein != null || carbs != null || fat != null;

  Map<String, dynamic> toJson() {
    return {'protein': protein, 'carbs': carbs, 'fat': fat};
  }

  factory NutritionBreakdown.fromJson(Map<String, dynamic> json) {
    return NutritionBreakdown(
      protein: _asDouble(json['protein']),
      carbs: _asDouble(json['carbs']),
      fat: _asDouble(json['fat']),
    );
  }
}

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

  Map<String, dynamic> toJson() {
    return {'name': name, 'calories': calories};
  }

  factory IngredientDetail.fromJson(Map<String, dynamic> json) {
    return IngredientDetail(
      name: (json['name'] ?? '').toString(),
      calories: json['calories']?.toString(),
    );
  }
}

class PredictionResult {
  const PredictionResult({
    required this.id,
    required this.food,
    required this.timestamp,
    required this.sourceType,
    this.calories,
    this.caloriesKcal,
    this.confidence,
    this.confidencePercent,
    this.ingredients = const [],
    this.ingredientDetails = const [],
    this.source,
    this.voiceInput,
    this.nutrition = const NutritionBreakdown(),
  });

  final String id;
  final String food;
  final String? calories;
  final double? caloriesKcal;
  final String? confidence;
  final double? confidencePercent;
  final List<String> ingredients;
  final List<IngredientDetail> ingredientDetails;
  final String? source;
  final String? voiceInput;
  final PredictionSource sourceType;
  final NutritionBreakdown nutrition;
  final DateTime timestamp;

  String get confidenceLabel {
    if (confidencePercent == null) {
      return confidence ?? 'N/A';
    }

    final fixed = confidencePercent!.toStringAsFixed(
      confidencePercent! % 1 == 0 ? 0 : 1,
    );
    return '$fixed%';
  }

  String get caloriesLabel {
    if (calories != null && calories!.trim().isNotEmpty) {
      return calories!;
    }
    if (caloriesKcal != null) {
      final fixed = caloriesKcal!.toStringAsFixed(
        caloriesKcal! % 1 == 0 ? 0 : 1,
      );
      return '$fixed kcal';
    }
    return 'N/A';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'food': food,
      'calories': calories,
      'caloriesKcal': caloriesKcal,
      'confidence': confidence,
      'confidencePercent': confidencePercent,
      'ingredients': ingredients,
      'ingredientDetails': ingredientDetails
          .map((item) => item.toJson())
          .toList(),
      'source': source,
      'voiceInput': voiceInput,
      'sourceType': sourceType.name,
      'nutrition': nutrition.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    final rawIngredients = json['ingredients'];
    final rawIngredientDetails = json['ingredientDetails'];

    return PredictionResult(
      id: (json['id'] ?? '').toString(),
      food: (json['food'] ?? 'Unknown').toString(),
      calories: json['calories']?.toString(),
      caloriesKcal: _asDouble(json['caloriesKcal']),
      confidence: json['confidence']?.toString(),
      confidencePercent: _asDouble(json['confidencePercent']),
      ingredients: rawIngredients is Iterable
          ? rawIngredients
                .map((item) => item.toString())
                .toList(growable: false)
          : const [],
      ingredientDetails: rawIngredientDetails is Iterable
          ? rawIngredientDetails
                .whereType<Map>()
                .map(
                  (item) => IngredientDetail.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList(growable: false)
          : const [],
      source: json['source']?.toString(),
      voiceInput: json['voiceInput']?.toString(),
      sourceType: _parseSource((json['sourceType'] ?? '').toString()),
      nutrition: json['nutrition'] is Map
          ? NutritionBreakdown.fromJson(
              Map<String, dynamic>.from(json['nutrition']),
            )
          : const NutritionBreakdown(),
      timestamp:
          DateTime.tryParse((json['timestamp'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}

PredictionSource _parseSource(String value) {
  return value == PredictionSource.voice.name
      ? PredictionSource.voice
      : PredictionSource.image;
}

// State providers
final imageProvider = StateProvider<File?>((ref) => null);
final resultProvider = StateProvider<PredictionResult?>((ref) => null);
final errorProvider = StateProvider<String?>((ref) => null);
final loadingProvider = StateProvider<bool>((ref) => false);
final voiceDraftProvider = StateProvider<String>((ref) => '');
final predictionHistoryProvider = StateProvider<List<PredictionResult>>(
  (ref) => const [],
);

class PredictNotifier extends StateNotifier<void> {
  PredictNotifier(this.ref) : super(null) {
    initialize();
  }

  static const _historyKey = 'scan_history_v2';
  static const _historyLimit = 40;

  final Ref ref;
  final ImagePicker picker = ImagePicker();

  Future<void> initialize() async {
    await _loadHistory();
  }

  Future<void> pickImage(ImageSource source) async {
    final picked = await picker.pickImage(source: source, imageQuality: 95);
    if (picked == null) {
      return;
    }

    final compressed = await _compressImage(File(picked.path));
    ref.read(imageProvider.notifier).state = compressed;
    ref.read(resultProvider.notifier).state = null;
    ref.read(errorProvider.notifier).state = null;
  }

  Future<File> _compressImage(File source) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final target =
          '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final compressed = await FlutterImageCompress.compressAndGetFile(
        source.absolute.path,
        target,
        quality: 72,
        minWidth: 1280,
        minHeight: 1280,
        format: CompressFormat.jpeg,
      );

      return compressed == null ? source : File(compressed.path);
    } catch (_) {
      return source;
    }
  }

  void clearSelection() {
    ref.read(imageProvider.notifier).state = null;
    ref.read(resultProvider.notifier).state = null;
    ref.read(errorProvider.notifier).state = null;
    ref.read(voiceDraftProvider.notifier).state = '';
  }

  Future<void> retryLastPrediction() async {
    final image = ref.read(imageProvider);
    final voiceText = ref.read(voiceDraftProvider).trim();

    if (image != null) {
      await predict();
      return;
    }

    if (voiceText.isNotEmpty) {
      await predictFromVoice(voiceText);
    }
  }

  Future<void> predict() async {
    final image = ref.read(imageProvider);
    if (image == null) {
      return;
    }

    ref.read(loadingProvider.notifier).state = true;
    ref.read(errorProvider.notifier).state = null;

    try {
      final data = await ApiService.predictFood(image);
      _consumePrediction(
        data,
        sourceType: PredictionSource.image,
        imagePath: image.path,
      );
    } catch (e) {
      ref.read(errorProvider.notifier).state = _cleanErrorMessage(e.toString());
      ref.read(resultProvider.notifier).state = null;
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }

  Future<void> predictFromVoice(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty) {
      ref.read(errorProvider.notifier).state =
          'Please provide a food description.';
      return;
    }

    ref.read(voiceDraftProvider.notifier).state = text;
    ref.read(loadingProvider.notifier).state = true;
    ref.read(errorProvider.notifier).state = null;

    try {                    
      final data = await ApiService.predictFoodByText(text);
      _consumePrediction(
        data,
        sourceType: PredictionSource.voice,
        voiceInput: text,
      );
    } catch (e) {
      ref.read(errorProvider.notifier).state = _cleanErrorMessage(e.toString());
      ref.read(resultProvider.notifier).state = null;
    } finally {
      ref.read(loadingProvider.notifier).state = false;
    }
  }

  void _consumePrediction(
    Map<String, dynamic> data, {
    required PredictionSource sourceType,
    String? imagePath,
    String? voiceInput,
  }) {
    final payload = _resolvePredictionPayload(data);
    final food =
        _readValue(payload, const [
          'food',
          'label',
          'class',
          'prediction',
          'name',
        ]) ??
        'Unknown';

    final caloriesRaw = _readValue(payload, const [
      'calories',
      'calorie',
      'kcal',
      'energy',
    ]);
    final confidenceRaw = _readValue(payload, const [
      'confidence',
      'probability',
      'score',
    ]);

    final ingredientDetails = _parseIngredientDetails(payload);
    final ingredients = ingredientDetails.isNotEmpty
        ? ingredientDetails.map((item) => item.name).toList(growable: false)
        : _formatIngredients(
            payload['ingredients'] ?? payload['ingredient'] ?? payload['items'],
          );

    final result = PredictionResult(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      food: food,
      calories: _formatCalories(caloriesRaw),
      caloriesKcal: _parseNumber(caloriesRaw),
      confidence: _formatConfidence(confidenceRaw),
      confidencePercent: _parseConfidenceValue(confidenceRaw),
      ingredients: ingredients,
      ingredientDetails: ingredientDetails,
      source: imagePath,
      voiceInput: voiceInput,
      sourceType: sourceType,
      nutrition: _parseNutrition(payload),
      timestamp: DateTime.now(),
    );

    ref.read(resultProvider.notifier).state = result;
    ref.read(errorProvider.notifier).state = null;

    final updated = [result, ...ref.read(predictionHistoryProvider)]
        .fold<List<PredictionResult>>(<PredictionResult>[], (acc, item) {
          final alreadyExists = acc.any((entry) => entry.id == item.id);
          if (!alreadyExists) {
            acc.add(item);
          }
          return acc;
        })
        .take(_historyLimit)
        .toList(growable: false);
        ref.read(predictionHistoryProvider.notifier).state = updated;
    _saveHistory(updated);
  }

  Future<void> deleteHistoryItem(String id) async {
    final updated = ref
        .read(predictionHistoryProvider)
        .where((item) => item.id != id)
        .toList();
    ref.read(predictionHistoryProvider.notifier).state = updated;
    await _saveHistory(updated);
  }

  Future<void> clearHistory() async {
    ref.read(predictionHistoryProvider.notifier).state = const [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_historyKey);
      if (raw == null || raw.trim().isEmpty) {
        return;
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return;
      }

      final history = decoded
          .whereType<Map>()
          .map(
            (item) =>
                PredictionResult.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false);

      ref.read(predictionHistoryProvider.notifier).state = history;
    } catch (_) {
      // Keep app usable even if local history cannot be decoded.
    }
  }

  Future<void> _saveHistory(List<PredictionResult> history) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = history
        .map((item) => item.toJson())
        .toList(growable: false);
    await prefs.setString(_historyKey, jsonEncode(payload));
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
    if (value == null) {
      return null;
    }

    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    return trimmed.toLowerCase().contains('cal') ? trimmed : '$trimmed kcal';
  }

  String? _formatConfidence(String? value) {
    final numeric = _parseConfidenceValue(value);
    if (numeric == null) {
      return value;
    }

    final fixed = numeric.toStringAsFixed(numeric % 1 == 0 ? 0 : 1);
    return '$fixed%';
  }

  double? _parseConfidenceValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final parsed = _parseNumber(value);
    if (parsed == null) {
      return null;
    }

    return parsed <= 1 ? parsed * 100 : parsed;
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
          .toList(growable: false);
    }

    if (value is Iterable) {
      return value
          .map((item) => item.toString().trim())
          .map(_stripWrapperCharacters)
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
    }

    final text = _stripWrapperCharacters(value.toString().trim());
    if (text.isEmpty) {
      return const [];
    }

    return text
        .split(RegExp(r'[\n,;|]+'))
        .map((item) => item.trim())
        .map(_stripWrapperCharacters)
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  NutritionBreakdown _parseNutrition(Map<String, dynamic> data) {
    final nutritionMap = _firstMap(data, const [
      'nutrition',
      'nutrients',
      'macros',
      'macro_breakdown',
    ]);

    final source = nutritionMap ?? data;

    final protein = _parseNumber(
      _readValue(source, const ['protein', 'protein_g', 'proteins']),
    );
    final carbs = _parseNumber(
      _readValue(source, const ['carbs', 'carbohydrates', 'carb_g']),
    );
    final fat = _parseNumber(
      _readValue(source, const ['fat', 'fats', 'fat_g']),
    );

    return NutritionBreakdown(protein: protein, carbs: carbs, fat: fat);
  }

  Map<String, dynamic>? _firstMap(
    Map<String, dynamic> data,
    List<String> keys,
  ) {    
    for (final key in keys) {
      final candidate = data[key];
      if (candidate is Map<String, dynamic>) {
        return candidate;
      }
      if (candidate is Map) {
        return Map<String, dynamic>.from(candidate);
      }
    }
    return null;
  }

  double? _parseNumber(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }

    final normalized = raw.replaceAll(',', '.');
    final direct = double.tryParse(normalized);
    if (direct != null) {
      return direct;
    }

    final match = RegExp(r'-?\d+(\.\d+)?').firstMatch(normalized);
    if (match == null) {
      return null;
    }

    return double.tryParse(match.group(0)!);
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

  String _cleanErrorMessage(String raw) {
    return raw.replaceFirst('Exception: ', '').trim();
  }
}

double? _asDouble(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value.toString());
}

// Notifier provider
final predictNotifierProvider = StateNotifierProvider<PredictNotifier, void>(
  (ref) => PredictNotifier(ref),
);
