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
class DiscoveryEngineResultsUseCase
    extends UseCase<String?, DiscoveryEngineState> {
  final DiscoveryEngineManager _discoveryApi;

  DiscoveryEngineResultsUseCase(this._discoveryApi);

  void search(
    String term, {
    List<SearchType> types = const [SearchType.web],
  }) {
    _discoveryApi.onClientEvent.add(SearchRequested(term, types));
  }

  @override
  Stream<DiscoveryEngineState> transaction(String? param) async* {
    if (param != null) {
      _discoveryApi.onClientEvent.add(SearchRequested(param, [SearchType.web]));
    }

    yield* _discoveryApi.stream;
  }
}
