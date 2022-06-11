import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/sources_management/sources_management_operation.dart';
import 'package:xayn_discovery_app/domain/model/sources_management/sources_management_task.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/engine_events_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/sources_management_mixin.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/page/source/manager/sources_pending_operations.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/page/source/manager/sources_state.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/page/source/manager/temp.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';
// ignore: implementation_imports
import 'package:xayn_discovery_engine/src/api/events/engine_events.dart';

const Duration _kRemovalInterval = Duration(seconds: 1);

typedef FoldEngineEvent = SourcesState Function(EngineEvent?) Function(
    SourcesState);
typedef OnGetAvailableSourcesListSucceeded = SourcesState Function(
    AvailableSourcesListRequestSucceeded event);
typedef OnExcludedSourcesListRequestSucceeded = SourcesState Function(
    ExcludedSourcesListRequestSucceeded event);
typedef OnTrustedSourcesListRequestSucceeded = SourcesState Function(
    TrustedSourcesListRequestSucceeded event);
typedef OnAddExcludeSourceSucceeded = SourcesState Function(
    AddExcludedSourceSucceeded event);
typedef OnRemoveExcludeSourceSucceeded = SourcesState Function(
    RemoveExcludedSourceSucceeded event);
typedef OnAddTrustSourceSucceeded = SourcesState Function(
    AddTrustedSourceSucceeded event);
typedef OnRemoveTrustSourceSucceeded = SourcesState Function(
    RemoveTrustedSourceSucceeded event);
typedef OnNonMatchedEngineEvent = SourcesState Function();

enum Scope { excludedSources, trustedSources }

@injectable
class SourcesManager extends Cubit<SourcesState>
    with UseCaseBlocHelper<SourcesState>, SourcesManagementMixin<SourcesState> {
  final EngineEventsUseCase engineEventsUseCase;
  final SourcesPendingOperations sourcesPendingOperations;
  late final FoldEngineEvent foldEngineEvent = _foldEngineEvent();
  late final UseCaseValueStream<SourcesState> nextStateValueStream = consume(
    engineEventsUseCase,
    initialData: none,
  ).transform(
    (out) => out.map((it) => foldEngineEvent(state)(it)),
  );

  SourcesManager(
    this.engineEventsUseCase,
    this.sourcesPendingOperations,
  ) : super(const SourcesState());

  /// Trigger this manager to load both [Source] lists.
  /// This method is typically invoked by a `Widget` when running `Widget.initState`.
  void init() {
    getExcludedSourcesList();
    getTrustedSourcesList();
  }

  bool canAddSourceToExcludedList(Source source) =>
      !state.excludedSources.contains(source);

  bool canAddSourceToTrustedList(Source source) =>
      !state.trustedSources.contains(source);

  bool isPendingRemoval({required Source source, required Scope scope}) {
    switch (scope) {
      case Scope.excludedSources:
        return sourcesPendingOperations
            .containsRemoveFromExcludedSources(source);
      case Scope.trustedSources:
        return sourcesPendingOperations
            .containsRemoveFromTrustedSources(source);
    }
  }

  bool isPendingAddition({required Source source, required Scope scope}) {
    switch (scope) {
      case Scope.excludedSources:
        return sourcesPendingOperations.containsAddToExcludedSources(source);
      case Scope.trustedSources:
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
  void removePendingSourceOperation(Source source) {
    // assert that the source is actually a pending operation
    assert([
      sourcesPendingOperations.containsAddToExcludedSources(source),
      sourcesPendingOperations.containsAddToTrustedSources(source),
      sourcesPendingOperations.containsRemoveFromExcludedSources(source),
      sourcesPendingOperations.containsRemoveFromTrustedSources(source),
    ].any((it) => it));

    print('TEST: ${[
      sourcesPendingOperations.containsAddToExcludedSources(source),
      sourcesPendingOperations.containsAddToTrustedSources(source),
      sourcesPendingOperations.containsRemoveFromExcludedSources(source),
      sourcesPendingOperations.containsRemoveFromTrustedSources(source),
    ].any((it) => it)}');

    sourcesPendingOperations.removeOperationsBySource(source);
  }

  /// This method will persist any pending [SourcesManagementOperation] with
  /// the engine.
  /// When completed, the pending operations are flushed, and the [state] will
  /// emit with updated engine list values.
  /// Use [intervalBetweenOperations] to wait between 2 operations, which, if used,
  /// gives the UI some time to visually indicate each addition/removal.
  /// The default value is 1 second.
  Future<void> applyChanges(
      {Duration intervalBetweenOperations = _kRemovalInterval}) async {
    final operationsWithInterval = sourcesPendingOperations.asStream();

    await for (final operation in operationsWithInterval) {
      sourcesPendingOperations.removeOperation(operation);

      switch (operation.task) {
        case SourcesManagementTask.removeFromExcludedSources:
          super.removeSourceFromExcludedList(operation.source);
          break;
        case SourcesManagementTask.addToExcludedSources:
          super.addSourceToExcludedList(operation.source);
          break;
        case SourcesManagementTask.removeFromTrustedSources:
          super.removeSourceFromTrustedList(operation.source);
          break;
        case SourcesManagementTask.addToTrustedSources:
          super.addSourceToTrustedList(operation.source);
          break;
      }
    }
  }

  @override
  Future<SourcesState?> computeState() async =>
      fold(nextStateValueStream).foldAll(
        (nextState, errorReport) async => nextState?.copyWith(
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
        ),
      );

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
          } else if (event is AddExcludedSourceSucceeded) {
            return addExcludeSourceSucceeded(event);
          } else if (event is RemoveExcludedSourceSucceeded) {
            return removeExcludeSourceSucceeded(event);
          } else if (event is AddTrustedSourceSucceeded) {
            return addTrustSourceSucceeded(event);
          } else if (event is RemoveTrustedSourceSucceeded) {
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
              excludedSources: {...state.excludedSources}
                ..remove(event.source)),
          addTrustSourceSucceeded: (event) => state.copyWith(
            trustedSources: {
              ...state.trustedSources,
              event.source,
            },
          ),
          removeTrustedSourceSucceeded: (event) => state.copyWith(
              trustedSources: {...state.trustedSources}..remove(event.source)),
          orElse: () => state,
        );
  }
}

/// Dummy classes - delete when the engine exposes these itself
@Deprecated('remove after engine update')
class RemoveExcludedSourceSucceeded extends TempEngineEvent {
  final Source source;

  RemoveExcludedSourceSucceeded(this.source);
}

@Deprecated('remove after engine update')
class RemoveTrustedSourceSucceeded extends TempEngineEvent {
  final Source source;

  RemoveTrustedSourceSucceeded(this.source);
}

@Deprecated('remove after engine update')
class AddExcludedSourceSucceeded extends TempEngineEvent {
  final Source source;

  AddExcludedSourceSucceeded(this.source);
}

@Deprecated('remove after engine update')
class AddTrustedSourceSucceeded extends TempEngineEvent {
  final Source source;

  AddTrustedSourceSucceeded(this.source);
}
