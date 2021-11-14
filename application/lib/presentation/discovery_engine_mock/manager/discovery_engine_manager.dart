import 'dart:async';
import 'dart:math';

import 'package:xayn_discovery_app/domain/model/discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/domain/use_case/discovery_feed/discovery_feed.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/log_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine_mock/manager/discovery_engine_state.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart' as xayn;
// ignore: implementation_imports
import 'package:xayn_discovery_engine/src/api/events/base_events.dart';
// ignore: implementation_imports
import 'package:xayn_discovery_engine/src/api/events/search_events.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case.dart';

/// Mock implementation.
/// This will be deprecated once the real discovery engine is available.
///
/// These are random keywords, real keywords are to be provided by the
/// real discovery engine.
const List<String> randomKeywords = [
  'german',
  'french',
  'english',
  'american',
  'hollywood',
  'music',
  'broadway',
  'football',
  'tennis',
  'covid',
  'trump',
  'merkel',
  'cars',
  'sports',
  'market',
  'economy',
  'financial',
];

/// Mock implementation.
/// This will be deprecated once the real discovery engine is available.
@singleton
class DiscoveryEngineManager extends Cubit<DiscoveryEngineState>
    with UseCaseBlocHelper<DiscoveryEngineState>
    implements xayn.DiscoveryEngine {
  final CreateHttpRequestUseCase _createHttpRequestUseCase;
  final InvokeApiEndpointUseCase _invokeApiEndpointUseCase;
  final StreamController<ClientEvent> _onClientEvent =
      StreamController<ClientEvent>();
  late final StreamSubscription<ClientEvent> _clientEventSubscription;
  final Random rnd = Random();

  late final UseCaseSink<String, ApiEndpointResponse> _handleQuery;

  late String nextFakeKeyword;

  bool _isLoading = false;

  Sink<ClientEvent> get onClientEvent => _onClientEvent.sink;

  DiscoveryEngineManager(
    this._createHttpRequestUseCase,
    this._invokeApiEndpointUseCase,
  ) : super(const DiscoveryEngineState.initial()) {
    _initGeneral();
    _initHandlers();
  }

  @override
  Future<void> close() {
    _onClientEvent.close();
    _clientEventSubscription.cancel();

    return super.close();
  }

  void _initGeneral() {
    nextFakeKeyword = randomKeywords[rnd.nextInt(randomKeywords.length)];

    _clientEventSubscription = _onClientEvent.stream.listen(_handleClientEvent);
  }

  void _initHandlers() {
    _handleQuery = pipe(_createHttpRequestUseCase).transform(
      (out) => out
          .followedBy(LogUseCase((it) => 'will fetch $it'))
          .followedBy(_invokeApiEndpointUseCase)
          .scheduleComputeState(
            condition: (data) => !data.isComplete,
            whenTrue: (data) => _isLoading = true,
          )
          .scheduleComputeState(
            condition: (data) => data.isComplete,
            whenTrue: (data) => _isLoading = false,
            swallowEvent: false,
          )
          .followedBy(
            LogUseCase(
              (it) => 'did fetch ${it.results.length} results',
              when: (it) => it.isComplete,
            ),
          ),
    );
  }

  @override
  Future<DiscoveryEngineState?> computeState() async =>
      fold(_handleQuery).foldAll((a, errorReport) {
        if (errorReport.isNotEmpty) {
          final errorAndStackTrace = errorReport.of(_handleQuery)!;

          return DiscoveryEngineState.error(
            error: errorAndStackTrace.error,
            stackTrace: errorAndStackTrace.stackTrace,
          );
        }

        if (_isLoading) {
          return const DiscoveryEngineState.loading();
        }

        if (a != null) {
          return _extractFakeKeywordAndEmit(a.results);
        }
      });

  void _handleClientEvent(ClientEvent event) {
    if (event is SearchRequested) _handleSearchEvent(event);
  }

  void _handleSearchEvent(SearchRequested event) {
    // ignore event query for now
    _handleQuery(nextFakeKeyword);
  }

  DiscoveryEngineState _extractFakeKeywordAndEmit(List<Document> nextResults) {
    nextFakeKeyword = _fakeNextKeywork(nextResults);

    if (nextResults.isEmpty) {
      _handleQuery(nextFakeKeyword);
    }

    return DiscoveryEngineState(results: nextResults, isComplete: true);
  }

  /// selects a random word from the combined set of [Result.description]s.
  String _fakeNextKeywork(List<Document> nextResults) {
    if (nextResults.isEmpty) {
      return randomKeywords[rnd.nextInt(randomKeywords.length)];
    }

    final words = nextResults
        .map((it) => it.webResource.snippet)
        .join(' ')
        .split(RegExp(r'[\s]+'))
        .where((it) => it.length >= 5)
        .toList(growable: false);

    if (words.isEmpty) {
      return randomKeywords[rnd.nextInt(randomKeywords.length)];
    }

    return words[rnd.nextInt(words.length)];
  }
}
