import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/discovery_engine.dart';

@injectable
class LogEngineOutputEventUseCase extends UseCase<None, String> {
  final DiscoveryEngine _engine;

  LogEngineOutputEventUseCase(this._engine);

  @override
  Stream<String> transaction(None param) => _engine.engineEvents.map(
        (it) => it.toString(),
      );
}
