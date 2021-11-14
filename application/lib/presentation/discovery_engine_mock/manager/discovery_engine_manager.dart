import 'dart:async';

import 'package:xayn_architecture/concepts/on_failure.dart';
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
@singleton
class DiscoveryEngineManager extends Cubit<DiscoveryEngineState>
    with UseCaseBlocHelper<DiscoveryEngineState>
    implements xayn.DiscoveryEngine {
  final CreateHttpRequestUseCase _createHttpRequestUseCase;
  final InvokeApiEndpointUseCase _invokeApiEndpointUseCase;
  final StreamController<ClientEvent> _onClientEvent =
      StreamController<ClientEvent>();
  late final StreamSubscription<ClientEvent> _clientEventSubscription;

  late final Handler<String> _handleQuery;

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
    _clientEventSubscription = _onClientEvent.stream.listen(_handleClientEvent);
  }

  void _initHandlers() {
    _handleQuery = pipe(_createHttpRequestUseCase)
        .transform(
          (out) => out
              .followedBy(LogUseCase((it) => 'will fetch $it'))
              .followedBy(_invokeApiEndpointUseCase)
              .maybeResolveEarly(
                  condition: (data) => !data.isComplete,
                  stateBuilder: (data) => const DiscoveryEngineState.loading())
              .followedBy(
                LogUseCase(
                  (it) => 'did fetch ${it.results.length} results',
                  when: (it) => it.isComplete,
                ),
              ),
        )
        .fold(
          onSuccess: (it) =>
              DiscoveryEngineState(results: it.results, isComplete: true),
          onFailure: HandleFailure(
              (e, s) => DiscoveryEngineState.error(error: e, stackTrace: s),
              matchers: {
                On<ApiEndpointError>(
                  (e, s) => DiscoveryEngineState.error(error: e, stackTrace: s),
                ),
              }),
          guard: (nextState) {
            // allow going from loading state to filled state
            if (state.isLoading && nextState.isComplete) return true;

            // allow going from loading state to error state
            if (state.isLoading && nextState.hasError) return true;

            // allow going from error state to loading state
            if (state.hasError && nextState.isLoading) return true;

            // allow going from loaded state to loading state
            if (state.isComplete && nextState.isLoading) return true;

            // disallow any other changes
            return false;
          },
        );
  }

  void _handleClientEvent(ClientEvent event) {
    if (event is SearchRequested) _handleSearchEvent(event);
  }

  void _handleSearchEvent(SearchRequested event) {
    _handleQuery(event.term);
  }
}
