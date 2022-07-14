import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

///Return true if succeeded, false otherwise
///
@injectable
class ResetAIUseCase extends UseCase<None, bool> {
  final DiscoveryEngine _engine;

  ResetAIUseCase(this._engine);

  @override
  Stream<bool> transaction(None param) async* {
    final engineEvent = await _engine.resetAi();
    if (engineEvent is ResetAiSucceeded) {
      yield true;
      return;
    } else {
      yield false;
    }
  }
}
