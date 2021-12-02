import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_bloc_helper.dart';
import 'package:xayn_discovery_app/domain/model/feature.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feature/override_feature_use_case.dart';
import 'package:xayn_discovery_app/presentation/utils/environment_helper.dart';

import 'feature_manager_state.dart';

const FeatureMap kInitialFeatureMap = {
  Feature.onBoarding: false,
  Feature.featuresScreen: EnvironmentHelper.kIsInternal,
};

@lazySingleton
class FeatureManager extends Cubit<FeatureManagerState>
    with UseCaseBlocHelper<FeatureManagerState> {
  FeatureManager(
    this._overrideFeatureUseCase,
  ) : super(FeatureManagerState.initial(kInitialFeatureMap)) {
    _init();
  }

  final OverrideFeatureUseCase _overrideFeatureUseCase;
  late FeatureMap featureMap;

  void _init() {
    featureMap = state.featureMap;
  }

  bool get showFeaturesScreen =>
      Feature.values.isNotEmpty && isEnabled(Feature.featuresScreen);

  @override
  Future<FeatureManagerState?> computeState() async =>
      state.copyWith(featureMap: featureMap);

  bool isEnabled(Feature feature) => state.featureMap[feature] ?? false;

  bool isDisabled(Feature feature) => !isEnabled(feature);

  void overrideFeature(Feature feature, bool isEnabled) =>
      scheduleComputeState(() async {
        featureMap = await _overrideFeatureUseCase.singleOutput(
          OverrideFeatureParam(
            feature: feature,
            isEnabled: isEnabled,
            featureMap: state.featureMap,
          ),
        );
      });

  void flipFlopFeature(Feature feature) => overrideFeature(
        feature,
        isDisabled(feature),
      );
}
