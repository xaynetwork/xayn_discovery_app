import 'package:xayn_discovery_app/presentation/utils/environment_helper.dart';

enum Feature {
  featuresScreen(Owner.Michael,
      EnvironmentHelper.kIsDebug || EnvironmentHelper.kIsInternalFlavor),
  payment(Owner.Peter, false),
  discoveryEngineReportOverlay(Owner.Simon, false),
  ratingDialog(Owner.Simon, false),
  tts(Owner.Frank, false, 'Enables text-to-speech function for articles'),

  /// Keep flag for remote config
  promptSurvey(Owner.Carmine, false,
      'When enabled, collects the user interactions in order to prompt the survey card'),

  /// Keep flag for remote config
  altPromoCode(Owner.Simon, false, 'PromoCodes are handled inApp'),

  localNotifications(
    Owner.Peter,
    EnvironmentHelper.kIsDebug,
    'Allows to deep link to an article when tapping on local push notification',
  ),

  remoteNotifications(
    Owner.Peter,
    EnvironmentHelper.kIsDebug,
    'Listen for silent push notification from Airship to trigger news fetch',
  );

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
