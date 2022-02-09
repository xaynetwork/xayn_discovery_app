import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/discovery_card_observation.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/change_document_feedback_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/log_document_time_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/document_time_spent_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_engine/discovery_card_observation_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/util/use_case_sink_extensions.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

/// a threshold, how long a user should observe a document, before it becomes
/// implicitly liked.
const int _kThresholdDurationSecondsImplicitLike = 5;

mixin ObserveDocumentMixin<T> on UseCaseBlocHelper<T> {
  UseCaseSink<DiscoveryCardObservation, EngineEvent>? _useCaseSink;

  @override
  Future<void> close() {
    _useCaseSink = null;

    return super.close();
  }

  void observeDocument({
    Document? document,
    DocumentViewMode? mode,
  }) {
    _useCaseSink ??= _getUseCaseSink();

    _useCaseSink!(DiscoveryCardObservation(
      document: document,
      viewType: mode,
    ));
  }

  UseCaseSink<DiscoveryCardObservation, EngineEvent> _getUseCaseSink() {
    final useCase = di.get<LogDocumentTimeUseCase>();
    final discoveryCardObservationUseCase =
        di.get<DiscoveryCardObservationUseCase>();
    final discoveryCardMeasuredObservationUseCase =
        di.get<DiscoveryCardMeasuredObservationUseCase>();
    final sendAnalyticsUseCase = di.get<SendAnalyticsUseCase>();
    final changeDocumentFeedbackUseCase =
        di.get<ChangeDocumentFeedbackUseCase>();

    return pipe(discoveryCardObservationUseCase).transform(
      (out) => out
          .distinct(
            (a, b) =>
                a.value.document?.documentId == b.value.document?.documentId &&
                a.value.viewType == b.value.viewType,
          )
          .pairwise() // combine last card and current card
          .followedBy(discoveryCardMeasuredObservationUseCase)
          .where((it) => it.document != null && it.viewType != null)
          .doOnData(
            _onDuration(
              sendAnalyticsUseCase: sendAnalyticsUseCase,
              changeDocumentFeedbackUseCase: changeDocumentFeedbackUseCase,
            ),
          )
          .map((it) => LogData(
                documentId: it.document!.documentId,
                mode: it.viewType!,
                duration: it.duration,
              ))
          .followedBy(useCase),
    )..autoSubscribe(onError: (e, s) => onError(e, s ?? StackTrace.current));
  }

  void Function(DiscoveryCardMeasuredObservation) _onDuration({
    required SendAnalyticsUseCase sendAnalyticsUseCase,
    required ChangeDocumentFeedbackUseCase changeDocumentFeedbackUseCase,
  }) =>
      (DiscoveryCardMeasuredObservation observation) {
        final document = observation.document!;
        final isCardOpened = observation.viewType != DocumentViewMode.story;
        final isObservedLongEnough = observation.duration.inSeconds >=
            _kThresholdDurationSecondsImplicitLike;

        sendAnalyticsUseCase(
          DocumentTimeSpentEvent(
              document: document,
              duration: observation.duration,
              viewMode: observation.viewType!),
        );

        if (isCardOpened && isObservedLongEnough) {
          changeDocumentFeedbackUseCase.singleOutput(DocumentFeedbackChange(
            documentId: document.documentId,
            feedback: DocumentFeedback.positive,
          ));
        }
      };
}
