import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine_mock/manager/discovery_engine_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine_mock/manager/discovery_engine_state.dart';

// ignore: implementation_imports
import 'package:xayn_discovery_engine/src/api/events/search_events.dart';
// ignore: implementation_imports
import 'package:xayn_discovery_engine/src/domain/models/search_type.dart';

const Duration kDebounceDuration = Duration(milliseconds: 400);

/// Mock implementation,
/// This will be deprecated once the real discovery engine is available.
///
/// A [UseCase] which forwards the output documents stream of the [DiscoveryEngineManager].
@injectable
class DiscoveryEngineResultsUseCase
    extends UseCase<DiscoveryEngineResultsParam, DiscoveryEngineState> {
  final DiscoveryEngineManager _discoveryApi;

  DiscoveryEngineResultsUseCase(this._discoveryApi);

  @override
  Stream<DiscoveryEngineState> transaction(
      DiscoveryEngineResultsParam param) async* {
    final searchTerm = param.searchTerm;

    if (searchTerm != null) {
      _discoveryApi.onClientEvent.add(SearchRequested(
        searchTerm,
        param.searchTypes,
      ));
    }

    yield* _discoveryApi.stream;
  }

  @override
  Stream<DiscoveryEngineResultsParam> transform(
          Stream<DiscoveryEngineResultsParam> incoming) =>
      incoming
          .distinct((a, b) =>
              a.searchTerm == b.searchTerm &&
              listEquals(b.searchTypes, b.searchTypes))
          .debounceTime(kDebounceDuration);
}

class DiscoveryEngineResultsParam {
  final String? searchTerm;
  final List<SearchType> searchTypes;

  const DiscoveryEngineResultsParam({
    required this.searchTypes,
    this.searchTerm,
  });
}
