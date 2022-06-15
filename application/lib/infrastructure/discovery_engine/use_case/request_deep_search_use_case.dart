import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

@injectable
class RequestDeepSearchUseCase extends UseCase<DocumentId, EngineEvent> {
  final DiscoveryEngine _engine;
  // final ConnectivityObserver _connectivityObserver;
  // int _requestCount = 0;

  RequestDeepSearchUseCase(this._engine);

  @override
  Stream<EngineEvent> transaction(DocumentId param) async* {
    // store the request count locally
    // final localRequestCount = _requestCount = _requestCount + 1;
    // await _connectivityObserver.isUp();

    // because 1+ request counts could have been made during connection downtime,
    // we only allow the most recent one to actually pass, once the connection restores.
    // if (_requestCount == localRequestCount) {
    yield await _engine.requestDeepSearch(param);
    // }
  }
}
