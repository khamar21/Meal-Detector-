import '../../../home/providers.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_local_data_source.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  const HistoryRepositoryImpl(this._localDataSource);

  final HistoryLocalDataSource _localDataSource;

  @override
  Future<List<PredictionResult>> loadHistory() {
    return _localDataSource.loadHistory();
  }

  @override
  Future<void> saveHistory(List<PredictionResult> history) {
    return _localDataSource.saveHistory(history);
  }

  @override
  Future<void> deleteHistoryItem(String id) async {
    final history = await _localDataSource.loadHistory();
    final updated = history
        .where((item) => item.id != id)
        .toList(growable: false);
    await _localDataSource.saveHistory(updated);
  }

  @override
  Future<void> clearHistory() {
    return _localDataSource.clearHistory();
  }
}
