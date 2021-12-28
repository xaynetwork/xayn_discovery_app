import 'package:flutter/foundation.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

/// Mock implementation.
/// This will be deprecated once the real discovery engine is available.
@immutable
class DiscoveryEngineState {
  final List<Document> results;
  final bool isComplete;
  final Object? error;
  final StackTrace? stackTrace;

  bool get isLoading => !isComplete && !hasError;

  bool get hasError => error != null;

  const DiscoveryEngineState({
    required this.results,
    required this.isComplete,
  })  : error = null,
        stackTrace = null;

  const DiscoveryEngineState.initial()
      : results = const [],
        isComplete = false,
        error = null,
        stackTrace = null;

  DiscoveryEngineState.error({
    required this.error,
    required this.stackTrace,
  })  : results = const [],
        isComplete = false {
    // ignore: avoid_print
    print('e: $error, st: $stackTrace');
  }
}
