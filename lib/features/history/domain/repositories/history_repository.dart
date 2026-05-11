import '../../../home/providers.dart';

abstract class HistoryRepository {
  Future<List<PredictionResult>> loadHistory();

  Future<void> saveHistory(List<PredictionResult> history);

  Future<void> deleteHistoryItem(String id);

  Future<void> clearHistory();
}
