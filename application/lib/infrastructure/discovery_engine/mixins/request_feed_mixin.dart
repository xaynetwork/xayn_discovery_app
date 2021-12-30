import 'dart:async';

import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/use_case/discovery_feed/discovery_feed.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/app_discovery_engine.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/request_feed_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/request_next_feed_batch_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/connectivity/connectivity_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/log_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/random_keywords/random_keywords_use_case.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

mixin RequestFeedMixin<T> on UseCaseBlocHelper<T> {
  Future<UseCaseSink<None, EngineEvent>>? _useCaseSink;

  void requestNextFeedBatch() async {
    _useCaseSink ??= _getUseCaseSink();

    final useCaseSink = await _useCaseSink;

    useCaseSink!(none);
  }

  Stream<T>? _stream;

  @override
  Stream<T> get stream => _stream ??=
      Stream.fromFuture(_startConsuming()).asyncExpand((_) => super.stream);

  Future<UseCaseSink<None, EngineEvent>> _getUseCaseSink() async {
    final useCase = await di.getAsync<RequestNextFeedBatchUseCase>();
    final sink = pipe(useCase);

    return sink;
  }

  Future<void> _startConsuming() async {
    final consumeUseCase = await di.getAsync<RequestFeedUseCase>();

    consume(consumeUseCase, initialData: none);
  }
}

/// This is just a temporary class to "fake" the engine's feed.
mixin TempRequestFeedMixin<T> on UseCaseBlocHelper<T> {
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
  Stream<T> get stream => _stream ??=
      Stream.fromFuture(_startConsuming()).asyncExpand((_) => super.stream);

  Future<UseCaseSink<List<Document>, EngineEvent>> _getUseCaseSink() async {
    final engine = await di.getAsync<DiscoveryEngine>() as AppDiscoveryEngine;
    final randomKeyWordsUseCase = di.get<RandomKeyWordsUseCase>();
    final createHttpRequestUseCase = di.get<CreateHttpRequestUseCase>();
    final connectivityUseCase = di.get<ConnectivityUriUseCase>();
    final invokeApiEndpointUseCase = di.get<InvokeApiEndpointUseCase>();
    final sink = pipe(randomKeyWordsUseCase).transform(
      (out) => out
          .followedBy(createHttpRequestUseCase)
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
            _documentCache.addAll(it.results);
            engine.tempAddEvent(FeedRequestSucceeded(it.results));

            return FeedRequestSucceeded(it.results);
          }

          requestNextFeedBatch();

          return const FeedRequestFailed(FeedFailureReason.noNewsForMarket);
        },
      ),
    );

    fold(sink).foldAll((_, errorReport) {});

    return sink;
  }

  Future<void> _startConsuming() async {
    requestNextFeedBatch();
  }
}
