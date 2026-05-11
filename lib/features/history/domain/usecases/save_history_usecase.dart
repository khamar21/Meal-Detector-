import '../../../../core/usecases/usecase.dart';
import '../../../home/providers.dart';
import '../repositories/history_repository.dart';

class SaveHistoryParams {
  const SaveHistoryParams(this.history);

  final List<PredictionResult> history;
}

class SaveHistoryUseCase implements UseCase<void, SaveHistoryParams> {
  const SaveHistoryUseCase(this._repository);

  final HistoryRepository _repository;

  @override
  Future<void> call(SaveHistoryParams params) {
    return _repository.saveHistory(params.history);
  }
}
