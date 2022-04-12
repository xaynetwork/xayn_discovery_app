import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/connectivity/connectivity_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

@injectable
class RequestSearchUseCase extends UseCase<String, EngineEvent> {
  final DiscoveryEngine _engine;
  final ConnectivityObserver _connectivityObserver;

  RequestSearchUseCase(
    this._engine,
    this._connectivityObserver,
  );

  @override
  Stream<EngineEvent> transaction(String param) async* {
    await _connectivityObserver.isUp();

    yield await _engine.requestSearch(param);
  }
}
