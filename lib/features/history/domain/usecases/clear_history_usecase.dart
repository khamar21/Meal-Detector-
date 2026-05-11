import '../../../../core/usecases/usecase.dart';
import '../repositories/history_repository.dart';

class ClearHistoryUseCase implements UseCase<void, NoParams> {
  const ClearHistoryUseCase(this._repository);

  final HistoryRepository _repository;

  @override
  Future<void> call(NoParams params) {
    return _repository.clearHistory();
  }
}
