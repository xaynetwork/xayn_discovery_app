import 'package:xayn_discovery_app/presentation/utils/environment_helper.dart';

enum Feature {
  featuresScreen(
    Owner.Michael,
    EnvironmentHelper.kIsDebug || EnvironmentHelper.kIsInternalFlavor,
  ),
  payment(
    Owner.Peter,
    EnvironmentHelper.kAppId == EnvironmentHelper.kReleaseAppId,
  ),
  discoveryEngineReportOverlay(
    Owner.Simon,
    false,
  ),
  ratingDialog(
    Owner.Simon,
    EnvironmentHelper.kIsDebug || EnvironmentHelper.kIsInternalFlavor,
  ),
  tts(
    Owner.Frank,
    false,
    description: 'Enables text-to-speech function for articles',
  ),

  /// Keep flag for remote config
  promptSurvey(
    Owner.Carmine,
    true,
    description:
        'When enabled, collects the user interactions in order to prompt the survey card',
  ),

  /// Keep flag for remote config
  altPromoCode(Owner.Simon, true, description: 'PromoCodes are handled inApp'),
  onBoardingSheets(
    Owner.Michael,
    false,
    description: 'Showing onboarding bottom sheets',
    remoteKey: 'onboarding_sheets',
  ),
  localNotifications(
    Owner.Peter,
    EnvironmentHelper.kIsDebug,
    description:
        'Allows to deep link to an article when tapping on local push notification',
  ),
  remoteNotifications(
    Owner.Peter,
    EnvironmentHelper.kIsDebug,
    description:
        'Listen for silent push notification from Airship to trigger news fetch',
  );

  final Owner owner;
  final String? description;
  final bool defaultValue;

  /// Providing a remoteKey will allow to control this feature by a remote config
  final String? remoteKey;

  const Feature(
    this.owner,
    this.defaultValue, {
    this.description,
    this.remoteKey,
  });
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
