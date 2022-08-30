import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/connectivity/connectivity_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

@injectable
class RequestDeepSearchUseCase extends UseCase<DocumentId, EngineEvent> {
  final DiscoveryEngine _engine;
  final ConnectivityObserver _connectivityObserver;

  RequestDeepSearchUseCase(
    this._engine,
    this._connectivityObserver,
  );

  @override
  Stream<EngineEvent> transaction(DocumentId param) async* {
    final event = await _engine.requestDeepSearch(param);

    yield event;

    if (event is! DeepSearchRequestSucceeded) {
      final status = await _connectivityObserver.checkConnectivity();

      if (status == ConnectivityResult.none) {
        await _connectivityObserver.isUp();

        yield await _engine.requestDeepSearch(param);
      }
    }
  }
}
