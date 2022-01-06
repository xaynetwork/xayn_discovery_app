import 'dart:async';

import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/request_feed_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/search_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

mixin SearchMixin<T> on UseCaseBlocHelper<T> {
  Future<UseCaseSink<String, EngineEvent>>? _useCaseSink;

  bool get isLoading => false;

  void search(String searchTerm) async {
    _useCaseSink ??= _getUseCaseSink();

    final useCaseSink = await _useCaseSink;

    useCaseSink!(searchTerm);
  }

  Stream<T>? _stream;

  @override
  Stream<T> get stream => _stream ??= Stream.fromFuture(_startConsuming())
      .asyncExpand((_) => super.stream)
      .asBroadcastStream();

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
