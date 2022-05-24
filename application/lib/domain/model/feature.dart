import 'package:xayn_discovery_app/presentation/utils/environment_helper.dart';

enum Feature {
  featuresScreen(Owner.Michael,
      EnvironmentHelper.kIsDebug || EnvironmentHelper.kIsInternalFlavor),
  payment(
      Owner.Peter, EnvironmentHelper.kAppId == EnvironmentHelper.kReleaseAppId),
  readerModeSettings(Owner.Michael, true),
  discoveryEngineReportOverlay(Owner.Simon, false),
  ratingDialog(Owner.Simon,
      EnvironmentHelper.kIsDebug || EnvironmentHelper.kIsInternalFlavor),
  tts(Owner.Frank, false, 'Enables text-to-speech function for articles'),
  promptSurvey(Owner.Carmine, false,
      'When enabled, collects the user interactions in order to prompt the survey card');

  final Owner owner;
  final String? description;
  final bool defaultValue;

  const Feature(
    this.owner,
    this.defaultValue, [
    this.description,
  ]);
}

typedef FeatureMap = Map<Feature, bool>;

// ignore_for_file: constant_identifier_names
enum Owner {
  Carmine,
  Frank,
  Michael,
  Peter,
  Simon,
}
