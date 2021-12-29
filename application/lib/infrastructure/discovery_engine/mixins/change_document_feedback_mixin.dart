import 'dart:async';

import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/change_document_feedback_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

mixin ChangeDocumentFeedbackMixin<T> on UseCaseBlocHelper<T> {
  UseCaseSink<DocumentFeedbackChange, EngineEvent>? _useCaseSink;

  void changeDocumentFeedback({
    required DocumentId documentId,
    required DocumentFeedback feedback,
  }) async {
    final useCaseSink = await _getUseCaseSink();

    useCaseSink(DocumentFeedbackChange(
      documentId: documentId,
      feedback: feedback,
    ));
  }

  Future<UseCaseSink<DocumentFeedbackChange, EngineEvent>>
      _getUseCaseSink() async {
    var sink = _useCaseSink;

    if (sink == null) {
      final useCase = await di.getAsync<ChangeDocumentFeedbackUseCase>();

      sink = _useCaseSink = pipe(useCase);
    }

    return sink;
  }
}
