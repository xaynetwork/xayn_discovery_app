import 'dart:async';

import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/use_case/discovery_feed/discovery_feed.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/app_discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/connectivity/connectivity_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/log_use_case.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/util/use_case_sink_extensions.dart';

/// This is a temporary solution and will be removed as soon as the discovery engine
/// is able to provide us with search functionality itself.
mixin SearchMixin<T> on UseCaseBlocHelper<T> {
  Future<UseCaseSink<String, EngineEvent>>? _useCaseSink;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void search(String searchTerm) async {
    _useCaseSink ??= _getUseCaseSink();

    final useCaseSink = await _useCaseSink;

    useCaseSink!(searchTerm);
  }

  Future<UseCaseSink<String, EngineEvent>> _getUseCaseSink() async {
    final engine = await di.getAsync<DiscoveryEngine>() as AppDiscoveryEngine;
    final createHttpRequestUseCase = di.get<CreateHttpRequestUseCase>();
    final connectivityUseCase = di.get<ConnectivityUriUseCase>();
    final invokeApiEndpointUseCase = di.get<InvokeApiEndpointUseCase>();

    // logs when the api endpoint is about to be invoked.
    final willFetchLogUseCase = LogUseCase<Uri>(
      (it) => 'will fetch $it',
      logger: logger,
    );

    // logs when results were fetched.
    final didFetchLogUseCase = LogUseCase<ApiEndpointResponse>(
      (it) => 'did fetch ${it.results.length} results',
      when: (it) => it.isComplete,
      logger: logger,
    );

    // transforms the response into the expected EngineEvent type.
    // if successful, then it maps to a FeedRequestSucceeded event.
    // if unsuccessful, then a FeedRequestFailed event.
    mapToFeedEvent(ApiEndpointResponse it) {
      if (it.results.isNotEmpty) {
        engine.tempAddEvent(FeedRequestSucceeded(it.results));

        return FeedRequestSucceeded(it.results);
      }

      return const FeedRequestFailed(FeedFailureReason.noNewsForMarket);
    }

    return pipe(createHttpRequestUseCase).transform(
      (out) => out
          .followedBy(connectivityUseCase)
          .followedBy(willFetchLogUseCase)
          .followedBy(invokeApiEndpointUseCase)
          .scheduleComputeState(
            consumeEvent: (data) => !data.isComplete,
            run: (data) {
              _isLoading = !data.isComplete;
            },
          )
          .followedBy(didFetchLogUseCase)
          .map(mapToFeedEvent),
    )..autoSubscribe(
        onError: (e, s) => onError(e, s ?? StackTrace.current),
        onValue: (_) => scheduleComputeState(() {}),
      );
  }
}
