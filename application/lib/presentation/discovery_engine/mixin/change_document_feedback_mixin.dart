import 'dart:async';

import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/change_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/document_feedback_changed_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/util/use_case_sink_extensions.dart';

mixin ChangeDocumentFeedbackMixin<T> on UseCaseBlocHelper<T> {
  Future<UseCaseSink<DocumentFeedbackChange, EngineEvent>>? _useCaseSink;

  @override
  Future<void> close() {
    _useCaseSink = null;

    return super.close();
  }

  void changeDocumentFeedback({
    required Document document,
    required DocumentFeedback feedback,
  }) async {
    _useCaseSink ??= _getUseCaseSink();

    final useCaseSink = await _useCaseSink;
    final sendAnalyticsUseCase = await di.getAsync<SendAnalyticsUseCase>();

    useCaseSink!(DocumentFeedbackChange(
      documentId: document.documentId,
      feedback: feedback,
    ));

    sendAnalyticsUseCase(DocumentFeedbackChangedEvent(
        document: document.copyWith(feedback: feedback)));
  }

  Future<UseCaseSink<DocumentFeedbackChange, EngineEvent>>
      _getUseCaseSink() async {
    final useCase = await di.getAsync<ChangeDocumentFeedbackUseCase>();

    return pipe(useCase)
      ..autoSubscribe(onError: (e, s) => onError(e, s ?? StackTrace.current));
  }
}
