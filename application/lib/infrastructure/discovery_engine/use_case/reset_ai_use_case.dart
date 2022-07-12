import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

@injectable
class ResetAIUseCase extends UseCase<None, EngineEvent> {
  final DiscoveryEngine _engine;

  ResetAIUseCase(this._engine);

  @override
  Stream<EngineEvent> transaction(None param) async* {
    yield await _engine.resetAi();
  }
}
