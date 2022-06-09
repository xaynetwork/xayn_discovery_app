import 'package:freezed_annotation/freezed_annotation.dart';
// ignore: implementation_imports
import 'package:xayn_discovery_engine/src/domain/models/source.dart';

part 'sources_state.freezed.dart';

enum SourceState {
  normal,
  pendingRemoval,
  pendingAddition,
}

@freezed
class SourcesState with _$SourcesState {
  const SourcesState._();

  const factory SourcesState({
    @Default(<AvailableSource>{}) Set<AvailableSource> availableSources,
    @Default(<SourceEntry>{}) Set<SourceEntry> excludedSources,
    @Default(<SourceEntry>{}) Set<SourceEntry> trustedSources,
  }) = _SourcesState;
}

@immutable
class SourceEntry {
  final Source source;
  final SourceState state;

  const SourceEntry.normal(this.source) : state = SourceState.normal;
  const SourceEntry.pendingRemoval(this.source)
      : state = SourceState.pendingRemoval;
  const SourceEntry.pendingAddition(this.source)
      : state = SourceState.pendingAddition;

  @override
  bool operator ==(Object other) =>
      other is SourceEntry && source == other.source && state == other.state;

  @override
  int get hashCode => Object.hashAll([source, state]);
}
