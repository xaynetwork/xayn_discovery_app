import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/connectivity/connectivity_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

@injectable
class RequestNextSearchBatchUseCase extends UseCase<None, EngineEvent> {
  final DiscoveryEngine _engine;
  final ConnectivityObserver _connectivityObserver;

  RequestNextSearchBatchUseCase(
    this._engine,
    this._connectivityObserver,
  );

  @override
  Stream<EngineEvent> transaction(None param) async* {
    final event = await _engine.requestNextActiveSearchBatch();

    yield event;

    if (event is! NextActiveSearchBatchRequestSucceeded) {
      final status = await _connectivityObserver.checkConnectivity();

      if (status == ConnectivityResult.none) {
        await _connectivityObserver.isUp();

        yield await _engine.requestNextActiveSearchBatch();
      }
    }
  }
}
