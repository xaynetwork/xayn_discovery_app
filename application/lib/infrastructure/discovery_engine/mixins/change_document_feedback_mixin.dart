import 'dart:async';

import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/change_document_feedback_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

mixin ChangeDocumentFeedbackMixin<T> on UseCaseBlocHelper<T> {
  Future<UseCaseSink<DocumentFeedbackChange, EngineEvent>>? _useCaseSink;

  void changeDocumentFeedback({
    required DocumentId documentId,
    required DocumentFeedback feedback,
  }) async {
    _useCaseSink ??= _getUseCaseSink();

    final useCaseSink = await _useCaseSink;

    useCaseSink!(DocumentFeedbackChange(
      documentId: documentId,
      feedback: feedback,
    ));
  }

  Future<UseCaseSink<DocumentFeedbackChange, EngineEvent>>
      _getUseCaseSink() async {
    final useCase = await di.getAsync<ChangeDocumentFeedbackUseCase>();
    final sink = pipe(useCase);

    fold(sink).foldAll((_, errorReport) {});

    return sink;
  }
}
