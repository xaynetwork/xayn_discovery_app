import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

@injectable
class CloseFeedDocumentsUseCase extends UseCase<Set<DocumentId>, EngineEvent> {
  final DiscoveryEngine _engine;

  CloseFeedDocumentsUseCase(this._engine);

  @override
  Stream<EngineEvent> transaction(Set<DocumentId> param) async* {
    yield await _engine.closeFeedDocuments(param);
  }
}
