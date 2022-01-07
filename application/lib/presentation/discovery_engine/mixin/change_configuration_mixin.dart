import 'dart:async';

import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/change_configuration_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart' hide Configuration;
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/util/use_case_sink_extensions.dart';

mixin ChangeConfigurationMixin<T> on UseCaseBlocHelper<T> {
  Future<UseCaseSink<Configuration, EngineEvent>>? _useCaseSink;

  @override
  Future<void> close() {
    _useCaseSink = null;

    return super.close();
  }

  void changeConfiguration({
    String? feedMarket,
    int? maxItemsPerFeedBatch,
  }) async {
    _useCaseSink ??= _getUseCaseSink();

    final useCaseSink = await _useCaseSink;

    useCaseSink!(Configuration(
      feedMarket: feedMarket,
      maxItemsPerFeedBatch: maxItemsPerFeedBatch,
    ));
  }

  Future<UseCaseSink<Configuration, EngineEvent>> _getUseCaseSink() async {
    final useCase = await di.getAsync<ChangeConfigurationUseCase>();

    return pipe(useCase)
      ..autoSubscribe(onError: (e, s) => onError(e, s ?? StackTrace.current));
  }
}
