import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

@injectable
class RemoveSourceFromExcludedListUseCase extends UseCase<Source, EngineEvent> {
  final DiscoveryEngine _engine;

  RemoveSourceFromExcludedListUseCase(this._engine);

  @override
  Stream<EngineEvent> transaction(Source param) async* {
    yield await _engine.removeSourceFromExcludedList(param);
  }
}
