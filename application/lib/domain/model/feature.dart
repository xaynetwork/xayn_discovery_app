import 'package:xayn_discovery_app/presentation/utils/environment_helper.dart';

enum Feature {
  featuresScreen('Michael',
      EnvironmentHelper.kIsDebug || EnvironmentHelper.kIsInternalFlavor),
  payment('Peter', EnvironmentHelper.kAppId == 'com.xayn.discovery'),
  readerModeSettings('Michael', true),
  discoveryEngineReportOverlay('Simon', false),
  ratingDialog('Simon',
      EnvironmentHelper.kIsDebug || EnvironmentHelper.kIsInternalFlavor),
  tts('Frank', false, 'Enables text-to-speech function for articles');

  final String owner;
  final String? description;
  final bool defaultValue;

  const Feature(
    this.owner,
    this.defaultValue,
    [this.description,]
  );
}

typedef FeatureMap = Map<Feature, bool>;
