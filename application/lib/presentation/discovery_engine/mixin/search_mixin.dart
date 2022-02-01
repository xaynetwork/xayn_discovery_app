import 'dart:async';

import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/request_feed_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/search_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/util/use_case_sink_extensions.dart';

mixin SearchMixin<T> on UseCaseBlocHelper<T> {
  Future<UseCaseSink<String, EngineEvent>>? _useCaseSink;
  bool _didStartConsuming = false;

  bool get isLoading => false;

  void search(String searchTerm) async {
    _useCaseSink ??= _getUseCaseSink();

    final useCaseSink = await _useCaseSink;

    useCaseSink!(searchTerm);
  }

  @override
  Stream<T> get stream {
    if (!_didStartConsuming) {
      _startConsuming();
    }

    return super.stream;
  }

  Future<UseCaseSink<String, EngineEvent>> _getUseCaseSink() async {
    final useCase = di.get<SearchUseCase>();

    return pipe(useCase)
      ..autoSubscribe(onError: (e, s) => onError(e, s ?? StackTrace.current));
  }

  void _startConsuming() {
    final consumeUseCase = di.get<RequestFeedUseCase>();

    _didStartConsuming = true;
    consume(consumeUseCase, initialData: none);
  }
}
