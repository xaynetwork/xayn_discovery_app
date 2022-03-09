import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

@injectable
class RestoreSearchUseCase extends UseCase<None, EngineEvent> {
  final DiscoveryEngine _engine;

  RestoreSearchUseCase(this._engine);

  @override
  Stream<EngineEvent> transaction(None param) async* {
    yield await _engine.restoreSearch();
  }
}
