import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  void _showImageSourceSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: const Text('Choose from gallery'),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await ref
                        .read(predictNotifierProvider.notifier)
                        .pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: const Text('Use camera'),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await ref
                        .read(predictNotifierProvider.notifier)
                        .pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(BuildContext context, DateTime timestamp) {
    return TimeOfDay.fromDateTime(timestamp).format(context);
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade700, height: 1.3),
        ),
      ],
    );
  }

  Widget _actionButton({
    required BuildContext context,
    required WidgetRef ref,
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool filled = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return filled
        ? FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(label),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            ),
          )
        : OutlinedButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(label),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colorScheme.outlineVariant),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            ),
          );
  }

  Widget _historyCard(BuildContext context, PredictionResult entry) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.restaurant_outlined,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.food,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      if (entry.calories != null) entry.calories!,
                      if (entry.confidence != null) entry.confidence!,
                    ].join('  ·  '),
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _formatTime(context, entry.timestamp),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image = ref.watch(imageProvider);
    final result = ref.watch(resultProvider);
    final errorMessage = ref.watch(errorProvider);
    final loading = ref.watch(loadingProvider);
    final history = ref.watch(predictionHistoryProvider);
    final bool hasResult = result != null || errorMessage != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calorie Snap'),
        actions: [
          IconButton(
            tooltip: 'Clear current selection',
            onPressed: image == null && result == null && errorMessage == null
                ? null
                : () => ref
                      .read(predictNotifierProvider.notifier)
                      .clearSelection(),
            icon: const Icon(Icons.refresh_outlined),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange.shade50, Colors.deepOrange.shade50],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 0,
                  color: Colors.white.withValues(alpha: 0.85),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.deepOrange.shade400,
                                Colors.orange.shade300,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.restaurant_menu,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Smarter meal detection',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Capture or upload food photos, get calorie estimates, and review your recent scans in one place.',
                                style: TextStyle(height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _sectionTitle(
                  'Preview',
                  'Select a food image to analyze it with the model.',
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.white, Colors.orange.shade50],
                      ),
                    ),
                    child: AspectRatio(
                      aspectRatio: 1.15,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: image != null
                                ? Image.file(image, fit: BoxFit.cover)
                                : Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_search_outlined,
                                          size: 72,
                                          color: Colors.orange.shade300,
                                        ),
                                        const SizedBox(height: 14),
                                        Text(
                                          'No image selected yet',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Choose a photo from the gallery or camera to begin.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: 16,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.55),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    loading
                                        ? 'Analyzing image...'
                                        : image == null
                                        ? 'Awaiting photo'
                                        : 'Ready to predict',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (image != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      'Selected',
                                      style: TextStyle(
                                        color: Colors.grey.shade900,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: 170,
                      child: _actionButton(
                        context: context,
                        ref: ref,
                        label: 'Gallery',
                        icon: Icons.photo_library_outlined,
                        onPressed: () => _showImageSourceSheet(context, ref),
                      ),
                    ),
                    SizedBox(
                      width: 170,
                      child: _actionButton(
                        context: context,
                        ref: ref,
                        label: loading ? 'Analyzing' : 'Predict',
                        icon: loading
                            ? Icons.hourglass_top
                            : Icons.auto_awesome,
                        filled: true,
                        onPressed: loading || image == null
                            ? () {}
                            : () => ref
                                  .read(predictNotifierProvider.notifier)
                                  .predict(),
                      ),
                    ),
                    SizedBox(
                      ///////////////////
                      width: 170,
                      child: _actionButton(
                        context: context,
                        ref: ref,
                        label: 'Clear',
                        icon: Icons.delete_outline,
                        onPressed:
                            image == null &&
                                result == null &&
                                errorMessage == null
                            ? () {}
                            : () => ref
                                  .read(predictNotifierProvider.notifier)
                                  .clearSelection(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (hasResult)
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    color: errorMessage == null
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: errorMessage == null && result != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        Icons.check_circle_outline,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            result.food,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Prediction completed at ${_formatTime(context, result.timestamp)}',
                                            style: TextStyle(
                                              color: Colors.green.shade900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    _InfoChip(
                                      label: 'Food',
                                      value: result.food,
                                      color: Colors.green.shade700,
                                    ),
                                    if (result.calories != null)
                                      _InfoChip(
                                        label: 'Calories',
                                        value: result.calories!,
                                        color: Colors.deepOrange.shade700,
                                      ),
                                    if (result.confidence != null)
                                      _InfoChip(
                                        label: 'Confidence',
                                        value: result.confidence!,
                                        color: Colors.blue.shade700,
                                      ),
                                  ],
                                ),
                                if (result.ingredients.isNotEmpty ||
                                    result.ingredientDetails.isNotEmpty) ...[
                                  const SizedBox(height: 18),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.green.shade50,
                                          Colors.white,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(
                                        color: Colors.green.shade200,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.shade100
                                              .withValues(alpha: 0.35),
                                          blurRadius: 18,
                                          offset: const Offset(0, 8),
                                        ),
                                       ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: result.ingredients
                                          .asMap()
                                          .entries
                                          .expand(
                                            (entry) => [
                                              if (entry.key != 0)
                                                Divider(
                                                  height: 18,
                                                  thickness: 1,
                                                  color: Colors.green.shade100,
                                                ),
                                              _IngredientListItem(
                                                index: entry.key + 1,
                                                label: entry.value,
                                              ),
                                            ],
                                          )
                                          .toList(),
                                    ),
                                  ),
                                ],
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        Icons.error_outline,
                                        color: Colors.red.shade700,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Prediction failed',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Check the backend connection or try another image.',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  errorMessage ?? 'Unknown error',
                                  style: TextStyle(
                                    color: Colors.red.shade900,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                if (history.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  _sectionTitle(
                    'Recent scans',
                    'Track the latest predictions without losing your place.',
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    itemCount: history.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        _historyCard(context, history[index]),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _IngredientListItem extends StatelessWidget {
  const _IngredientListItem({required this.index, required this.label});

  final int index;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Text(
            index.toString(),
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Icon(Icons.chevron_right, size: 18, color: Colors.green.shade300),
      ],
    );
  }
}
