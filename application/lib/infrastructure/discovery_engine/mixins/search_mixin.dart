import 'dart:async';

import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/use_case/discovery_feed/discovery_feed.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/request_feed_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/search_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/connectivity/connectivity_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/develop/log_use_case.dart';
import 'package:xayn_discovery_app/presentation/utils/logger.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

mixin SearchMixin<T> on UseCaseBlocHelper<T> {
  Future<UseCaseSink<String, EngineEvent>>? _useCaseSink;

  void search(String searchTerm) async {
    _useCaseSink ??= _getUseCaseSink();

    final useCaseSink = await _useCaseSink;

    useCaseSink!(searchTerm);
  }

  Stream<T>? _stream;

  @override
  Stream<T> get stream => _stream ??=
      Stream.fromFuture(_startConsuming()).asyncExpand((_) => super.stream);

  Future<UseCaseSink<String, EngineEvent>> _getUseCaseSink() async {
    final useCase = await di.getAsync<SearchUseCase>();
    final sink = pipe(useCase);

    return sink;
  }

  Future<void> _startConsuming() async {
    final consumeUseCase = await di.getAsync<RequestFeedUseCase>();

    consume(consumeUseCase, initialData: none);
  }
}

mixin TempSearchMixin<T> on UseCaseBlocHelper<T> {
  final List<Document> _documentCache = <Document>[];

  Future<UseCaseSink<String, EngineEvent>>? _useCaseSink;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<Document> get documents => _documentCache.toList(growable: false);

  void search(String searchTerm) async {
    _useCaseSink ??= _getUseCaseSink();

    final useCaseSink = await _useCaseSink;

    useCaseSink!(searchTerm);
  }

  Future<UseCaseSink<String, EngineEvent>> _getUseCaseSink() async {
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
            _documentCache.addAll(it.results);

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
