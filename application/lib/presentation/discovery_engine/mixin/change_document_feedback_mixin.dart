import 'dart:async';

import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/document/document_feedback_context.dart';
import 'package:xayn_discovery_app/domain/model/document/explicit_document_feedback.dart';
import 'package:xayn_discovery_app/domain/model/unique_id.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/change_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/crud_explicit_document_feedback_use_case.dart';
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
  }) async {
    _useCaseSink ??= _getUseCaseSink();

    final isExplicit = context == FeedbackContext.explicit;
    final isNeutral = document.feedback == DocumentFeedback.neutral;

    // when explicit, then always propagate the feedback,
    // when implicit, only propagate when neutral.
    // should a user explicitly dislike a Document,
    // and then trigger an implicit like, then it will _not_ propagate.
    if (isExplicit || isNeutral) {
      await _maybeUpdateExplicitDocumentFeedback(
        document: document,
        feedback: feedback,
        context: context,
      );

      // updating the engine and sending analytics, should only
      // propagate _if_ the value actually changes.
      final willUpdateEngine = document.feedback != feedback;

      if (willUpdateEngine) {
        final sendAnalyticsUseCase = di.get<SendAnalyticsUseCase>();

        _useCaseSink!(
          DocumentFeedbackChange(
            documentId: document.documentId,
            feedback: feedback,
          ),
        );

        sendAnalyticsUseCase(
          DocumentFeedbackChangedEvent(
            document: document.copyWith(feedback: feedback),
            context: context,
          ),
        );
      }
    }
  }

  Future<void> _maybeUpdateExplicitDocumentFeedback({
    required Document document,
    required DocumentFeedback feedback,
    required FeedbackContext context,
  }) async {
    if (context == FeedbackContext.explicit) {
      final crudExplicitDocumentFeedbackUseCase =
          di.get<CrudExplicitDocumentFeedbackUseCase>();

      await crudExplicitDocumentFeedbackUseCase.singleOutput(
        CrudExplicitDocumentFeedbackUseCaseIn.store(
          ExplicitDocumentFeedback(
            id: UniqueId.fromTrustedString(document.documentId.toString()),
            feedback: feedback,
          ),
        ),
      );
    }
  }

  UseCaseSink<DocumentFeedbackChange, EngineEvent> _getUseCaseSink() {
    final useCase = di.get<ChangeDocumentFeedbackUseCase>();

    return pipe(useCase)
      ..autoSubscribe(onError: (e, s) => onError(e, s ?? StackTrace.current));
  }
}
