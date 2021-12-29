import 'dart:async';

import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/reset_engine_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

mixin ResetEngineMixin<T> on UseCaseBlocHelper<T> {
  UseCaseSink<None, EngineEvent>? _useCaseSink;

  void resetEngine() async {
    final useCaseSink = await _getUseCaseSink();

    useCaseSink(none);
  }

  Future<UseCaseSink<None, EngineEvent>> _getUseCaseSink() async {
    var sink = _useCaseSink;

    if (sink == null) {
      final useCase = await di.getAsync<ResetEngineUseCase>();

      sink = _useCaseSink = pipe(useCase);
    }

    return sink;
  }
}
