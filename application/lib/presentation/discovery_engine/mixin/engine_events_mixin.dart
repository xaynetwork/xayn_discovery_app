import 'dart:async';

import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/engine_events_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

mixin EngineEventsMixin<T> on UseCaseBlocHelper<T> {
  late final UseCaseValueStream<EngineEvent> engineEvents;

  @override
  Future<void> close() {
    _stream = null;

    return super.close();
  }

  Stream<T>? _stream;

  @override
  Stream<T> get stream => _stream ??= Stream.fromFuture(_startConsuming())
      .asyncExpand((_) => super.stream)
      .asBroadcastStream();

  Future<void> _startConsuming() async {
    final consumeUseCase = di.get<EngineEventsUseCase>();

    engineEvents = consume(consumeUseCase, initialData: none);
  }
}
