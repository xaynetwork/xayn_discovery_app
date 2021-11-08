import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine_mock/manager/discovery_engine_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine_mock/manager/discovery_engine_state.dart';

// ignore: implementation_imports
import 'package:xayn_discovery_engine/src/api/events/search_events.dart';
// ignore: implementation_imports
import 'package:xayn_discovery_engine/src/domain/models/search_type.dart';

/// Mock implementation,
/// This will be deprecated once the real discovery engine is available.
///
/// A [UseCase] which forwards the output documents stream of the [DiscoveryEngineManager].
@injectable
class DiscoveryEngineResultsUseCase extends UseCase<int, DiscoveryEngineState> {
  final DiscoveryEngineManager _discoveryApi;

  DiscoveryEngineResultsUseCase(this._discoveryApi);

  @override
  Stream<DiscoveryEngineState> transaction(int param) async* {
    _discoveryApi.onClientEvent
        .add(const SearchRequested('', [SearchType.web]));

    yield* _discoveryApi.stream;
  }
}
