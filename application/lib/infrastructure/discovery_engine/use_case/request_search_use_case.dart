import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

@injectable
class RequestSearchUseCase extends UseCase<String, EngineEvent> {
  final DiscoveryEngine _engine;

  RequestSearchUseCase(this._engine);

  @override
  Stream<EngineEvent> transaction(String param) async* {
    yield await _engine.requestSearch(
      queryTerm: param,
      market: const FeedMarket(countryCode: '', langCode: ''),
    );
  }
}
