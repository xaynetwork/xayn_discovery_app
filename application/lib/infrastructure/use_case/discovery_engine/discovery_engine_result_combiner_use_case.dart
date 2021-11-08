import 'dart:collection';

import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine_mock/manager/discovery_engine_state.dart';

class DiscoveryEngineResultCombinerUseCase
    extends UseCase<DiscoveryEngineState, ResultCombinerJob> {
  final List<Document>? Function() _currentResults;

  DiscoveryEngineResultCombinerUseCase(this._currentResults);

  @override
  Stream<ResultCombinerJob> transaction(DiscoveryEngineState param) async* {
    final currentResults = _currentResults();

    if (param.isComplete) {
      final queue = Queue<Document>.from(
          [...currentResults ?? const [], ...param.results]);
      var removals = 0;

      // reduce to max 15 items
      while (queue.length > 15) {
        queue.removeFirst();
        removals++;
      }

      yield ResultCombinerJob(
        queue.toList(growable: false),
        added: param.results.length,
        removed: removals,
        apiState: param,
      );
    } else {
      yield ResultCombinerJob(
        currentResults ?? const [],
        added: 0,
        removed: 0,
        apiState: param,
      );
    }
  }
}

class ResultCombinerJob {
  final int added, removed;
  final List<Document> documents;
  final DiscoveryEngineState apiState;

  const ResultCombinerJob(
    this.documents, {
    required this.added,
    required this.removed,
    required this.apiState,
  });
}
