import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/history_local_data_source.dart';
import '../../data/repositories/history_repository_impl.dart';
import '../../domain/repositories/history_repository.dart';
import '../../domain/usecases/clear_history_usecase.dart';
import '../../domain/usecases/delete_history_item_usecase.dart';
import '../../domain/usecases/get_history_usecase.dart';
import '../../domain/usecases/save_history_usecase.dart';

final historyLocalDataSourceProvider = Provider<HistoryLocalDataSource>(
  (ref) => const HistoryLocalDataSource(),
);

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepositoryImpl(ref.read(historyLocalDataSourceProvider));
});

final getHistoryUseCaseProvider = Provider<GetHistoryUseCase>((ref) {
  return GetHistoryUseCase(ref.read(historyRepositoryProvider));
});

final saveHistoryUseCaseProvider = Provider<SaveHistoryUseCase>((ref) {
  return SaveHistoryUseCase(ref.read(historyRepositoryProvider));
});

final deleteHistoryItemUseCaseProvider = Provider<DeleteHistoryItemUseCase>(
  (ref) => DeleteHistoryItemUseCase(ref.read(historyRepositoryProvider)),
);

final clearHistoryUseCaseProvider = Provider<ClearHistoryUseCase>((ref) {
  return ClearHistoryUseCase(ref.read(historyRepositoryProvider));
});
