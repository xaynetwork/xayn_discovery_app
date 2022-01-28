import 'dart:async';

import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/reset_engine_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/util/use_case_sink_extensions.dart';

mixin ResetEngineMixin<T> on UseCaseBlocHelper<T> {
  Future<UseCaseSink<None, EngineEvent>>? _useCaseSink;

  @override
  Future<void> close() {
    _useCaseSink = null;

    return super.close();
  }

  void resetEngine() async {
    _useCaseSink ??= _getUseCaseSink();

    final useCaseSink = await _useCaseSink;

    useCaseSink!(none);
  }

  Future<UseCaseSink<None, EngineEvent>> _getUseCaseSink() async {
    final useCase = di.get<ResetEngineUseCase>();

    return pipe(useCase)
      ..autoSubscribe(onError: (e, s) => onError(e, s ?? StackTrace.current));
  }
}
