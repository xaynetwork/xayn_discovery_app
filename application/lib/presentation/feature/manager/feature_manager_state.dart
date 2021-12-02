import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/feature.dart';

part 'feature_manager_state.freezed.dart';

@freezed
class FeatureManagerState with _$FeatureManagerState {
  const FeatureManagerState._();

  const factory FeatureManagerState({
    @Default(<Feature, bool>{}) FeatureMap featureMap,
  }) = _FeatureManagerState;

  factory FeatureManagerState.initial(FeatureMap initialMap) =>
      FeatureManagerState(featureMap: initialMap);
}
