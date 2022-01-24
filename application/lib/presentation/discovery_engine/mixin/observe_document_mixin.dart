import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/discovery_card_observation.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/log_document_time_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/document_time_spent_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/discovery_engine/discovery_card_observation_use_case.dart';
import 'package:xayn_discovery_engine/discovery_engine.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/util/use_case_sink_extensions.dart';

mixin ObserveDocumentMixin<T> on UseCaseBlocHelper<T> {
  Future<UseCaseSink<DiscoveryCardObservation, EngineEvent>>? _useCaseSink;

  @override
  Future<void> close() {
    _useCaseSink = null;

    return super.close();
  }

  void observeDocument({
    Document? document,
    DocumentViewMode? mode,
  }) async {
    _useCaseSink ??= _getUseCaseSink();

    final useCaseSink = await _useCaseSink;

    useCaseSink!(DiscoveryCardObservation(
      document: document,
      viewType: mode,
    ));
  }

  Future<UseCaseSink<DiscoveryCardObservation, EngineEvent>>
      _getUseCaseSink() async {
    final useCase = await di.getAsync<LogDocumentTimeUseCase>();
    final discoveryCardObservationUseCase =
        di.get<DiscoveryCardObservationUseCase>();
    final discoveryCardMeasuredObservationUseCase =
        di.get<DiscoveryCardMeasuredObservationUseCase>();
    final sendAnalyticsUseCase = await di.getAsync<SendAnalyticsUseCase>();

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
            (it) => sendAnalyticsUseCase(
              DocumentTimeSpentEvent(
                  document: it.document!,
                  duration: it.duration,
                  viewMode: it.viewType!),
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
}
