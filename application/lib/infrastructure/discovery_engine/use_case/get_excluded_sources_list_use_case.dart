import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

@injectable
class GetExcludedSourcesListUseCase extends UseCase<None, EngineEvent> {
  final DiscoveryEngine _engine;

  GetExcludedSourcesListUseCase(this._engine);

  @override
  Stream<EngineEvent> transaction(None param) async* {
    yield await _engine.getExcludedSourcesList();
  }
}
