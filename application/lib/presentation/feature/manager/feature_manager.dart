import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/handlers/fold.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_bloc_helper.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_stream.dart';
import 'package:xayn_discovery_app/domain/model/feature.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
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
  late final UseCaseSink<OverrideFeatureParam, FeatureMap>
      _overrideFeatureHandler;

  void _init() {
    _overrideFeatureHandler = pipe(_overrideFeatureUseCase);
  }

  static bool get shouldShowFeaturesScreen =>
      Feature.featuresScreen.isEnabled && Feature.values.isNotEmpty;

  @override
  Future<FeatureManagerState?> computeState() async =>
      fold(_overrideFeatureHandler).foldAll((featureMap, errorReport) {
        if (errorReport.isEmpty && featureMap != null) {
          return state.copyWith(featureMap: featureMap);
        }
        return state;
      });

  bool isEnabled(Feature feature) => state.featureMap[feature] ?? false;

  void overrideFeature(Feature feature, bool isEnabled) =>
      _overrideFeatureHandler(OverrideFeatureParam(
        feature: feature,
        isEnabled: isEnabled,
        featureMap: state.featureMap,
      ));
}

extension FeatureHelperExtension on Feature {
  bool get isEnabled => di.get<FeatureManager>().isEnabled(this);
  bool get isDisabled => !isEnabled;
  void overrideFeature(bool isEnabled) =>
      di.get<FeatureManager>().overrideFeature(this, isEnabled);

  void invert() => overrideFeature(!isEnabled);
}
