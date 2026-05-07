import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../diet/model/diet_models.dart';
import '../diet/viewmodel/diet_view_model.dart';
import '../history/history_page.dart';
import 'providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final TextEditingController _voiceController = TextEditingController();
  late final AnimationController _micPulseController;

  bool _speechEnabled = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _micPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final enabled = await _speech.initialize();
    if (!mounted) return;
    setState(() => _speechEnabled = enabled);
  }

  @override
  void dispose() {
    _micPulseController.dispose();
    _voiceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    await ref.read(predictNotifierProvider.notifier).pickImage(source);
  }

  Future<void> _pickBatchImages() async {
    await ref.read(predictNotifierProvider.notifier).pickBatchImages();
  }

  Future<void> _predict() async {
    await ref.read(predictNotifierProvider.notifier).predict();
  }

  Future<void> _adjustPortion() async {
    await ref
        .read(predictNotifierProvider.notifier)
        .adjustPortion(ref.read(portionMultiplierProvider));
  }

  Future<void> _loadAlternatives() async {
    await ref
        .read(predictNotifierProvider.notifier)
        .loadHealthierAlternatives();
  }

  Future<void> _predictVoice() async {
    final text = _voiceController.text.trim();
    if (text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Say or type a food name first.')),
      );
      return;
    }
    await ref.read(predictNotifierProvider.notifier).predictFromVoice(text);
  }

  Future<void> _toggleListening() async {
    if (!_speechEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice input is not available on this device.'),
        ),
      );
      return;
    }

    if (_isListening) {
      await _speech.stop();
      _micPulseController.stop();
      if (!mounted) return;
      setState(() => _isListening = false);
      return;
    }

    final started = await _speech.listen(
      onResult: (result) {
        final words = result.recognizedWords;
        _voiceController.value = TextEditingValue(
          text: words,
          selection: TextSelection.collapsed(offset: words.length),
        );
        ref.read(voiceDraftProvider.notifier).state = words;
      },
      onSoundLevelChange: (_) {},
      listenMode: stt.ListenMode.confirmation,
    );

    if (!mounted) return;
    setState(() => _isListening = started);
    if (started) {
      _micPulseController.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pickedImage = ref.watch(imageProvider);
    final batchImages = ref.watch(batchImagesProvider);
    final batchMode = ref.watch(batchModeProvider);
    final result = ref.watch(resultProvider);
    final batchResults = ref.watch(batchResultsProvider);
    final error = ref.watch(errorProvider);
    final isLoading = ref.watch(loadingProvider);
    final processingLabel = ref.watch(processingLabelProvider);
    final portionMultiplier = ref.watch(portionMultiplierProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Calorie AI'),
        actions: [
          IconButton(
            tooltip: 'Scan history',
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const HistoryPage()));
            },
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.6),
              colorScheme.surface,
              colorScheme.secondaryContainer.withValues(alpha: 0.45),
            ],
            stops: const [0, 0.46, 1],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1080),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
              children: [
                _glassCard(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload food photos, get calories, then refine the portion and find lighter alternatives.',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Single upload works for camera scans. Batch mode lets you send multiple images and compare all results in one pass.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _glassCard(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload mode',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 14),
                      ToggleButtons(
                        borderRadius: BorderRadius.circular(16),
                        isSelected: [!batchMode, batchMode],
                        onPressed: isLoading
                            ? null
                            : (index) {
                                ref
                                    .read(predictNotifierProvider.notifier)
                                    .setBatchMode(index == 1);
                              },
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child: Text('Single image'),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14),
                            child: Text('Batch upload'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _glassCard(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        batchMode ? 'Batch upload' : 'Single image upload',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Preview before submit. Images are validated for type and size first.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 14),
                      if (batchMode)
                        _BatchPreviewGrid(
                          images: batchImages,
                          onRemove: isLoading
                              ? null
                              : (path) => ref
                                    .read(predictNotifierProvider.notifier)
                                    .removeBatchImage(path),
                        )
                      else
                        _SingleImagePreview(image: pickedImage),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: batchMode
                            ? [
                                FilledButton.icon(
                                  onPressed: isLoading
                                      ? null
                                      : _pickBatchImages,
                                  icon: const Icon(
                                    Icons.add_photo_alternate_outlined,
                                  ),
                                  label: const Text('Add images'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: isLoading
                                      ? null
                                      : () => ref
                                            .read(
                                              predictNotifierProvider.notifier,
                                            )
                                            .clearSelection(),
                                  icon: const Icon(Icons.clear_rounded),
                                  label: const Text('Clear batch'),
                                ),
                              ]
                            : [
                                FilledButton.icon(
                                  onPressed: isLoading
                                      ? null
                                      : () => _pickImage(ImageSource.camera),
                                  icon: const Icon(Icons.camera_alt_outlined),
                                  label: const Text('Camera'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: isLoading
                                      ? null
                                      : () => _pickImage(ImageSource.gallery),
                                  icon: const Icon(
                                    Icons.photo_library_outlined,
                                  ),
                                  label: const Text('Gallery'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: isLoading
                                      ? null
                                      : () => ref
                                            .read(
                                              predictNotifierProvider.notifier,
                                            )
                                            .clearSelection(),
                                  icon: const Icon(Icons.clear_rounded),
                                  label: const Text('Clear'),
                                ),
                              ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: isLoading
                              ? null
                              : (batchMode
                                    ? batchImages.isEmpty
                                    : pickedImage == null)
                              ? null
                              : _predict,
                          icon: const Icon(Icons.auto_awesome),
                          label: Text(
                            batchMode ? 'Process batch' : 'Predict food',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLoading) ...[
                  const SizedBox(height: 18),
                  _LoadingStateCard(
                    message: processingLabel ?? 'Analyzing your upload...',
                  ),
                ],
                if (error != null && error.trim().isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _ErrorStateCard(
                    error: error,
                    onRetry: () => ref
                        .read(predictNotifierProvider.notifier)
                        .retryLastPrediction(),
                  ),
                ],
                if (batchResults.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _BatchSummaryCard(items: batchResults),
                  const SizedBox(height: 18),
                  _BatchResultsGrid(items: batchResults),
                ] else if (result != null) ...[
                  const SizedBox(height: 18),
                  _PredictionResultCard(result: result),
                  const SizedBox(height: 18),
                  _PortionAdjusterCard(
                    result: result,
                    multiplier: portionMultiplier,
                    onMultiplierChanged: (value) {
                      ref.read(portionMultiplierProvider.notifier).state =
                          value;
                    },
                    onApply: _adjustPortion,
                  ),
                  const SizedBox(height: 18),
                  _AlternativesPanel(result: result, onLoad: _loadAlternatives),
                ],
                const SizedBox(height: 18),
                _glassCard(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Voice input',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _voiceController,
                        onChanged: (value) =>
                            ref.read(voiceDraftProvider.notifier).state = value,
                        decoration: const InputDecoration(
                          hintText: 'Example: I ate biryani',
                          prefixIcon: Icon(Icons.record_voice_over_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          ScaleTransition(
                            scale: Tween<double>(begin: 1, end: 1.08).animate(
                              CurvedAnimation(
                                parent: _micPulseController,
                                curve: Curves.easeInOut,
                              ),
                            ),
                            child: FilledButton.tonalIcon(
                              onPressed: isLoading ? null : _toggleListening,
                              icon: Icon(
                                _isListening
                                    ? Icons.mic
                                    : Icons.mic_none_rounded,
                              ),
                              label: Text(
                                _isListening ? 'Listening...' : 'Speak',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: isLoading ? null : _predictVoice,
                              icon: const Icon(Icons.send_rounded),
                              label: const Text('Predict from voice'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassCard(BuildContext context, {required Widget child}) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 13, sigmaY: 13),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: colorScheme.surface.withValues(alpha: 0.68),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.22),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _LoadingStateCard extends StatelessWidget {
  const _LoadingStateCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return _shellCard(
      context,
      child: Row(
        children: [
          SizedBox(
            width: 26,
            height: 26,
            child: CircularProgressIndicator(
              strokeWidth: 2.8,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorStateCard extends StatelessWidget {
  const _ErrorStateCard({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _shellCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(error),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _SingleImagePreview extends StatelessWidget {
  const _SingleImagePreview({required this.image});

  final File? image;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 260,
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          gradient: image == null
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primaryContainer.withValues(alpha: 0.4),
                    colorScheme.secondaryContainer.withValues(alpha: 0.3),
                  ],
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 44,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Image preview will appear here',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              )
            : Image.file(image!, fit: BoxFit.cover),
      ),
    );
  }
}

class _BatchPreviewGrid extends StatelessWidget {
  const _BatchPreviewGrid({required this.images, required this.onRemove});

  final List<File> images;
  final ValueChanged<String>? onRemove;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.outline.withValues(alpha: 0.18),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.photo_library_outlined,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'No batch images selected yet',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return _BatchThumb(image: images[index], onRemove: onRemove);
      },
    );
  }
}

class _BatchThumb extends StatelessWidget {
  const _BatchThumb({required this.image, required this.onRemove});

  final File image;
  final ValueChanged<String>? onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(image, fit: BoxFit.cover),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: null,
                hoverColor: Colors.black.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    image.path.split(Platform.pathSeparator).last,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (onRemove != null)
                  IconButton.filledTonal(
                    onPressed: () => onRemove!(image.path),
                    icon: Icon(Icons.close_rounded, color: colorScheme.error),
                    visualDensity: VisualDensity.compact,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PredictionResultCard extends StatelessWidget {
  const _PredictionResultCard({required this.result});

  final PredictionResult result;

  @override
  Widget build(BuildContext context) {
    return _shellCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prediction result',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          _ResultHero(result: result),
          const SizedBox(height: 14),
          Text(result.food, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Tag(label: 'Calories: ${result.caloriesLabel}'),
              _Tag(label: 'Confidence: ${result.confidenceLabel}'),
              _Tag(label: _sourceLabel(result.sourceType)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                final entry = DietEntry.fromPrediction(result);
                final container = ProviderScope.containerOf(
                  context,
                  listen: false,
                );
                container
                    .read(dietViewModelProvider.notifier)
                    .addPrediction(entry);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to today\'s diet log.')),
                );
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add to diet log'),
            ),
          ),
          const SizedBox(height: 14),
          _MetricRow(
            icon: Icons.schedule_rounded,
            label: 'Scanned at',
            value: _formatTimestamp(result.timestamp),
          ),
          if (result.source != null && result.source!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            _MetricRow(
              icon: Icons.image_outlined,
              label: 'Saved image',
              value: result.source!,
            ),
          ],
          if (result.nutrition.hasData) ...[
            const SizedBox(height: 16),
            Text(
              'Nutrition breakdown',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _NutritionRow(
              icon: Icons.fitness_center,
              label: 'Protein',
              value: result.nutrition.protein,
              accent: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 8),
            _NutritionRow(
              icon: Icons.grain,
              label: 'Carbs',
              value: result.nutrition.carbs,
              accent: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 8),
            _NutritionRow(
              icon: Icons.water_drop_outlined,
              label: 'Fat',
              value: result.nutrition.fat,
              accent: Theme.of(context).colorScheme.tertiary,
            ),
          ],
          if (result.ingredients.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Ingredients', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: result.ingredients
                  .map((item) => _Tag(label: item))
                  .toList(growable: false),
            ),
          ],
          if (result.ingredientDetails.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Ingredient confidence',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...result.ingredientDetails.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _IngredientRow(detail: item),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultHero extends StatelessWidget {
  const _ResultHero({required this.result});

  final PredictionResult result;

  @override
  Widget build(BuildContext context) {
    final image = result.source != null ? File(result.source!) : null;
    final hasImage = image != null && image.existsSync();
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: SizedBox(
        height: 260,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            hasImage
                ? Image.file(image, fit: BoxFit.cover)
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primaryContainer,
                          colorScheme.secondaryContainer,
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.restaurant_outlined,
                      size: 68,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.08),
                      Colors.black.withValues(alpha: 0.42),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      label: 'Calories',
                      value: result.caloriesLabel,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniStat(
                      label: 'Confidence',
                      value: result.confidenceLabel,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PortionAdjusterCard extends StatelessWidget {
  const _PortionAdjusterCard({
    required this.result,
    required this.multiplier,
    required this.onMultiplierChanged,
    required this.onApply,
  });

  final PredictionResult result;
  final double multiplier;
  final ValueChanged<double> onMultiplierChanged;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _shellCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Portion adjustment',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              _Tag(label: 'x${multiplier.toStringAsFixed(1)}'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Use a quick multiplier or slide to update the calories with the backend calculation.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Slider(
            value: multiplier.clamp(0.5, 3.0),
            min: 0.5,
            max: 3.0,
            divisions: 10,
            label: 'x${multiplier.toStringAsFixed(1)}',
            onChanged: onMultiplierChanged,
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _QuickMultiplierButton(
                label: 'Half',
                isSelected: (multiplier - 0.5).abs() < 0.01,
                onTap: () => onMultiplierChanged(0.5),
              ),
              _QuickMultiplierButton(
                label: 'Normal',
                isSelected: (multiplier - 1).abs() < 0.01,
                onTap: () => onMultiplierChanged(1),
              ),
              _QuickMultiplierButton(
                label: 'Double',
                isSelected: (multiplier - 2).abs() < 0.01,
                onTap: () => onMultiplierChanged(2),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onApply,
              icon: const Icon(Icons.calculate_outlined),
              label: const Text('Update portion calories'),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Adjusted calories',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  result.adjustedCaloriesLabel,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  result.hasAdjustedData
                      ? 'Backend returned updated portion details.'
                      : 'Tap the button above to fetch the updated calorie estimate.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlternativesPanel extends StatelessWidget {
  const _AlternativesPanel({required this.result, required this.onLoad});

  final PredictionResult result;
  final VoidCallback onLoad;

  @override
  Widget build(BuildContext context) {
    return _shellCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Healthier alternatives',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              OutlinedButton.icon(
                onPressed: onLoad,
                icon: const Icon(Icons.health_and_safety_outlined),
                label: const Text('View healthier options'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Show lighter options, calorie reduction, and why each option is a better fit.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (result.alternatives.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...result.alternatives.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _AlternativeCard(alternative: item),
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            Text(
              'No alternatives loaded yet. Use the button above to ask the backend.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

class _AlternativeCard extends StatelessWidget {
  const _AlternativeCard({required this.alternative});

  final HealthierAlternative alternative;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.12),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  alternative.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _Tag(label: '${alternative.caloriesLabel} kcal'),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Tag(label: 'Reduction: ${alternative.reductionLabel}'),
              if (alternative.benefit != null &&
                  alternative.benefit!.trim().isNotEmpty)
                _Tag(label: alternative.benefit!),
            ],
          ),
        ],
      ),
    );
  }
}

class _BatchSummaryCard extends StatelessWidget {
  const _BatchSummaryCard({required this.items});

  final List<BatchPredictionItem> items;

  @override
  Widget build(BuildContext context) {
    final successes = items
        .where((item) => item.isSuccess)
        .toList(growable: false);
    final failed = items
        .where((item) => !item.isSuccess)
        .toList(growable: false);
    final totalCalories = successes.fold<double>(0, (sum, item) {
      final result = item.result;
      return sum + (result?.adjustedCaloriesKcal ?? result?.caloriesKcal ?? 0);
    });
    final confidenceValues = successes
        .map((item) => item.result?.confidencePercent)
        .whereType<double>()
        .toList(growable: false);
    final averageConfidence = confidenceValues.isEmpty
        ? 0.0
        : confidenceValues.reduce((a, b) => a + b) / confidenceValues.length;

    return _shellCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Batch totals', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _SummaryTile(
                label: 'Total calories',
                value:
                    '${totalCalories.toStringAsFixed(totalCalories % 1 == 0 ? 0 : 1)} kcal',
              ),
              _SummaryTile(
                label: 'Average confidence',
                value:
                    '${averageConfidence.toStringAsFixed(averageConfidence % 1 == 0 ? 0 : 1)}%',
              ),
              _SummaryTile(label: 'Success', value: '${successes.length}'),
              _SummaryTile(label: 'Failed', value: '${failed.length}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _BatchResultsGrid extends StatelessWidget {
  const _BatchResultsGrid({required this.items});

  final List<BatchPredictionItem> items;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 720;

    return _shellCard(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Batch results', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWide ? 2 : 1,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: isWide ? 1.35 : 1.05,
            ),
            itemBuilder: (context, index) {
              return _BatchResultCard(item: items[index]);
            },
          ),
        ],
      ),
    );
  }
}

class _BatchResultCard extends StatelessWidget {
  const _BatchResultCard({required this.item});

  final BatchPredictionItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 160,
              width: double.infinity,
              child: Image.file(item.image, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: item.result != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.result!.food,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            const _Tag(label: 'Success'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Calories: ${item.result!.caloriesLabel}'),
                        Text('Confidence: ${item.result!.confidenceLabel}'),
                        if (item.result!.ingredients.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            item.result!.ingredients.join(', '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Image failed',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            const _Tag(label: 'Failed'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(kTypeVideo
                          item.error ??
                              'The backend could not process this image.',
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({required this.detail});

  final IngredientDetail detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.local_dining_outlined, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(detail.name, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 2),
              Text(
                'Calories: ${detail.caloriesLabel} • Confidence: ${detail.confidenceLabel}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NutritionRow extends StatelessWidget {
  const _NutritionRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final double? value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final amount = value ?? 0;
    final progress = (amount / 100).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: accent),
            const SizedBox(width: 8),
            Expanded(child: Text(label)),
            Text('${amount.toStringAsFixed(amount % 1 == 0 ? 0 : 1)} g'),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress.toDouble(),
            minHeight: 8,
            color: accent,
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _QuickMultiplierButton extends StatelessWidget {
  const _QuickMultiplierButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected
            ? Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: 0.6)
            : null,
      ),
      child: Text(label),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: '$label: ',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

Widget _shellCard(BuildContext context, {required Widget child}) {
  final colorScheme = Theme.of(context).colorScheme;

  return ClipRRect(
    borderRadius: BorderRadius.circular(28),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 13, sigmaY: 13),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: colorScheme.surface.withValues(alpha: 0.68),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.22),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: child,
      ),
    ),
  );
}

String _sourceLabel(PredictionSource sourceType) {
  return sourceType == PredictionSource.voice ? 'Voice scan' : 'Image scan';
}

String _formatTimestamp(DateTime timestamp) {
  final local = timestamp.toLocal();
  return local.toString().split('.').first;
}
