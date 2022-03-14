import 'dart:async';

import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/request_feed_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/request_next_feed_batch_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/util/use_case_sink_extensions.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

mixin RequestFeedMixin<T> on UseCaseBlocHelper<T> {
  late final RequestNextFeedBatchUseCase requestNextFeedBatchUseCase =
      di.get<RequestNextFeedBatchUseCase>();
  UseCaseSink<None, EngineEvent>? _useCaseSink;
  bool _didStartConsuming = false;

  void requestNextFeedBatch() {
    _useCaseSink ??= _getUseCaseSink();

    _useCaseSink!(none);
  }

  @override
  Stream<T> get stream {
    if (!_didStartConsuming) {
      _startConsuming();
    }

    return super.stream;
  }

  UseCaseSink<None, EngineEvent> _getUseCaseSink() {
    return pipe(requestNextFeedBatchUseCase)
      ..autoSubscribe(onError: (e, s) => onError(e, s ?? StackTrace.current));
  }

  void _startConsuming() {
    final consumeUseCase = di.get<RequestFeedUseCase>();
    final maybeRequestNextBatchUseCase =
        _MaybeRequestNextBatchWhenEmptyUseCase(requestNextFeedBatchUseCase);

    _didStartConsuming = true;

    consume(consumeUseCase, initialData: none)
        .transform((out) => out.switchedBy(maybeRequestNextBatchUseCase))
        .autoSubscribe(onError: (e, s) => onError(e, s ?? StackTrace.current));
  }
}

class _MaybeRequestNextBatchWhenEmptyUseCase
    extends UseCase<EngineEvent, EngineEvent> {
  final RequestNextFeedBatchUseCase maybeRequestNextBatchUseCase;

  _MaybeRequestNextBatchWhenEmptyUseCase(this.maybeRequestNextBatchUseCase);

  @override
  Stream<EngineEvent> transaction(EngineEvent param) async* {
    if (param is RestoreFeedSucceeded && param.items.isEmpty) {
      yield await maybeRequestNextBatchUseCase.singleOutput(none);
    }

    yield param;
  }
}
