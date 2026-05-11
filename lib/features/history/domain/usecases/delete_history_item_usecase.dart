import '../../../../core/usecases/usecase.dart';
import '../repositories/history_repository.dart';

class DeleteHistoryItemParams {
  const DeleteHistoryItemParams(this.id);

  final String id;
}

class DeleteHistoryItemUseCase
    implements UseCase<void, DeleteHistoryItemParams> {
  const DeleteHistoryItemUseCase(this._repository);

  final HistoryRepository _repository;

  @override
  Future<void> call(DeleteHistoryItemParams params) {
    return _repository.deleteHistoryItem(params.id);
  }
}
