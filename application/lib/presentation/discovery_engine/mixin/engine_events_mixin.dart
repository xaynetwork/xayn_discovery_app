import 'dart:async';

import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/engine_events_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

mixin EngineEventsMixin<T> on UseCaseBlocHelper<T> {
  late final UseCaseValueStream<EngineEvent> engineEvents;
  bool _didStartConsuming = false;

  @override
  Stream<T> get stream {
    if (!_didStartConsuming) {
      _startConsuming();
    }

    return super.stream;
  }

  void _startConsuming() {
    final consumeUseCase = di.get<EngineEventsUseCase>();

    _didStartConsuming = true;
    engineEvents = consume(consumeUseCase, initialData: none);
  }
}
