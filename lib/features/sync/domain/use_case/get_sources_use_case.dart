import 'package:healthwithme/features/sync/domain/entities/source.dart';
import 'package:healthwithme/features/sync/domain/repository/sync_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetSourcesUseCase {
  final SyncRepository _syncRepository;

  GetSourcesUseCase(this._syncRepository);

  Future<List<Source>> call() {
    return _syncRepository.getSources();
  }
}
