import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/connectivity/connectivity_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

@injectable
class RequestNextSearchBatchUseCase extends UseCase<None, EngineEvent>
    with ConnectivityUseCaseMixin<None, EngineEvent> {
  final DiscoveryEngine _engine;

  RequestNextSearchBatchUseCase(this._engine);

  @override
  Stream<EngineEvent> transaction(None param) async* {
    yield await _engine.requestNextSearchBatch();
  }
}
