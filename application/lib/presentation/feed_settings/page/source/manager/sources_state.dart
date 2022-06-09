import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/sources_management/sources_management_operation.dart';
// ignore: implementation_imports
import 'package:xayn_discovery_engine/src/domain/models/source.dart';

part 'sources_state.freezed.dart';

@freezed
class SourcesState with _$SourcesState {
  const SourcesState._();

  const factory SourcesState({
    @Default(<AvailableSource>{}) Set<AvailableSource> availableSources,
    @Default(<Source>{}) Set<Source> excludedSources,
    @Default(<Source>{}) Set<Source> trustedSources,
    @Default(<SourcesManagementOperation>{})
        Set<SourcesManagementOperation> pendingOperations,
  }) = _SourcesState;
}
