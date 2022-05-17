import 'package:xayn_discovery_app/presentation/utils/environment_helper.dart';

enum Feature {
  featuresScreen('Michael',
      EnvironmentHelper.kIsDebug || EnvironmentHelper.kIsInternalFlavor),
  payment('Peter', EnvironmentHelper.kAppId == 'com.xayn.discovery'),
  readerModeSettings('Michael', true),
  discoveryEngineReportOverlay('Simon', false),
  ratingDialog('Simon',
      EnvironmentHelper.kIsDebug || EnvironmentHelper.kIsInternalFlavor),
  tts('Frank', false);

  final String author;
  final bool defaultValue;

  const Feature(
    this.author,
    this.defaultValue,
  );
}

typedef FeatureMap = Map<Feature, bool>;
