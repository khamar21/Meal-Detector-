import '../../../../core/usecases/usecase.dart';
import '../../../home/providers.dart';
import '../repositories/history_repository.dart';

class GetHistoryUseCase implements UseCase<List<PredictionResult>, NoParams> {
  const GetHistoryUseCase(this._repository);

  final HistoryRepository _repository;

  @override
  Future<List<PredictionResult>> call(NoParams params) {
    return _repository.loadHistory();
  }
}
