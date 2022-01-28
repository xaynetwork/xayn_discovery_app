import 'dart:async';

import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/request_feed_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/request_next_feed_batch_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

mixin RequestFeedMixin<T> on UseCaseBlocHelper<T> {
  Future<UseCaseSink<None, EngineEvent>>? _useCaseSink;

  bool get isLoading => false;

  @override
  Future<void> close() {
    _useCaseSink = null;
    _stream = null;

    return super.close();
  }

  void requestNextFeedBatch() async {
    _useCaseSink ??= _getUseCaseSink();

    final useCaseSink = await _useCaseSink;

    useCaseSink!(none);
  }

  Stream<T>? _stream;

  @override
  Stream<T> get stream => _stream ??= Stream.fromFuture(_startConsuming())
      .asyncExpand((_) => super.stream)
      .asBroadcastStream();

  Future<UseCaseSink<None, EngineEvent>> _getUseCaseSink() async {
    final useCase = di.get<RequestNextFeedBatchUseCase>();
    final sink = pipe(useCase);

    return sink;
  }

  Future<void> _startConsuming() async {
    final consumeUseCase = di.get<RequestFeedUseCase>();

    consume(consumeUseCase, initialData: none);
  }
}
