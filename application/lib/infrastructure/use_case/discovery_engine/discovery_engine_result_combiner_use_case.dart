import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:xayn_architecture/concepts/use_case.dart';
import 'package:xayn_discovery_app/domain/model/discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine_mock/manager/discovery_engine_manager.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine_mock/manager/discovery_engine_state.dart';

/// Mock implementation,
/// This will be deprecated once the real discovery engine is available.
///
/// Because the discovery feed could become quite long when more and more
/// results are being loaded, this [UseCase] adds the latest results first,
/// then, if the total amount of results exceeds 15, it removes the oldest entries first,
/// until a total count of 15 is reached again.
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

/// The return type of [DiscoveryEngineResultCombinerUseCase].
/// This class simply contains a report of what was [added] and [removed],
/// and returns the remaining actual [documents] list, in combination with
/// the [apiState] that was received as input.
@immutable
class ResultCombinerJob {
  /// what was added and/or removed.
  /// if nothing, then these are empty lists.
  final int added, removed;

  /// the actual results, which should be rendered by widgets.
  final List<Document> documents;

  /// the state of the [DiscoveryEngineManager].
  final DiscoveryEngineState apiState;

  const ResultCombinerJob(
    this.documents, {
    required this.added,
    required this.removed,
    required this.apiState,
  });
}
