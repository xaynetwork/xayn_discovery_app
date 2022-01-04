import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_bloc_helper.dart';
import 'package:xayn_discovery_app/domain/model/feature.dart';
import 'package:xayn_discovery_app/presentation/utils/environment_helper.dart';

import 'feature_manager_state.dart';

const FeatureMap kInitialFeatureMap = {
  Feature.onBoarding: false,
  Feature.featuresScreen: EnvironmentHelper.kIsInternal,
};

@lazySingleton
class FeatureManager extends Cubit<FeatureManagerState>
    with UseCaseBlocHelper<FeatureManagerState> {
  FeatureManager() : super(FeatureManagerState.initial(kInitialFeatureMap)) {
    _init();
  }

  late FeatureMap _featureMap;

  /// [FeatureManager] is [lazySingleton],
  /// so we should NOT `close` it
  @visibleForOverriding
  @override
  Future<void> close() {
    return super.close();
  }

  void _init() {
    _featureMap = state.featureMap;
  }

  bool get showFeaturesScreen =>
      Feature.values.isNotEmpty && isEnabled(Feature.featuresScreen);

  bool get showOnboardingScreen => isEnabled(Feature.onBoarding);

  @override
  Future<FeatureManagerState?> computeState() async => FeatureManagerState(
        featureMap: Map.from(_featureMap),
      );

  bool isEnabled(Feature feature) => _featureMap[feature] ?? false;

  bool isDisabled(Feature feature) => !isEnabled(feature);

  void overrideFeature(Feature feature, bool isEnabled) =>
      scheduleComputeState(() {
        final FeatureMap modifiedFeatureMap = Map.from(_featureMap);
        modifiedFeatureMap[feature] = isEnabled;
        _featureMap = modifiedFeatureMap;
      });

  void flipFlopFeature(Feature feature) => overrideFeature(
        feature,
        isDisabled(feature),
      );
}
