import 'dart:async';

import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/request_deep_search_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/util/use_case_sink_extensions.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

mixin RequestDeepSearchMixin<T> on UseCaseBlocHelper<T> {
  UseCaseSink<DocumentId, EngineEvent>? _useCaseSink;

  @override
  Future<void> close() {
    _useCaseSink = null;

    return super.close();
  }

  void requestDeepSearch(DocumentId documentId) async {
    await Future.delayed(const Duration(seconds: 2));
    _useCaseSink ??= _getUseCaseSink();
    _useCaseSink!(documentId);
  }

  UseCaseSink<DocumentId, EngineEvent> _getUseCaseSink() {
    final useCase = di.get<RequestDeepSearchUseCase>();

    return pipe(useCase)
      ..autoSubscribe(onError: (e, s) => onError(e, s ?? StackTrace.current));
  }
}
