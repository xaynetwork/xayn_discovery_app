import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/legacy/events/engine_event.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/discovery_engine.dart';

@injectable
class EngineEventsUseCase extends UseCase<None, EngineEvent> {
  final DiscoveryEngine _engine;

  EngineEventsUseCase(this._engine);

  @override
  Stream<EngineEvent> transaction(None param) => _engine.engineEvents;
}
