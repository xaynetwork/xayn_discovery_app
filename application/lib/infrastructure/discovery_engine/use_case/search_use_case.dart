import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/app_discovery_engine.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

@injectable
class SearchUseCase extends UseCase<String, EngineEvent> {
  final DiscoveryEngine _engine;

  SearchUseCase(this._engine);

  @override
  Stream<EngineEvent> transaction(String param) async* {
    final appDiscoveryEngine = _engine as AppDiscoveryEngine;

    yield await appDiscoveryEngine.search(param);
  }
}
