import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/app_discovery_engine.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

@injectable
class LogEngineInputEventUseCase extends UseCase<None, String> {
  final DiscoveryEngine _engine;

  LogEngineInputEventUseCase(this._engine);

  @override
  Stream<String> transaction(None param) =>
      (_engine as AppDiscoveryEngine).engineInputEventsLog;
}
