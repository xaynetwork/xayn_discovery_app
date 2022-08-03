import 'package:dart_remote_config/model/experimentation_engine_result.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/extensions/app_status_extension.dart';
import 'package:xayn_discovery_app/domain/model/feature.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/mappers/experiment_feature_mapper.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/set_experiments_identity_params_use_case.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/remote_config/fetch_experiments_use_case.dart';

import 'feature_manager_state.dart';

FeatureMap kInitialFeatureMap = {
  for (var v in Feature.values) v: v.defaultValue
};

@lazySingleton
class FeatureManager extends Cubit<FeatureManagerState>
    with UseCaseBlocHelper<FeatureManagerState> {
  FeatureManager(
    this._experiments,
    this._setExperimentsIdentityParamsUseCase,
  ) : super(FeatureManagerState.initial(kInitialFeatureMap)) {
    _init()
    alterFeatureMapAccordingToExperiments(experimentationResult);
    _setExperimentsIdentityParamsUseCase(_experiments);
  }

  final ExperimentationEngineResult _experiments;
  final SetExperimentsIdentityParamsUseCase
      _setExperimentsIdentityParamsUseCase;

  late FeatureMap _featureMap;

  void _init() {
    _featureMap = state.featureMap;
  }

  bool get showFeaturesScreen =>
      Feature.values.isNotEmpty && isEnabled(Feature.featuresScreen);

  bool get isPaymentEnabled => isEnabled(Feature.payment);

  bool get isAlternativePromoCodeEnabled => isEnabled(Feature.altPromoCode);

  bool get isTtsEnabled => isEnabled(Feature.tts);

  bool get isPromptSurveyEnabled => isEnabled(Feature.promptSurvey);

  bool get areLocalNotificationsEnabled =>
      isEnabled(Feature.localNotifications);

  bool get areRemoteNotificationsEnabled =>
      isEnabled(Feature.remoteNotifications);

  bool get showDiscoveryEngineReportOverlay =>
      isEnabled(Feature.discoveryEngineReportOverlay);

  bool get isOnBoardingSheetsEnabled => isEnabled(Feature.onBoardingSheets);

  @override
  Future<FeatureManagerState?> computeState() async {
    return FeatureManagerState(
      featureMap: Map.from(_featureMap),
    );
  }

  void _alterFeatureMapAccordingToExperiments(
    FetchedExperimentsOut experiments,
  ) =>
      experiments.subscribedFeatures
          .map((it) => it.toAppFeature)
          .where((feature) => feature != null)
          .forEach(
            (feature) => _overrideFeature(feature!, true),
          );

  bool isEnabled(Feature feature) => _featureMap[feature] ?? false;

  bool isDisabled(Feature feature) => !isEnabled(feature);

  void _overrideFeature(Feature feature, bool isEnabled) {
    final FeatureMap modifiedFeatureMap = Map.from(_featureMap);
    modifiedFeatureMap[feature] = isEnabled;
    _featureMap = modifiedFeatureMap;
  }

  void overrideFeature(Feature feature, bool isEnabled) => scheduleComputeState(
        () => _overrideFeature(feature, isEnabled),
      );

  void flipFlopFeature(Feature feature) =>
      overrideFeature(feature, isDisabled(feature));

  void resetFirstAppStartupDate() {
    final appStatusRepo = di.get<AppStatusRepository>();
    final newStatus =
        appStatusRepo.appStatus.copyWith(firstAppLaunchDate: DateTime.now());
    appStatusRepo.save(newStatus);
  }

  void setTrialDurationToZero() {
    final appStatusRepo = di.get<AppStatusRepository>();
    final newStatus = appStatusRepo.appStatus.copyWith(
      firstAppLaunchDate: DateTime.now().subtract(freeTrialDuration),
      extraTrialEndDate: null,
      usedPromoCodes: {},
    );
    appStatusRepo.save(newStatus);
  }
}
