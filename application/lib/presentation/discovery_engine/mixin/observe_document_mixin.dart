import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/discovery_card_observation.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document.dart';
import 'package:xayn_discovery_app/domain/model/legacy/document_view_mode.dart';
import 'package:xayn_discovery_app/domain/model/legacy/events/engine_event.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/log_document_time_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_engine/discovery_card_observation_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/singleton_subscription_observer.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/util/use_case_sink_extensions.dart';

typedef OnObservation = void Function(
    DiscoveryCardMeasuredObservation observation);

mixin ObserveDocumentMixin<T> on SingletonSubscriptionObserver<T> {
  UseCaseSink<DiscoveryCardObservation, EngineEvent>? _useCaseSink;

  @override
  bool get allowSuspension => false;

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

    _useCaseSink!(
      DiscoveryCardObservation(
        document: document,
        viewType: mode,
      ),
    );
  }

  @override
  void onCancel() {
    observeDocument();

    super.onCancel();
  }

  UseCaseSink<DiscoveryCardObservation, EngineEvent> _getUseCaseSink() {
    final useCase = di.get<LogDocumentTimeUseCase>();
    final discoveryCardObservationUseCase =
        di.get<DiscoveryCardObservationUseCase>();
    final discoveryCardMeasuredObservationUseCase =
        di.get<DiscoveryCardMeasuredObservationUseCase>();

    observeAndTrack(DiscoveryCardMeasuredObservation observation) {
      onObservation(observation);
    }

    return pipe(discoveryCardObservationUseCase).transform(
      (out) => out
          .distinct(
            (a, b) =>
                a.value.document?.documentId == b.value.document?.documentId &&
                a.value.viewType == b.value.viewType,
          )
          .pairwise() // combine last card and current card
          .followedBy(discoveryCardMeasuredObservationUseCase)
          .where((it) =>
              it.document != null &&
              it.viewType != null &&
              it.duration.inSeconds > 0 &&
              isDocumentCurrentlyDisplayed(it.document!))
          .doOnData(observeAndTrack)
          .map((it) => LogData(
                documentId: it.document!.documentId,
                mode: it.viewType!,
                duration: it.duration,
              ))
          .followedBy(useCase),
    )..autoSubscribe(onError: (e, s) => onError(e, s ?? StackTrace.current));
  }

  /// Sync-checks if the document is not yet closed by the feed
  @mustCallSuper
  bool isDocumentCurrentlyDisplayed(Document document);

  @mustCallSuper
  void onObservation(DiscoveryCardMeasuredObservation observation) {}
}
