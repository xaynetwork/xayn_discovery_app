import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

@injectable
class RemoveSourceFromTrustedListUseCase extends UseCase<Source, EngineEvent> {
  final DiscoveryEngine _engine;

  RemoveSourceFromTrustedListUseCase(this._engine);

  @override
  Stream<EngineEvent> transaction(Source param) async* {
    yield await _engine.send(ClientEvent.trustedSourceRemoved(param));
  }
}
