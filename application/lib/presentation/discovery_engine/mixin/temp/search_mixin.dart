import 'dart:async';

import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/use_case/discovery_feed/discovery_feed.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/app_discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/connectivity/connectivity_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/log_use_case.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

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
    final sink = pipe(createHttpRequestUseCase).transform(
      (out) => out
          .followedBy(connectivityUseCase)
          .followedBy(LogUseCase(
            (it) => 'will fetch $it',
            logger: logger,
          ))
          .followedBy(invokeApiEndpointUseCase)
          .scheduleComputeState(
            consumeEvent: (data) => !data.isComplete,
            run: (data) {
              _isLoading = !data.isComplete;
            },
          )
          .followedBy(
            LogUseCase(
              (it) => 'did fetch ${it.results.length} results',
              when: (it) => it.isComplete,
              logger: logger,
            ),
          )
          .map(
        (it) {
          if (it.results.isNotEmpty) {
            engine.tempAddEvent(FeedRequestSucceeded(it.results));

            return FeedRequestSucceeded(it.results);
          }

          return const FeedRequestFailed(FeedFailureReason.noNewsForMarket);
        },
      ),
    );

    fold(sink).foldAll((_, errorReport) => scheduleComputeState(() {}));

    return sink;
  }
}
