import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/legacy/events/engine_event.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/discovery_engine.dart';

@injectable
class RequestFeedUseCase extends UseCase<None, EngineEvent> {
  final DiscoveryEngine _engine;

  RequestFeedUseCase(this._engine);

  @override
  Stream<EngineEvent> transaction(None param) async* {
    yield await _engine.restoreFeed();
  }
}
