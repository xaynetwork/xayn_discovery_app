import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_bloc_helper.dart';
import 'package:xayn_discovery_app/domain/model/feature.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';

import 'feature_manager_state.dart';

FeatureMap kInitialFeatureMap = {
  for (var v in Feature.values) v: v.defaultValue
};

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

  bool get isPaymentEnabled => isEnabled(Feature.payment);

  bool get isAlternativePromoCodeEnabled => isEnabled(Feature.altPromoCode);

  bool get isTtsEnabled => isEnabled(Feature.tts);

  bool get isPromptSurveyEnabled => isEnabled(Feature.promptSurvey);

  bool get isNewExcludeSourceFlowEnabled =>
      isEnabled(Feature.newExcludeSourceFlow);

  bool get arePushNotificationDeepLinksEnabled =>
      isEnabled(Feature.pushNotificationDeepLinks);

  bool get showDiscoveryEngineReportOverlay =>
      isEnabled(Feature.discoveryEngineReportOverlay);

  bool get areAdsEnabled => isEnabled(Feature.ads);

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

  void resetFirstAppStartupDate() {
    final appStatusRepo = di.get<AppStatusRepository>();
    final newStatus =
        appStatusRepo.appStatus.copyWith(firstAppLaunchDate: DateTime.now());
    appStatusRepo.save(newStatus);
  }

  void setTrialDurationToZero() {
    final appStatusRepo = di.get<AppStatusRepository>();
    final newStatus = appStatusRepo.appStatus.copyWith(
      firstAppLaunchDate: DateTime.now().subtract(const Duration(days: 7)),
      extraTrialEndDate: null,
      usedPromoCodes: {},
    );
    appStatusRepo.save(newStatus);
  }
}
