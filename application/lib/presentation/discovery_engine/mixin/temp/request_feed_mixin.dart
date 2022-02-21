import 'dart:async';

import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/use_case/discovery_feed/discovery_feed.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/app_discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/connectivity/connectivity_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/log_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/random_keywords/random_keywords_use_case.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart' hide logger;
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/util/use_case_sink_extensions.dart';

/// This is a temporary solution and will be removed as soon as the discovery engine
/// is able to provide us with a feed itself.
mixin RequestFeedMixin<T> on UseCaseBlocHelper<T> {
  final List<Document> _documentCache = <Document>[];

  Future<UseCaseSink<List<Document>, EngineEvent>>? _useCaseSink;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void requestNextFeedBatch() async {
    _useCaseSink ??= _getUseCaseSink();

    final useCaseSink = await _useCaseSink;

    useCaseSink!(_documentCache);
  }

  Stream<T>? _stream;

  @override
  Stream<T> get stream => _stream ??= Stream.fromFuture(_startConsuming())
      .asyncExpand((_) => super.stream)
      .asBroadcastStream();

  Future<UseCaseSink<List<Document>, EngineEvent>> _getUseCaseSink() async {
    final engine = di.get<DiscoveryEngine>() as AppDiscoveryEngine;
    final randomKeyWordsUseCase = di.get<RandomKeyWordsUseCase>();
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
        _documentCache.addAll(it.results);
        engine.tempAddEvent(FeedRequestSucceeded(it.results));

        return FeedRequestSucceeded(it.results);
      }

      requestNextFeedBatch();

      return const FeedRequestFailed(FeedFailureReason.noNewsForMarket);
    }

    return pipe(randomKeyWordsUseCase).transform(
      (out) => out
          .followedBy(createHttpRequestUseCase)
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
      );
  }

  Future<void> _startConsuming() async {
    requestNextFeedBatch();
  }
}
