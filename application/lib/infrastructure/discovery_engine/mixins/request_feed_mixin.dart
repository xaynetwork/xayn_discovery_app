import 'dart:async';

import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/request_feed_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/request_next_feed_batch_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

mixin RequestFeedMixin<T> on UseCaseBlocHelper<T> {
  UseCaseSink<None, EngineEvent>? _useCaseSink;

  void requestNextFeedBatch() async {
    final useCaseSink = await _getUseCaseSink();

    useCaseSink(none);
  }

  Stream<T>? _stream;

  @override
  Stream<T> get stream => _stream ??=
      Stream.fromFuture(_startConsuming()).asyncExpand((_) => super.stream);

  Future<UseCaseSink<None, EngineEvent>> _getUseCaseSink() async {
    var sink = _useCaseSink;

    if (sink == null) {
      final useCase = await di.getAsync<RequestNextFeedBatchUseCase>();

      sink = _useCaseSink = pipe(useCase);
    }

    return sink;
  }

  Future<void> _startConsuming() async {
    final consumeUseCase = await di.getAsync<RequestFeedUseCase>();

    consume(consumeUseCase, initialData: none);
  }
}
