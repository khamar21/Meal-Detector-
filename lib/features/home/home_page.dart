import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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
    if (!mounted) {
      return;
    }
    setState(() {
      _speechEnabled = enabled;
    });
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

  Future<void> _predictImage() async {
    await ref.read(predictNotifierProvider.notifier).predict();
  }

  Future<void> _predictVoice() async {
    final text = _voiceController.text.trim();
    if (text.isEmpty) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Say or type a food name first.')),
      );
      return;
    }
    await ref.read(predictNotifierProvider.notifier).predictFromVoice(text);
  }

  Future<void> _toggleListening() async {
    if (!_speechEnabled) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice input is not available on device.'),
        ),
      );
      return;
    }

    if (_isListening) {
      await _speech.stop();
      _micPulseController.stop();
      if (!mounted) {
        return;
      }
      setState(() {
        _isListening = false;
      });
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

    if (!mounted) {
      return;
    }

    setState(() {
      _isListening = started;
    });

    if (started) {
      _micPulseController.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pickedImage = ref.watch(imageProvider);
    final result = ref.watch(resultProvider);
    final error = ref.watch(errorProvider);
    final isLoading = ref.watch(loadingProvider);
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
              colorScheme.primaryContainer.withValues(alpha: 0.55),
              colorScheme.surface,
              colorScheme.secondaryContainer.withValues(alpha: 0.45),
            ],
            stops: const [0, 0.45, 1],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _glassCard(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scan from image',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _ImagePreview(image: pickedImage),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
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
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Gallery'),
                      ),
                      OutlinedButton.icon(
                        onPressed: isLoading
                            ? null
                            : () => ref
                                  .read(predictNotifierProvider.notifier)
                                  .clearSelection(),
                        icon: const Icon(Icons.clear_rounded),
                        label: const Text('Clear'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: (isLoading || pickedImage == null)
                          ? null
                          : _predictImage,
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('Predict From Image'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _glassCard(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Voice input',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _voiceController,
                    onChanged: (value) =>
                        ref.read(voiceDraftProvider.notifier).state = value,
                    decoration: const InputDecoration(
                      hintText: 'Example: I ate biryani',
                      prefixIcon: Icon(Icons.record_voice_over_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
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
                            _isListening ? Icons.mic : Icons.mic_none_rounded,
                          ),
                          label: Text(_isListening ? 'Listening...' : 'Speak'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: isLoading ? null : _predictVoice,
                          icon: const Icon(Icons.send_rounded),
                          label: const Text('Predict From Voice'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (isLoading)
              _glassCard(
                context,
                child: const Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    ),
                    SizedBox(width: 12),
                    Expanded(child: Text('Analyzing your food...')),
                  ],
                ),
              ),
            if (error != null && error.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: _glassCard(
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
                        onPressed: () => ref
                            .read(predictNotifierProvider.notifier)
                            .retryLastPrediction(),
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final slide = Tween<Offset>(
                  begin: const Offset(0, 0.08),
                  end: Offset.zero,
                ).animate(animation);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(position: slide, child: child),
                );
              },
              child: result == null
                  ? const SizedBox.shrink()
                  : Padding(
                      key: ValueKey<String>(result.id),
                      padding: const EdgeInsets.only(top: 14),
                      child: _ResultCard(result: result),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glassCard(BuildContext context, {required Widget child}) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 11, sigmaY: 11),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: colorScheme.surface.withValues(alpha: 0.62),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.image});

  final File? image;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 210,
        width: double.infinity,
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        child: image == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 38,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  const Text('Image preview will appear here'),
                ],
              )
            : Image.file(image!, fit: BoxFit.cover),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final PredictionResult result;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 11, sigmaY: 11),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: colorScheme.surface.withValues(alpha: 0.68),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.24),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Prediction Result',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                result.food,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Tag(label: 'Calories: ${result.caloriesLabel}'),
                  _Tag(label: 'Confidence: ${result.confidenceLabel}'),
                  _Tag(
                    label: result.sourceType == PredictionSource.voice
                        ? 'Voice Scan'
                        : 'Image Scan',
                  ),
                ],
              ),
              if (result.ingredients.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  'Ingredients',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: result.ingredients
                      .map((item) => _Tag(label: item))
                      .toList(growable: false),
                ),
              ],
              if (result.nutrition.hasData) ...[
                const SizedBox(height: 14),
                Text(
                  'Nutrition',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _NutritionBar(
                  icon: Icons.fitness_center,
                  label: 'Protein',
                  value: result.nutrition.protein,
                  max: 60,
                ),
                const SizedBox(height: 8),
                _NutritionBar(
                  icon: Icons.grain,
                  label: 'Carbs',
                  value: result.nutrition.carbs,
                  max: 120,
                ),
                const SizedBox(height: 8),
                _NutritionBar(
                  icon: Icons.water_drop_outlined,
                  label: 'Fat',
                  value: result.nutrition.fat,
                  max: 45,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NutritionBar extends StatelessWidget {
  const _NutritionBar({
    required this.icon,
    required this.label,
    required this.value,
    required this.max,
  });

  final IconData icon;
  final String label;
  final double? value;
  final double max;

  @override
  Widget build(BuildContext context) {
    final amount = value ?? 0;
    final progress = (amount / max).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 18),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.secondaryContainer.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label),
    );
  }
}
