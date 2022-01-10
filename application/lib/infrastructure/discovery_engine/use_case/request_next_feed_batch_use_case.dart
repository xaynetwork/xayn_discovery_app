import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

@injectable
class RequestNextFeedBatchUseCase extends UseCase<None, EngineEvent> {
  final DiscoveryEngine _engine;

  RequestNextFeedBatchUseCase(this._engine);

  @override
  Stream<EngineEvent> transaction(None param) async* {
    yield await _engine.requestNextFeedBatch();
  }
}
