import 'dart:async';

import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/document/document_feedback_context.dart';
import 'package:xayn_discovery_app/domain/model/document/explicit_document_feedback.dart';
import 'package:xayn_discovery_app/domain/model/extensions/document_extension.dart';
import 'package:xayn_discovery_app/domain/model/feed/feed_type.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/change_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/crud_explicit_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/document_feedback_changed_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/crud/db_entity_crud_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/util/use_case_sink_extensions.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';

mixin ChangeUserReactionMixin<T> on UseCaseBlocHelper<T> {
  UseCaseSink<DocumentFeedbackChange, EngineEvent>? _useCaseSink;

  @override
  Future<void> close() {
    _useCaseSink = null;

    return super.close();
  }

  void changeUserReaction({
    required Document document,
    required UserReaction userReaction,
    required FeedbackContext context,
    required FeedType? feedType,
  }) async {
    _useCaseSink ??= _getUseCaseSink();

    final isExplicit = context == FeedbackContext.explicit;

    // when explicit, then always propagate the feedback,
    // when implicit, only propagate when neutral.
    // should a user explicitly dislike a Document,
    // and then trigger an implicit like, then it will _not_ propagate.
    if (isExplicit || document.userReaction.isNeutral) {
      await _maybeUpdateExplicitDocumentFeedback(
        document: document,
        userReaction: userReaction,
        context: context,
      );

      // updating the engine and sending analytics, should only
      // propagate _if_ the value actually changes.
      final willUpdateEngine = document.userReaction != userReaction;

      if (willUpdateEngine) {
        final sendAnalyticsUseCase = di.get<SendAnalyticsUseCase>();

        _useCaseSink!(
          DocumentFeedbackChange(
            documentId: document.documentId,
            userReaction: userReaction,
          ),
        );

        sendAnalyticsUseCase(
          DocumentFeedbackChangedEvent(
            document: document.copyWith(userReaction: userReaction),
            context: context,
            feedType: feedType,
          ),
        );
      }
    }
  }

  Future<void> _maybeUpdateExplicitDocumentFeedback({
    required Document document,
    required UserReaction userReaction,
    required FeedbackContext context,
  }) async {
    if (context == FeedbackContext.explicit) {
      final crudExplicitDocumentFeedbackUseCase =
          di.get<CrudExplicitDocumentFeedbackUseCase>();

      await crudExplicitDocumentFeedbackUseCase.singleOutput(
        DbCrudIn.store(
          ExplicitDocumentFeedback(
            id: document.documentId.uniqueId,
            userReaction: userReaction,
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
