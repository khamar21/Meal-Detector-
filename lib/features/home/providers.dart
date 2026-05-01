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
  const IngredientDetail({
    required this.name,
    this.calories,
    this.confidence,
    this.confidencePercent,
  });

  final String name;
  final String? calories;
  final String? confidence;
  final double? confidencePercent;

  String get caloriesLabel {
    if (calories == null || calories!.isEmpty) {
      return 'N/A';
    }
    return calories!;
  }

  String get confidenceLabel {
    if (confidencePercent != null) {
      final fixed = confidencePercent!.toStringAsFixed(
        confidencePercent! % 1 == 0 ? 0 : 1,
      );
      return '$fixed%';
    }
    return confidence?.trim().isNotEmpty == true ? confidence! : 'N/A';
  }

  String get displayLabel {
    final parts = <String>[name];
    if (calories != null && calories!.trim().isNotEmpty) {
      parts.add(calories!);
    }
    if (confidence != null && confidence!.trim().isNotEmpty) {
      parts.add(confidenceLabel);
    }
    return parts.join(' • ');
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'calories': calories,
      'confidence': confidence,
      'confidencePercent': confidencePercent,
    };
  }

  factory IngredientDetail.fromJson(Map<String, dynamic> json) {
    return IngredientDetail(
      name: (json['name'] ?? '').toString(),
      calories: json['calories']?.toString(),
      confidence: json['confidence']?.toString(),
      confidencePercent: _asDouble(json['confidencePercent']),
    );
  }
}

class HealthierAlternative {
  const HealthierAlternative({
    required this.name,
    this.calories,
    this.reductionPercent,
    this.benefit,
  });

  final String name;
  final String? calories;
  final double? reductionPercent;
  final String? benefit;

  String get caloriesLabel {
    if (calories == null || calories!.trim().isEmpty) {
      return 'N/A';
    }
    return calories!;
  }

  String get reductionLabel {
    if (reductionPercent == null) {
      return 'N/A';
    }

    final fixed = reductionPercent!.toStringAsFixed(
      reductionPercent! % 1 == 0 ? 0 : 1,
    );
    return '$fixed%';
  }

  factory HealthierAlternative.fromJson(Map<String, dynamic> json) {
    return HealthierAlternative(
      name: (json['name'] ?? json['food'] ?? json['label'] ?? 'Alternative')
          .toString(),
      calories: json['calories']?.toString(),
      reductionPercent: _asDouble(
        json['reductionPercent'] ?? json['reduction'],
      ),
      benefit: json['benefit']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'calories': calories,
      'reductionPercent': reductionPercent,
      'benefit': benefit,
    };
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
    this.portionMultiplier,
    this.adjustedCalories,
    this.adjustedCaloriesKcal,
    this.adjustedNutrition = const NutritionBreakdown(),
    this.alternatives = const [],
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
  final double? portionMultiplier;
  final String? adjustedCalories;
  final double? adjustedCaloriesKcal;
  final NutritionBreakdown adjustedNutrition;
  final List<HealthierAlternative> alternatives;
  final DateTime timestamp;

  bool get hasAlternatives => alternatives.isNotEmpty;

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

  String get adjustedCaloriesLabel {
    if (adjustedCalories != null && adjustedCalories!.trim().isNotEmpty) {
      return adjustedCalories!;
    }
    if (adjustedCaloriesKcal != null) {
      final fixed = adjustedCaloriesKcal!.toStringAsFixed(
        adjustedCaloriesKcal! % 1 == 0 ? 0 : 1,
      );
      return '$fixed kcal';
    }
    return 'Not calculated yet';
  }

  bool get hasAdjustedData {
    return adjustedCalories != null ||
        adjustedCaloriesKcal != null ||
        adjustedNutrition.hasData;
  }

  PredictionResult copyWith({
    String? id,
    String? food,
    String? calories,
    double? caloriesKcal,
    String? confidence,
    double? confidencePercent,
    List<String>? ingredients,
    List<IngredientDetail>? ingredientDetails,
    String? source,
    String? voiceInput,
    PredictionSource? sourceType,
    NutritionBreakdown? nutrition,
    DateTime? timestamp,
    double? portionMultiplier,
    String? adjustedCalories,
    double? adjustedCaloriesKcal,
    NutritionBreakdown? adjustedNutrition,
    List<HealthierAlternative>? alternatives,
  }) {
    return PredictionResult(
      id: id ?? this.id,
      food: food ?? this.food,
      calories: calories ?? this.calories,
      caloriesKcal: caloriesKcal ?? this.caloriesKcal,
      confidence: confidence ?? this.confidence,
      confidencePercent: confidencePercent ?? this.confidencePercent,
      ingredients: ingredients ?? this.ingredients,
      ingredientDetails: ingredientDetails ?? this.ingredientDetails,
      source: source ?? this.source,
      voiceInput: voiceInput ?? this.voiceInput,
      sourceType: sourceType ?? this.sourceType,
      nutrition: nutrition ?? this.nutrition,
      timestamp: timestamp ?? this.timestamp,
      portionMultiplier: portionMultiplier ?? this.portionMultiplier,
      adjustedCalories: adjustedCalories ?? this.adjustedCalories,
      adjustedCaloriesKcal: adjustedCaloriesKcal ?? this.adjustedCaloriesKcal,
      adjustedNutrition: adjustedNutrition ?? this.adjustedNutrition,
      alternatives: alternatives ?? this.alternatives,
    );
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
      'portionMultiplier': portionMultiplier,
      'adjustedCalories': adjustedCalories,
      'adjustedCaloriesKcal': adjustedCaloriesKcal,
      'adjustedNutrition': adjustedNutrition.toJson(),
      'alternatives': alternatives.map((item) => item.toJson()).toList(),
    };
  }

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    final rawIngredients = json['ingredients'];
    final rawIngredientDetails = json['ingredientDetails'];
    final rawAlternatives = json['alternatives'];

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
      portionMultiplier: _asDouble(json['portionMultiplier']),
      adjustedCalories: json['adjustedCalories']?.toString(),
      adjustedCaloriesKcal: _asDouble(json['adjustedCaloriesKcal']),
      adjustedNutrition: json['adjustedNutrition'] is Map
          ? NutritionBreakdown.fromJson(
              Map<String, dynamic>.from(json['adjustedNutrition']),
            )
          : const NutritionBreakdown(),
      alternatives: rawAlternatives is Iterable
          ? rawAlternatives
                .whereType<Map>()
                .map(
                  (item) => HealthierAlternative.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList(growable: false)
          : const [],
    );
  }
}

class BatchPredictionItem {
  const BatchPredictionItem({
    required this.id,
    required this.image,
    this.result,
    this.error,
  });

  final String id;
  final File image;
  final PredictionResult? result;
  final String? error;

  bool get isSuccess => result != null;
}

PredictionSource _parseSource(String value) {
  return value == PredictionSource.voice.name
      ? PredictionSource.voice
      : PredictionSource.image;
}

final imageProvider = StateProvider<File?>((ref) => null);
final batchImagesProvider = StateProvider<List<File>>((ref) => const []);
final batchModeProvider = StateProvider<bool>((ref) => false);
final resultProvider = StateProvider<PredictionResult?>((ref) => null);
final batchResultsProvider = StateProvider<List<BatchPredictionItem>>(
  (ref) => const [],
);
final errorProvider = StateProvider<String?>((ref) => null);
final loadingProvider = StateProvider<bool>((ref) => false);
final processingLabelProvider = StateProvider<String?>((ref) => null);
final voiceDraftProvider = StateProvider<String>((ref) => '');
final portionMultiplierProvider = StateProvider<double>((ref) => 1.0);
final predictionHistoryProvider = StateProvider<List<PredictionResult>>(
  (ref) => const [],
);

class PredictNotifier extends StateNotifier<void> {
  PredictNotifier(this.ref) : super(null) {
    initialize();
  }

  static const _historyKey = 'scan_history_v3';
  static const _historyLimit = 40;
  static const _maxUploadSizeBytes = 15 * 1024 * 1024;
  static const _allowedExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp',
    'heic',
    'heif',
  ];

  final Ref ref;
  final ImagePicker picker = ImagePicker();

  Future<void> initialize() async {
    await _loadHistory();
  }

  Future<void> setBatchMode(bool enabled) async {
    ref.read(batchModeProvider.notifier).state = enabled;
    ref.read(errorProvider.notifier).state = null;
    ref.read(resultProvider.notifier).state = null;

    if (!enabled) {
      ref.read(batchImagesProvider.notifier).state = const [];
      ref.read(batchResultsProvider.notifier).state = const [];
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final picked = await picker.pickImage(source: source, imageQuality: 95);
    if (picked == null) {
      return;
    }

    final compressed = await _compressImage(File(picked.path));
    final validationError = await _validateUploadFile(compressed);
    if (validationError != null) {
      ref.read(errorProvider.notifier).state = validationError;
      return;
    }

    ref.read(imageProvider.notifier).state = compressed;
    ref.read(resultProvider.notifier).state = null;
    ref.read(batchResultsProvider.notifier).state = const [];
    ref.read(errorProvider.notifier).state = null;
  }

  Future<void> pickBatchImages() async {
    final picked = await picker.pickMultiImage(imageQuality: 95);
    if (picked.isEmpty) {
      return;
    }

    final compressedFiles = await Future.wait(
      picked.map((item) => _compressImage(File(item.path))),
    );

    final current = List<File>.from(ref.read(batchImagesProvider));
    for (final file in compressedFiles) {
      final validationError = await _validateUploadFile(file);
      if (validationError != null) {
        ref.read(errorProvider.notifier).state = validationError;
        return;
      }

      final alreadyAdded = current.any(
        (existing) => existing.path == file.path,
      );
      if (!alreadyAdded) {
        current.add(file);
      }
    }

    ref.read(batchImagesProvider.notifier).state = current;
    ref.read(resultProvider.notifier).state = null;
    ref.read(errorProvider.notifier).state = null;
  }

  void removeBatchImage(String path) {
    final updated = ref
        .read(batchImagesProvider)
        .where((item) => item.path != path)
        .toList(growable: false);
    ref.read(batchImagesProvider.notifier).state = updated;
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

  Future<String?> _validateUploadFile(File file) async {
    final extension = _fileExtension(file.path);
    if (extension == null || !_allowedExtensions.contains(extension)) {
      return 'Please choose a JPG, PNG, or WEBP image.';
    }

    try {
      final size = await file.length();
      if (size > _maxUploadSizeBytes) {
        return 'File is too large. Please choose an image under 15 MB.';
      }
    } catch (_) {
      return 'Could not read the selected image.';
    }

    return null;
  }

  String? _fileExtension(String path) {
    final index = path.lastIndexOf('.');
    if (index < 0 || index == path.length - 1) {
      return null;
    }

    return path.substring(index + 1).toLowerCase();
  }

  void clearSelection() {
    ref.read(imageProvider.notifier).state = null;
    ref.read(batchImagesProvider.notifier).state = const [];
    ref.read(resultProvider.notifier).state = null;
    ref.read(batchResultsProvider.notifier).state = const [];
    ref.read(errorProvider.notifier).state = null;
    ref.read(voiceDraftProvider.notifier).state = '';
    ref.read(portionMultiplierProvider.notifier).state = 1.0;
  }

  Future<void> retryLastPrediction() async {
    final batchImages = ref.read(batchImagesProvider);
    final image = ref.read(imageProvider);
    final voiceText = ref.read(voiceDraftProvider).trim();

    if (ref.read(batchModeProvider) && batchImages.isNotEmpty) {
      await predict();
      return;
    }

    if (image != null) {
      await predict();
      return;
    }

    if (voiceText.isNotEmpty) {
      await predictFromVoice(voiceText);
    }
  }

  Future<void> predict() async {
    if (ref.read(batchModeProvider)) {
      await predictBatch();
      return;
    }

    final image = ref.read(imageProvider);
    if (image == null) {
      return;
    }

    ref.read(loadingProvider.notifier).state = true;
    ref.read(processingLabelProvider.notifier).state =
        'Analyzing your food image...';
    ref.read(errorProvider.notifier).state = null;

    try {
      final data = await ApiService.predictFood(image);
      final result = _buildPredictionResult(
        data,
        sourceType: PredictionSource.image,
        imagePath: image.path,
      );
      _storeSingleResult(result);
    } catch (e) {
      ref.read(errorProvider.notifier).state = _cleanErrorMessage(e.toString());
      ref.read(resultProvider.notifier).state = null;
    } finally {
      ref.read(loadingProvider.notifier).state = false;
      ref.read(processingLabelProvider.notifier).state = null;
    }
  }

  Future<void> predictBatch() async {
    final images = ref.read(batchImagesProvider);
    if (images.isEmpty) {
      ref.read(errorProvider.notifier).state = 'Add at least one image first.';
      return;
    }

    ref.read(loadingProvider.notifier).state = true;
    ref.read(processingLabelProvider.notifier).state =
        'Analyzing ${images.length} images...';
    ref.read(errorProvider.notifier).state = null;

    try {
      final data = await ApiService.predictFoodBatch(images);
      final batchItems = <BatchPredictionItem>[];
      final successfulResults = <PredictionResult>[];

      for (var index = 0; index < images.length; index++) {
        final image = images[index];
        final payload = index < data.length ? data[index] : <String, dynamic>{};
        final errorMessage = _readValue(payload, const [
          'error',
          'detail',
          'message',
        ]);

        if (errorMessage != null && errorMessage.trim().isNotEmpty) {
          batchItems.add(
            BatchPredictionItem(
              id: '${DateTime.now().microsecondsSinceEpoch}-$index',
              image: image,
              error: _cleanErrorMessage(errorMessage),
            ),
          );
          continue;
        }

        final result = _buildPredictionResult(
          payload,
          sourceType: PredictionSource.image,
          imagePath: image.path,
        );
        successfulResults.add(result);
        batchItems.add(
          BatchPredictionItem(id: result.id, image: image, result: result),
        );
      }

      ref.read(batchResultsProvider.notifier).state = batchItems;
      ref.read(resultProvider.notifier).state = null;
      ref.read(errorProvider.notifier).state = null;
      _saveResultsToHistory(successfulResults);
    } catch (e) {
      ref.read(errorProvider.notifier).state = _cleanErrorMessage(e.toString());
      ref.read(batchResultsProvider.notifier).state = const [];
    } finally {
      ref.read(loadingProvider.notifier).state = false;
      ref.read(processingLabelProvider.notifier).state = null;
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
    ref.read(processingLabelProvider.notifier).state =
        'Analyzing your voice input...';
    ref.read(errorProvider.notifier).state = null;

    try {
      final data = await ApiService.predictFoodByText(text);
      final result = _buildPredictionResult(
        data,
        sourceType: PredictionSource.voice,
        voiceInput: text,
      );
      _storeSingleResult(result);
    } catch (e) {
      ref.read(errorProvider.notifier).state = _cleanErrorMessage(e.toString());
      ref.read(resultProvider.notifier).state = null;
    } finally {
      ref.read(loadingProvider.notifier).state = false;
      ref.read(processingLabelProvider.notifier).state = null;
    }
  }

  Future<void> adjustPortion(double multiplier) async {
    final current = ref.read(resultProvider);
    if (current == null) {
      return;
    }

    ref.read(loadingProvider.notifier).state = true;
    ref.read(processingLabelProvider.notifier).state =
        'Updating portion calories...';
    ref.read(errorProvider.notifier).state = null;
    ref.read(portionMultiplierProvider.notifier).state = multiplier;

    try {
      final data = await ApiService.adjustPortion(
        foodName: current.food,
        multiplier: multiplier,
        prediction: current.toJson(),
      );

      final payload = _resolvePredictionPayload(data);
      final adjustedCaloriesRaw = _readValue(payload, const [
        'adjustedCalories',
        'adjusted_calories',
        'calories',
        'kcal',
      ]);
      final adjustedNutrition = _parseNutrition(
        payload,
        keys: const [
          'adjustedNutrition',
          'adjusted_nutrition',
          'nutrition',
          'nutrients',
        ],
      );

      final updated = current.copyWith(
        portionMultiplier: multiplier,
        adjustedCalories: _formatCalories(adjustedCaloriesRaw),
        adjustedCaloriesKcal: _parseNumber(adjustedCaloriesRaw),
        adjustedNutrition: adjustedNutrition,
      );
      _storeSingleResult(updated);
    } catch (e) {
      ref.read(errorProvider.notifier).state = _cleanErrorMessage(e.toString());
    } finally {
      ref.read(loadingProvider.notifier).state = false;
      ref.read(processingLabelProvider.notifier).state = null;
    }
  }

  Future<void> loadHealthierAlternatives() async {
    final current = ref.read(resultProvider);
    if (current == null) {
      return;
    }

    ref.read(loadingProvider.notifier).state = true;
    ref.read(processingLabelProvider.notifier).state =
        'Loading healthier options...';
    ref.read(errorProvider.notifier).state = null;

    try {
      final data = await ApiService.healthierAlternatives(current.food);
      final alternatives = data
          .map(HealthierAlternative.fromJson)
          .toList(growable: false);
      final updated = current.copyWith(alternatives: alternatives);
      _storeSingleResult(updated);
    } catch (e) {
      ref.read(errorProvider.notifier).state = _cleanErrorMessage(e.toString());
    } finally {
      ref.read(loadingProvider.notifier).state = false;
      ref.read(processingLabelProvider.notifier).state = null;
    }
  }

  PredictionResult _buildPredictionResult(
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

    return PredictionResult(
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
      portionMultiplier: _asDouble(payload['portionMultiplier']),
      adjustedCalories: _formatCalories(
        _readValue(payload, const ['adjustedCalories', 'adjusted_calories']),
      ),
      adjustedCaloriesKcal: _parseNumber(
        _readValue(payload, const ['adjustedCalories', 'adjusted_calories']),
      ),
      adjustedNutrition: _parseNutrition(
        payload,
        keys: const ['adjustedNutrition', 'adjusted_nutrition'],
      ),
      alternatives: _parseAlternatives(payload),
    );
  }

  void _storeSingleResult(PredictionResult result) {
    ref.read(resultProvider.notifier).state = result;
    ref.read(errorProvider.notifier).state = null;
    _saveResultsToHistory([result]);
  }

  void _saveResultsToHistory(List<PredictionResult> results) {
    if (results.isEmpty) {
      return;
    }

    final merged =
        <PredictionResult>[...results, ...ref.read(predictionHistoryProvider)]
            .fold<List<PredictionResult>>(<PredictionResult>[], (acc, item) {
              final alreadyExists = acc.any((entry) => entry.id == item.id);
              if (!alreadyExists) {
                acc.add(item);
              }
              return acc;
            })
            .take(_historyLimit)
            .toList(growable: false);

    ref.read(predictionHistoryProvider.notifier).state = merged;
    _saveHistory(merged);
  }

  Future<void> deleteHistoryItem(String id) async {
    final updated = ref
        .read(predictionHistoryProvider)
        .where((item) => item.id != id)
        .toList(growable: false);
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

  NutritionBreakdown _parseNutrition(
    Map<String, dynamic> data, {
    List<String> keys = const [
      'nutrition',
      'nutrients',
      'macros',
      'macro_breakdown',
    ],
  }) {
    final nutritionMap = _firstMap(data, keys);
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

    void addDetail(
      String rawName,
      dynamic rawCalories, {
      dynamic rawConfidence,
    }) {
      final name = _stripWrapperCharacters(rawName);
      if (name.isEmpty) {
        return;
      }

      result.add(
        IngredientDetail(
          name: name,
          calories: _formatCalories(rawCalories?.toString()),
          confidence: rawConfidence?.toString(),
          confidencePercent: _asDouble(rawConfidence),
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
          final confidence = _readFirstMapValue(item, const [
            'confidence',
            'probability',
            'score',
          ]);

          if (name != null) {
            addDetail(name, calories, rawConfidence: confidence);
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
              confidence: existing.confidence,
              confidencePercent: existing.confidencePercent,
            );
          } else {
            addDetail(keyName, value);
          }
        });
      }
    }

    return result;
  }

  List<HealthierAlternative> _parseAlternatives(Map<String, dynamic> data) {
    final candidates = [
      data['alternatives'],
      data['healthier_alternatives'],
      data['options'],
      data['results'],
    ];

    for (final candidate in candidates) {
      if (candidate is Iterable) {
        return candidate
            .whereType<Map>()
            .map(
              (item) => HealthierAlternative.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList(growable: false);
      }
    }

    return const [];
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
    return raw
        .replaceFirst('Exception: ', '')
        .replaceFirst('HttpException: ', '')
        .trim();
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

final predictNotifierProvider = StateNotifierProvider<PredictNotifier, void>(
  (ref) => PredictNotifier(ref),
);
