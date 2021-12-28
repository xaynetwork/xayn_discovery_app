import 'dart:async';

import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/change_configuration_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart' hide Configuration;

mixin ChangeConfigurationMixin<T> on UseCaseBlocHelper<T> {
  UseCaseSink<Configuration, EngineEvent>? changeConfigurationSink;

  Stream<T>? _stream;

  @override
  Stream<T> get stream => _stream ??=
      Stream.fromFuture(_getUseCaseSink()).asyncExpand((_) => super.stream);

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
    var sink = changeConfigurationSink;

    if (sink == null) {
      final useCase = await di.getAsync<ChangeConfigurationUseCase>();

      sink = changeConfigurationSink = pipe(useCase);

      fold(sink).foldAll((engineEvent, errorReport) => null);
    }

    return sink;
  }
}
