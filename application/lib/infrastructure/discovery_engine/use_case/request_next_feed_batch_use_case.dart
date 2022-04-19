import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/connectivity/connectivity_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

@injectable
class RequestNextFeedBatchUseCase extends UseCase<None, EngineEvent> {
  final DiscoveryEngine _engine;
  final ConnectivityObserver _connectivityObserver;

  RequestNextFeedBatchUseCase(
    this._engine,
    this._connectivityObserver,
  );

  @override
  Stream<EngineEvent> transaction(None param) async* {
    final event = await _engine.requestNextFeedBatch();

    yield event;

    if (event is! NextFeedBatchRequestSucceeded) {
      final status = await _connectivityObserver.checkConnectivity();

      if (status == ConnectivityResult.none) {
        await _connectivityObserver.isUp();

        yield await _engine.requestNextFeedBatch();
      }
    }
  }
}
