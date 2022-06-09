import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

@injectable
class AddSourceToExcludedListUseCase extends UseCase<Source, EngineEvent> {
  final DiscoveryEngine _engine;

  AddSourceToExcludedListUseCase(this._engine);

  @override
  Stream<EngineEvent> transaction(Source param) async* {
    yield await _engine.addSourceToExcludedList(param);
  }
}
