import 'dart:async';

import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/log_document_time_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

mixin LogDocumentTimeMixin<T> on UseCaseBlocHelper<T> {
  UseCaseSink<LogData, EngineEvent>? _useCaseSink;

  void logDocumentTime(
    DocumentId documentId,
    DocumentViewMode mode,
    Duration duration,
  ) async {
    final useCaseSink = await _getUseCaseSink();

    useCaseSink(LogData(
      documentId: documentId,
      mode: mode,
      duration: duration,
    ));
  }

  Future<UseCaseSink<LogData, EngineEvent>> _getUseCaseSink() async {
    var sink = _useCaseSink;

    if (sink == null) {
      final useCase = await di.getAsync<LogDocumentTimeUseCase>();

      sink = _useCaseSink = pipe(useCase);
    }

    return sink;
  }
}
