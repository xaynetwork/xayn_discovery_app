import 'dart:async';

import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/change_configuration_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart' hide Configuration;

mixin ChangeConfigurationMixin<T> on UseCaseBlocHelper<T> {
  UseCaseSink<Configuration, EngineEvent>? _useCaseSink;

  void changeConfiguration({
    String? feedMarket,
    int? maxItemsPerFeedBatch,
  }) async {
    final useCaseSink = await _getUseCaseSink();

    useCaseSink(Configuration(
      feedMarket: feedMarket,
      maxItemsPerFeedBatch: maxItemsPerFeedBatch,
    ));
  }

  Future<UseCaseSink<Configuration, EngineEvent>> _getUseCaseSink() async {
    var sink = _useCaseSink;

    if (sink == null) {
      final useCase = await di.getAsync<ChangeConfigurationUseCase>();

      sink = _useCaseSink = pipe(useCase);

      fold(sink).foldAll((engineEvent, errorReport) => null);
    }

    return sink;
  }
}
