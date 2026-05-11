import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../home/providers.dart';

class HistoryLocalDataSource {
  const HistoryLocalDataSource();

  static const String historyKey = 'scan_history_v3';

  Future<List<PredictionResult>> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(historyKey);
      if (raw == null || raw.trim().isEmpty) {
        return const [];
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) =>
                PredictionResult.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveHistory(List<PredictionResult> history) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = history
        .map((item) => item.toJson())
        .toList(growable: false);
    await prefs.setString(historyKey, jsonEncode(payload));
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(historyKey);
  }
}
