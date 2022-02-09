import 'dart:async';

import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/document/document_feedback_context.dart';
import 'package:xayn_discovery_app/domain/model/document/explicit_document_feedback.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/change_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/save_explicit_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/document_feedback_changed_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/util/use_case_sink_extensions.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

mixin ChangeDocumentFeedbackMixin<T> on UseCaseBlocHelper<T> {
  UseCaseSink<DocumentFeedbackChange, EngineEvent>? _useCaseSink;

  @override
  Future<void> close() {
    _useCaseSink = null;

    return super.close();
  }

  void changeDocumentFeedback({
    required Document document,
    required DocumentFeedback feedback,
    required FeedbackContext context,
  }) {
    if (document.feedback == feedback) return;

    _useCaseSink ??= _getUseCaseSink();

    final sendAnalyticsUseCase = di.get<SendAnalyticsUseCase>();

    _useCaseSink!(DocumentFeedbackChange(
      documentId: document.documentId,
      feedback: feedback,
    ));

    if (context == FeedbackContext.explicit) {
      final saveExplicitDocumentFeedbackUseCase =
          di.get<SaveExplicitDocumentFeedbackUseCase>();

      saveExplicitDocumentFeedbackUseCase(ExplicitDocumentFeedback(
        id: UniqueId.fromTrustedString(document.documentId.toString()),
        feedback: feedback,
      ));
    }

    sendAnalyticsUseCase(
      DocumentFeedbackChangedEvent(
        document: document.copyWith(feedback: feedback),
        context: context,
      ),
    );
  }

  UseCaseSink<DocumentFeedbackChange, EngineEvent> _getUseCaseSink() {
    final useCase = di.get<ChangeDocumentFeedbackUseCase>();

    return pipe(useCase)
      ..autoSubscribe(onError: (e, s) => onError(e, s ?? StackTrace.current));
  }
}
