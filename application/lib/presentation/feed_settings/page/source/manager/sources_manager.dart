import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/analytics/analytics_event.dart';
import 'package:xayn_discovery_app/domain/model/sources_management/sources_management_operation.dart';
import 'package:xayn_discovery_app/domain/model/sources_management/sources_management_task.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/engine_events_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/sources_management_changed_event.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/sources_management_single_changed_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/sources_management_mixin.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/page/source/manager/sources_pending_operations.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/page/source/manager/sources_state.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_data.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_manager_mixin.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

typedef FoldEngineEvent = SourcesState Function(EngineEvent?) Function(
    SourcesState);
typedef OnGetAvailableSourcesListSucceeded = SourcesState Function(
    AvailableSourcesListRequestSucceeded event);
typedef OnExcludedSourcesListRequestSucceeded = SourcesState Function(
    ExcludedSourcesListRequestSucceeded event);
typedef OnTrustedSourcesListRequestSucceeded = SourcesState Function(
    TrustedSourcesListRequestSucceeded event);
typedef OnAddExcludeSourceSucceeded = SourcesState Function(
    AddExcludedSourceRequestSucceeded event);
typedef OnRemoveExcludeSourceSucceeded = SourcesState Function(
    RemoveExcludedSourceRequestSucceeded event);
typedef OnAddTrustSourceSucceeded = SourcesState Function(
    AddTrustedSourceRequestSucceeded event);
typedef OnRemoveTrustSourceSucceeded = SourcesState Function(
    RemoveTrustedSourceRequestSucceeded event);
typedef OnNonMatchedEngineEvent = SourcesState Function();

enum SourceType { excluded, trusted }

abstract class SourcesScreenNavActions {
  void onDismissSourcesSelection();
  void onLoadExcludedSourcesInterface();
  void onLoadTrustedSourcesInterface();
}

@lazySingleton
class SourcesManager extends Cubit<SourcesState>
    with
        UseCaseBlocHelper<SourcesState>,
        SourcesManagementMixin<SourcesState>,
        OverlayManagerMixin<SourcesState>
    implements SourcesScreenNavActions {
  final EngineEventsUseCase engineEventsUseCase;
  final SourcesPendingOperations sourcesPendingOperations;
  final SourcesScreenNavActions _sourcesScreenNavActions;
  final SendAnalyticsUseCase _sendAnalyticsUseCase;
  late final FoldEngineEvent foldEngineEvent = _foldEngineEvent();
  late final UseCaseValueStream<SourcesState> nextStateValueStream = consume(
    engineEventsUseCase,
    initialData: none,
  ).transform(
    (out) => out.map((it) => foldEngineEvent(state)(it)),
  );
  String? latestSourcesSearchTerm;

  SourcesManager(
    this._sendAnalyticsUseCase,
    this._sourcesScreenNavActions,
    this.engineEventsUseCase,
    this.sourcesPendingOperations,
  ) : super(const SourcesState()) {
    _init();
  }

  @override
  void onDismissSourcesSelection() =>
      _sourcesScreenNavActions.onDismissSourcesSelection();

  @override
  void onLoadExcludedSourcesInterface() =>
      _sourcesScreenNavActions.onLoadExcludedSourcesInterface();

  @override
  void onLoadTrustedSourcesInterface() =>
      _sourcesScreenNavActions.onLoadTrustedSourcesInterface();

  void resetAvailableSourcesList() =>
      scheduleComputeState(() => latestSourcesSearchTerm = null);

  @override
  void getAvailableSourcesList(String fuzzySearchTerm) {
    super.getAvailableSourcesList(fuzzySearchTerm);

    scheduleComputeState(() => latestSourcesSearchTerm = fuzzySearchTerm);
  }

  void _init() {
    getExcludedSourcesList();
    getTrustedSourcesList();
  }

  bool canAddSourceToExcludedList(Source source) =>
      !state.excludedSources.contains(source);

  bool canAddSourceToTrustedList(Source source) =>
      !state.trustedSources.contains(source);

  bool isPendingRemoval({required Source source, required SourceType scope}) {
    switch (scope) {
      case SourceType.excluded:
        return sourcesPendingOperations
            .containsRemoveFromExcludedSources(source);
      case SourceType.trusted:
        return sourcesPendingOperations
            .containsRemoveFromTrustedSources(source);
    }
  }

  bool isPendingAddition({required Source source, required SourceType scope}) {
    switch (scope) {
      case SourceType.excluded:
        return sourcesPendingOperations.containsAddToExcludedSources(source);
      case SourceType.trusted:
        return sourcesPendingOperations.containsAddToTrustedSources(source);
    }
  }

  @override
  void removeSourceFromExcludedList(Source source) =>
      scheduleComputeState(() => sourcesPendingOperations.addOperation(
          SourcesManagementOperation.removeFromExcludedSources(source)));

  @override
  void addSourceToExcludedList(Source source) =>
      scheduleComputeState(() => sourcesPendingOperations.addOperation(
          SourcesManagementOperation.addToExcludedSources(source)));

  @override
  void removeSourceFromTrustedList(Source source) =>
      scheduleComputeState(() => sourcesPendingOperations.addOperation(
          SourcesManagementOperation.removeFromTrustedSources(source)));

  @override
  void addSourceToTrustedList(Source source) =>
      scheduleComputeState(() => sourcesPendingOperations.addOperation(
          SourcesManagementOperation.addToTrustedSources(source)));

  /// Call this method to undo any operations related to [source].
  /// Once [applyChanges] is triggered, operations are persisted, and then
  /// calling this method will no longer have effect.
  void removePendingSourceOperation(Source source) => scheduleComputeState(
      () => sourcesPendingOperations.removeOperationsBySource(source));

  /// This method will persist any pending [SourcesManagementOperation] with
  /// the engine.
  /// When completed, the pending operations are flushed, and the [state] will
  /// emit with updated engine list values.
  /// Use [intervalBetweenOperations] to wait between 2 operations, which, if used,
  /// gives the UI some time to visually indicate each addition/removal.
  /// The default value is 1 second.
  void applyChanges({required bool isBatchedProcess}) {
    final oldTrustedCount = state.trustedSources.length;
    final oldExcludedCount = state.excludedSources.length;
    var newTrustedCount = oldTrustedCount;
    var newExcludedCount = oldExcludedCount;
    AnalyticsEvent? analyticsEvent;

    for (final operation in sourcesPendingOperations.toSet()) {
      sourcesPendingOperations.removeOperation(operation);

      switch (operation.task) {
        case SourcesManagementTask.removeFromExcludedSources:
          if (newExcludedCount > 0) newExcludedCount--;
          super.removeSourceFromExcludedList(operation.source);
          break;
        case SourcesManagementTask.addToExcludedSources:
          newExcludedCount++;
          super.addSourceToExcludedList(operation.source);
          break;
        case SourcesManagementTask.removeFromTrustedSources:
          if (newTrustedCount > 0) newTrustedCount--;
          super.removeSourceFromTrustedList(operation.source);
          break;
        case SourcesManagementTask.addToTrustedSources:
          newTrustedCount++;
          super.addSourceToTrustedList(operation.source);
          break;
      }
    }

    if (isBatchedProcess) {
      if (newTrustedCount != oldTrustedCount ||
          newExcludedCount != oldExcludedCount) {
        analyticsEvent = SourcesManagementChangedEvent(
          newTrustedCount: newTrustedCount,
          oldTrustedCount: oldTrustedCount,
          newExcludedCount: newExcludedCount,
          oldExcludedCount: oldExcludedCount,
        );
      }
    } else {
      // in this case, only a single source was affected,
      // so old and new are all the same values, except for 1 of the 4,
      // which is then either +1 or -1
      final sourceType = newTrustedCount != oldTrustedCount
          ? SourceType.trusted
          : SourceType.excluded;
      final operation = newTrustedCount + newExcludedCount >
              oldTrustedCount + oldExcludedCount
          ? SourcesManagementSingleChangedEventOperation.addition
          : SourcesManagementSingleChangedEventOperation.removal;

      analyticsEvent = SourcesManagementSingleChangedEvent(
        sourceType: sourceType,
        operation: operation,
      );
    }

    if (analyticsEvent != null) _sendAnalyticsUseCase(analyticsEvent);
  }

  @override
  Future<SourcesState?> computeState() async =>
      fold(nextStateValueStream).foldAll((nextState, errorReport) async {
        if (errorReport.exists(nextStateValueStream)) {
          final report = errorReport.of(nextStateValueStream)!;

          showOverlay(
            OverlayData.bottomSheetGenericError(
              errorCode: report.error.toString(),
            ),
          );
        }

        return nextState?.copyWith(
          jointExcludedSources: {
            ...nextState.excludedSources,
            ...sourcesPendingOperations
                .sourcesByTask(SourcesManagementTask.addToExcludedSources)
          },
          jointTrustedSources: {
            ...nextState.trustedSources,
            ...sourcesPendingOperations
                .sourcesByTask(SourcesManagementTask.addToTrustedSources)
          },
          operations: sourcesPendingOperations.toSet(),
          sourcesSearchTerm: latestSourcesSearchTerm,
          availableSources: latestSourcesSearchTerm == null ||
                  latestSourcesSearchTerm!.length < 3
              ? const <AvailableSource>{}
              : nextState.availableSources,
        );
      });

  static SourcesState Function(EngineEvent?) Function(SourcesState)
      _foldEngineEvent() {
    foldEngineEvent({
      required OnGetAvailableSourcesListSucceeded
          getAvailableSourcesListSucceeded,
      required OnExcludedSourcesListRequestSucceeded
          excludedSourcesListRequestSucceeded,
      required OnTrustedSourcesListRequestSucceeded
          trustedSourcesListRequestSucceeded,
      required OnAddExcludeSourceSucceeded addExcludeSourceSucceeded,
      required OnRemoveExcludeSourceSucceeded removeExcludeSourceSucceeded,
      required OnAddTrustSourceSucceeded addTrustSourceSucceeded,
      required OnRemoveTrustSourceSucceeded removeTrustedSourceSucceeded,
      required OnNonMatchedEngineEvent orElse,
    }) =>
        (EngineEvent? event) {
          if (event is AvailableSourcesListRequestSucceeded) {
            return getAvailableSourcesListSucceeded(event);
          } else if (event is ExcludedSourcesListRequestSucceeded) {
            return excludedSourcesListRequestSucceeded(event);
          } else if (event is TrustedSourcesListRequestSucceeded) {
            return trustedSourcesListRequestSucceeded(event);
          } else if (event is AddExcludedSourceRequestSucceeded) {
            return addExcludeSourceSucceeded(event);
          } else if (event is RemoveExcludedSourceRequestSucceeded) {
            return removeExcludeSourceSucceeded(event);
          } else if (event is AddTrustedSourceRequestSucceeded) {
            return addTrustSourceSucceeded(event);
          } else if (event is RemoveTrustedSourceRequestSucceeded) {
            return removeTrustedSourceSucceeded(event);
          }

          return orElse();
        };

    return (SourcesState state) => foldEngineEvent(
          getAvailableSourcesListSucceeded: (event) =>
              state.copyWith(availableSources: event.availableSources.toSet()),
          excludedSourcesListRequestSucceeded: (event) =>
              state.copyWith(excludedSources: event.excludedSources),
          trustedSourcesListRequestSucceeded: (event) =>
              state.copyWith(trustedSources: event.sources),
          addExcludeSourceSucceeded: (event) => state.copyWith(
            excludedSources: {
              ...state.excludedSources,
              event.source,
            },
          ),
          removeExcludeSourceSucceeded: (event) => state.copyWith(
              excludedSources: state.excludedSources.toSet()
                ..remove(event.source)),
          addTrustSourceSucceeded: (event) => state.copyWith(
            trustedSources: {
              ...state.trustedSources,
              event.source,
            },
          ),
          removeTrustedSourceSucceeded: (event) => state.copyWith(
              trustedSources: state.trustedSources.toSet()
                ..remove(event.source)),
          orElse: () => state,
        );
  }
}
