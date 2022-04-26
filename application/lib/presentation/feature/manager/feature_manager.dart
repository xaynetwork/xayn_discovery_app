import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_bloc_helper.dart';
import 'package:xayn_discovery_app/domain/model/feature.dart';
import 'package:xayn_discovery_app/presentation/utils/environment_helper.dart';

import 'feature_manager_state.dart';

FeatureMap kInitialFeatureMap = {
  for (var v in Feature.values) v: v.defaultValue
};

extension on Feature {
  bool get defaultValue {
    switch (this) {
      case Feature.onBoarding:
        return false;
      case Feature.readerModeSettings:
        return true;
      case Feature.featuresScreen:
        return EnvironmentHelper.kIsDebug ||
            EnvironmentHelper.kIsInternalFlavor;
      case Feature.discoveryEngineReportOverlay:
        return false;
      case Feature.payment:
        return EnvironmentHelper.kAppId == 'com.xayn.discovery';
      case Feature.ratingDialog:
        return EnvironmentHelper.kIsDebug ||
            EnvironmentHelper.kIsInternalFlavor;
      case Feature.tts:
        return false;
    }
  }
}

@lazySingleton
class FeatureManager extends Cubit<FeatureManagerState>
    with UseCaseBlocHelper<FeatureManagerState> {
  FeatureManager() : super(FeatureManagerState.initial(kInitialFeatureMap)) {
    _init();
  }

  late FeatureMap _featureMap;

  void _init() {
    _featureMap = state.featureMap;
  }

  bool get showFeaturesScreen =>
      Feature.values.isNotEmpty && isEnabled(Feature.featuresScreen);

  bool get showOnboardingScreen => isEnabled(Feature.onBoarding);

  bool get isReaderModeSettingsEnabled => isEnabled(Feature.readerModeSettings);

  bool get isPaymentEnabled => isEnabled(Feature.payment);

  bool get isRatingDialogEnabled => isEnabled(Feature.ratingDialog);

  bool get isTtsEnabled => isEnabled(Feature.tts);

  bool get showDiscoveryEngineReportOverlay =>
      isEnabled(Feature.discoveryEngineReportOverlay);

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
