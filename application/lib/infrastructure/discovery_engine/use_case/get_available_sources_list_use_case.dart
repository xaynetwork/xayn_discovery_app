import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

@injectable
class GetAvailableSourcesListUseCase extends UseCase<String, EngineEvent> {
  final DiscoveryEngine _engine;

  GetAvailableSourcesListUseCase(this._engine);

  @override
  Stream<EngineEvent> transaction(String param) async* {
    yield await _engine.getAvailableSourcesList(param);
  }
}
