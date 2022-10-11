import 'package:dart_remote_config/dart_remote_config.dart';
import 'package:dart_remote_config/model/dart_remote_config_state.dart';
import 'package:dart_remote_config/model/known_experiment_variant.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/domain/model/extensions/app_status_extension.dart';
import 'package:xayn_discovery_app/domain/model/feature.dart';
import 'package:xayn_discovery_app/domain/repository/app_status_repository.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/analytics/set_experiments_identity_params_use_case.dart';
import 'package:xayn_discovery_app/presentation/utils/logger/logger.dart';

import 'feature_manager_state.dart';

FeatureMap kInitialFeatureMap = {
  for (var v in Feature.values) v: v.defaultValue
};

@lazySingleton
class FeatureManager extends Cubit<FeatureManagerState>
    with UseCaseBlocHelper<FeatureManagerState> {
  FeatureManager(
    this._remoteConfigState,
    this._setExperimentsIdentityParamsUseCase,
  ) : super(FeatureManagerState.initial(_alterFeatureMapAccordingToExperiments(
            kInitialFeatureMap, _remoteConfigState))) {
    _init();
    _remoteConfigState.whenOrNull(success: (_, result) {
      _setExperimentsIdentityParamsUseCase(result);
      _subscribedVariantIds = result.subscribedVariantIds;
    }, failed: (_, __) {
      _subscribedVariantIds = {};
    });
  }

  final DartRemoteConfigState _remoteConfigState;

  late final Set<KnownVariantId> _subscribedVariantIds;

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

  bool get isCountrySelectionInLineCardEnabled =>
      isEnabled(Feature.countrySelectionInLineCard);

  bool get isSourceSelectionInLineCardEnabled =>
      isEnabled(Feature.sourceSelectionInLineCard);

  bool get isTopicsEnabled => isEnabled(Feature.topics);

  bool get isDemoModeEnabled => isEnabled(Feature.demoMode);

  @override
  Future<FeatureManagerState?> computeState() async => FeatureManagerState(
        featureMap: Map.from(_featureMap),
        subscribedVariantIds: _subscribedVariantIds,
      );

  static FeatureMap _alterFeatureMapAccordingToExperiments(
    FeatureMap initialMap,
    DartRemoteConfigState state,
  ) {
    if (state is! DartRemoteConfigStateSuccess) {
      return initialMap;
    }

    final featureMap = Map<Feature, bool>.from(initialMap);
    for (var it in state.experiments.enabledFeatures) {
      final feature = Feature.values
          .firstWhereOrNull((element) => element.remoteKey == it.id);
      if (feature != null) {
        it.value.map(nothing: (_) {
          /// We assume that being part of an experiment and no value is provided that this means it is active
          logger.i(
              'RemoteConfig: Flipped $feature from ${featureMap[feature]} -> true');
          featureMap[feature] = true;
        }, string: (s) {
          /// Not used yet
        }, boolean: (b) {
          logger.i(
              'RemoteConfig: Flipped $feature from ${featureMap[feature]} -> ${b.boolValue}');
          featureMap[feature] = b.boolValue;
        });
      }
    }
    return featureMap;
  }

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
