import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/sources_management/sources_management_operation.dart';
import 'package:xayn_discovery_app/domain/model/sources_management/sources_management_task.dart';
import 'package:xayn_discovery_app/domain/model/user_interactions/user_interactions_events.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/engine_events_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/sources_management_single_changed_event.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/send_analytics_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/user_interactions/save_user_interaction_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/sources_management_mixin.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/page/source/manager/sources_pending_operations.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/page/source/manager/sources_state.dart';
import 'package:xayn_discovery_app/presentation/utils/environment_helper.dart';
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
typedef OnSetSourcesRequestSucceeded = SourcesState Function(
    SetSourcesRequestSucceeded event);
typedef OnNonMatchedEngineEvent = SourcesState Function();

enum SourceType { excluded, trusted }

const Duration _kSearchInputDebounceTime = Duration(seconds: 1);

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
  final SaveUserInteractionUseCase _saveUserInteractionUseCase;
  late final FoldEngineEvent foldEngineEvent = _foldEngineEvent();
  late final UseCaseValueStream<SourcesState> nextStateValueStream = consume(
    engineEventsUseCase,
    initialData: none,
  ).transform(
    (out) => out.map((it) => foldEngineEvent(state)(it)),
  );
  late final StreamController<String> _onSearchInput =
      StreamController<String>();
  StreamSubscription<String>? _searchInputSubscription;
  String? latestSourcesSearchTerm;

  SourcesManager(
    this._sendAnalyticsUseCase,
    this._sourcesScreenNavActions,
    this.engineEventsUseCase,
    this._saveUserInteractionUseCase,
    this.sourcesPendingOperations,
  ) : super(const SourcesState());

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
  void getAvailableSourcesList(String fuzzySearchTerm) =>
      _onSearchInput.add(fuzzySearchTerm);

  void init() {
    _searchInputSubscription = _searchInputSubscription ??
        _onSearchInput.stream
            .debounceTime(EnvironmentHelper.kIsInTest
                ? Duration.zero
                : _kSearchInputDebounceTime)
            .listen(_onSearchSources);

    getExcludedSourcesList();
    getTrustedSourcesList();
  }

  @override
  Future<void> close() async {
    _onSearchInput.close();

    await _searchInputSubscription?.cancel();
    await super.close();
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
  void applyChanges({required bool isBatchedProcess}) =>
      isBatchedProcess ? _applyBatchedChanges() : _applySingleChange();

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

  void _applyBatchedChanges() {
    final trustedSources = state.trustedSources.toSet();
    final excludedSources = state.excludedSources.toSet();

    for (final operation in sourcesPendingOperations.toSet()) {
      sourcesPendingOperations.removeOperation(operation);

      switch (operation.task) {
        case SourcesManagementTask.removeFromExcludedSources:
          excludedSources.remove(operation.source);
          _sendAnalyticsUseCase(
            SourcesManagementSingleChangedEvent(
              operation: SourcesManagementSingleChangedEventOperation.removal,
              sourceType: SourceType.excluded,
              isBatched: true,
            ),
          );
          _saveUserInteractionUseCase(
              UserInteractionsEvents.removeExcludedSource);
          break;
        case SourcesManagementTask.addToExcludedSources:
          excludedSources.add(operation.source);
          _sendAnalyticsUseCase(
            SourcesManagementSingleChangedEvent(
              operation: SourcesManagementSingleChangedEventOperation.addition,
              sourceType: SourceType.excluded,
              isBatched: true,
            ),
          );
          _saveUserInteractionUseCase(UserInteractionsEvents.excludedSource);
          break;
        case SourcesManagementTask.removeFromTrustedSources:
          trustedSources.remove(operation.source);
          _sendAnalyticsUseCase(
            SourcesManagementSingleChangedEvent(
              operation: SourcesManagementSingleChangedEventOperation.removal,
              sourceType: SourceType.trusted,
              isBatched: true,
            ),
          );
          _saveUserInteractionUseCase(
              UserInteractionsEvents.removeTrustedSource);
          break;
        case SourcesManagementTask.addToTrustedSources:
          trustedSources.add(operation.source);
          _sendAnalyticsUseCase(
            SourcesManagementSingleChangedEvent(
              operation: SourcesManagementSingleChangedEventOperation.addition,
              sourceType: SourceType.trusted,
              isBatched: true,
            ),
          );
          _saveUserInteractionUseCase(UserInteractionsEvents.trustedSource);
          break;
      }
    }

    overrideSources(
        trustedSources: trustedSources, excludedSources: excludedSources);
  }

  void _applySingleChange() {
    late final SourceType sourceType;
    late final SourcesManagementSingleChangedEventOperation sourceOperation;

    for (final operation in sourcesPendingOperations.toSet()) {
      sourcesPendingOperations.removeOperation(operation);

      switch (operation.task) {
        case SourcesManagementTask.removeFromExcludedSources:
          super.removeSourceFromExcludedList(operation.source);

          sourceType = SourceType.excluded;
          sourceOperation =
              SourcesManagementSingleChangedEventOperation.removal;
          _saveUserInteractionUseCase(
              UserInteractionsEvents.removeExcludedSource);
          break;
        case SourcesManagementTask.addToExcludedSources:
          super.addSourceToExcludedList(operation.source);

          sourceType = SourceType.excluded;
          sourceOperation =
              SourcesManagementSingleChangedEventOperation.addition;
          _saveUserInteractionUseCase(UserInteractionsEvents.excludedSource);
          break;
        case SourcesManagementTask.removeFromTrustedSources:
          super.removeSourceFromTrustedList(operation.source);

          sourceType = SourceType.trusted;
          sourceOperation =
              SourcesManagementSingleChangedEventOperation.removal;
          _saveUserInteractionUseCase(
              UserInteractionsEvents.removeTrustedSource);
          break;
        case SourcesManagementTask.addToTrustedSources:
          super.addSourceToTrustedList(operation.source);

          sourceType = SourceType.trusted;
          sourceOperation =
              SourcesManagementSingleChangedEventOperation.addition;
          _saveUserInteractionUseCase(UserInteractionsEvents.trustedSource);
          break;
      }
    }

    _sendAnalyticsUseCase(
      SourcesManagementSingleChangedEvent(
        sourceType: sourceType,
        operation: sourceOperation,
      ),
    );
  }

  void _onSearchSources(String fuzzySearchTerm) {
    super.getAvailableSourcesList(fuzzySearchTerm);

    scheduleComputeState(() => latestSourcesSearchTerm = fuzzySearchTerm);
  }

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
      required OnSetSourcesRequestSucceeded setSourcesRequestSucceeded,
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
          } else if (event is SetSourcesRequestSucceeded) {
            return setSourcesRequestSucceeded(event);
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
          setSourcesRequestSucceeded: (event) => state.copyWith(
            trustedSources: event.trustedSources,
            excludedSources: event.excludedSources,
          ),
          orElse: () => state,
        );
  }
}
