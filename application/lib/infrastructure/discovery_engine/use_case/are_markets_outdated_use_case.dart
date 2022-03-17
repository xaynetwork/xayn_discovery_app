import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/app_discovery_engine.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

@injectable
class AreMarketsOutdatedUseCase extends UseCase<None, bool> {
  final DiscoveryEngine _engine;

  AreMarketsOutdatedUseCase(this._engine);

  @override
  Stream<bool> transaction(None param) async* {
    final engine = _engine as AppDiscoveryEngine;

    yield await engine.areMarketsOutdated();
  }
}
