import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/sources_management/sources_management_operation.dart';
import 'package:xayn_discovery_app/domain/model/sources_management/sources_management_task.dart';
import 'package:xayn_discovery_app/infrastructure/discovery_engine/use_case/engine_events_use_case.dart';
import 'package:xayn_discovery_app/presentation/discovery_engine/mixin/sources_management_mixin.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/page/source/manager/sources_state.dart';
import 'package:xayn_discovery_engine_flutter/discovery_engine.dart';

const Duration _kRemovalInterval = Duration(seconds: 1);

typedef FoldEngineEvent = SourcesState Function(EngineEvent?) Function(
    SourcesState);
typedef OnGetAvailableSourcesListSucceeded = SourcesState Function(
    AvailableSourcesListRequestSucceeded event);
typedef OnExcludedSourcesListRequestSucceeded = SourcesState Function(
    ExcludedSourcesListRequestSucceeded event);
typedef OnTrustedSourcesListRequestSucceeded = SourcesState Function(
    TrustedSourcesListRequestSucceeded event);
typedef OnExcludeSourceSucceeded = SourcesState Function(
    ExcludeSourceSucceeded event);
typedef OnTrustSourceSucceeded = SourcesState Function(
    TrustSourceSucceeded event);
typedef OnNonMatchedEngineEvent = SourcesState Function();

@injectable
class SourcesManager extends Cubit<SourcesState>
    with UseCaseBlocHelper<SourcesState>, SourcesManagementMixin<SourcesState> {
  final EngineEventsUseCase engineEventsUseCase;
  final List<SourcesManagementOperation> _operations =
      <SourcesManagementOperation>[];
  late final FoldEngineEvent foldEngineEvent = _foldEngineEvent();
  late final UseCaseValueStream<SourcesState> nextStateValueStream = consume(
    engineEventsUseCase,
    initialData: none,
  ).transform(
    (out) => out.map((it) => foldEngineEvent(state)(it)),
  );

  SourcesManager(
    this.engineEventsUseCase,
  ) : super(const SourcesState());

  /// Trigger this manager to load both [Source] lists.
  /// This method is typically invoked by a `Widget` when running `Widget.initState`.
  void init() {
    getExcludedSourcesList();
    getTrustedSourcesList();
  }

  @override
  Future<void> close() {
    _operations.clear();

    return super.close();
  }

  @override
  void removeSourceFromExcludedList(Source source) =>
      scheduleComputeState(() => _addOperation(
          SourcesManagementOperation.removeFromExcludedSources(source)));

  @override
  void addSourceToExcludedList(Source source) => scheduleComputeState(() =>
      _addOperation(SourcesManagementOperation.addToExcludedSources(source)));

  @override
  void removeSourceFromTrustedList(Source source) =>
      scheduleComputeState(() => _addOperation(
          SourcesManagementOperation.removeFromTrustedSources(source)));

  @override
  void addSourceToTrustedList(Source source) => scheduleComputeState(() =>
      _addOperation(SourcesManagementOperation.addToTrustedSources(source)));

  /// This method will persist any pending [SourcesManagementOperation] with
  /// the engine.
  /// When completed, the pending operations are flushed, and the [state] will
  /// emit with updated engine list values.
  /// Use [intervalBetweenOperations] to wait between 2 operations, which, if used,
  /// gives the UI some time to visually indicate each addition/removal.
  /// The default value is 1 second.
  Future<void> applyChanges(
      {Duration intervalBetweenOperations = _kRemovalInterval}) async {
    final operationsWithInterval = Stream.fromIterable(_operations)
        .distinctUnique()
        .interval(intervalBetweenOperations);

    await for (final operation in operationsWithInterval) {
      _operations.remove(operation);

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
          excludedSources: {
            ...nextState.excludedSources,
            ..._operationsAsEntries({
              SourcesManagementTask.addToExcludedSources,
              SourcesManagementTask.removeFromExcludedSources,
            })
          },
          trustedSources: {
            ...nextState.trustedSources,
            ..._operationsAsEntries({
              SourcesManagementTask.addToTrustedSources,
              SourcesManagementTask.removeFromTrustedSources,
            })
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
      required OnExcludeSourceSucceeded excludeSourceSucceeded,
      required OnTrustSourceSucceeded trustSourceSucceeded,
      required OnNonMatchedEngineEvent orElse,
    }) =>
        (EngineEvent? event) {
          if (event is AvailableSourcesListRequestSucceeded) {
            return getAvailableSourcesListSucceeded(event);
          } else if (event is ExcludedSourcesListRequestSucceeded) {
            return excludedSourcesListRequestSucceeded(event);
          } else if (event is TrustedSourcesListRequestSucceeded) {
            return trustedSourcesListRequestSucceeded(event);
          } else if (event is ExcludeSourceSucceeded) {
            return excludeSourceSucceeded(event);
          } else if (event is TrustSourceSucceeded) {
            return trustSourceSucceeded(event);
          }

          return orElse();
        };

    return (SourcesState state) => foldEngineEvent(
          getAvailableSourcesListSucceeded: (event) =>
              state.copyWith(availableSources: event.availableSources.toSet()),
          excludedSourcesListRequestSucceeded: (event) => state.copyWith(
              excludedSources:
                  event.excludedSources.map(SourceEntry.normal).toSet()),
          trustedSourcesListRequestSucceeded: (event) => state.copyWith(
              trustedSources:
                  event.trustedSources.map(SourceEntry.normal).toSet()),
          excludeSourceSucceeded: (event) => state.copyWith(
            excludedSources: {
              ...state.excludedSources,
              SourceEntry.normal(event.source),
            },
          ),
          trustSourceSucceeded: (event) => state.copyWith(
            trustedSources: {
              ...state.trustedSources,
              SourceEntry.normal(event.source),
            },
          ),
          orElse: () => state,
        );
  }

  Iterable<SourceEntry> _operationsAsEntries(
          Set<SourcesManagementTask> forTasks) =>
      _operations
          .where((it) => forTasks.contains(it.task))
          .map((it) => it.asSourceEntry);

  /// Adds a new [SourcesManagementOperation], and ensures previous operations
  /// on the same [operation.source] are first removed.
  void _addOperation(SourcesManagementOperation operation) => _operations
    ..removeWhere((it) => it.source == operation.source)
    ..add(operation);
}

extension _SourcesManagementOperationExtension on SourcesManagementOperation {
  SourceEntry get asSourceEntry {
    switch (task) {
      case SourcesManagementTask.removeFromExcludedSources:
      case SourcesManagementTask.removeFromTrustedSources:
        return SourceEntry.pendingRemoval(source);
      case SourcesManagementTask.addToExcludedSources:
      case SourcesManagementTask.addToTrustedSources:
        return SourceEntry.pendingAddition(source);
    }
  }
}

/// Dummy classes - delete when the engine exposes these itself
abstract class TrustedSourcesListRequestSucceeded implements EngineEvent {
  final Set<Source> trustedSources;

  const TrustedSourcesListRequestSucceeded(this.trustedSources);
}

abstract class ExcludeSourceSucceeded implements EngineEvent {
  final Source source;

  const ExcludeSourceSucceeded(this.source);
}

abstract class TrustSourceSucceeded implements EngineEvent {
  final Source source;

  const TrustSourceSucceeded(this.source);
}
