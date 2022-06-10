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
    @Default(<Source>{}) Set<Source> excludedSources,
    @Default(<Source>{}) Set<Source> trustedSources,
    @Default(<Source>{}) Set<Source> jointExcludedSources,
    @Default(<Source>{}) Set<Source> jointTrustedSources,
  }) = _SourcesState;
}
