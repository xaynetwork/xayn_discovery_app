import 'package:flutter/foundation.dart';

class EnvironmentHelper {
  static const kIsDebug = !kReleaseMode;

  static const String _flavor = bool.hasEnvironment('USER_FLAVOR')
      ? String.fromEnvironment('USER_FLAVOR')
      : "internal";

  /// Be aware this is the app id that is passed to the build during publish
  /// thus the USER_APP_ID value is not set during development and we are falling
  /// back to a fixed appId.
  /// get_version will tell you the appId that is declared in the AndroidManifest / Info.plist
  /// To test a different appId behaviour you can build flutter with dart defines:
  ///
  /// ```bash
  ///   flutter ... --dart-define=USER_APP_ID=com.example
  /// ```
  static const String kAppId = bool.hasEnvironment('USER_APP_ID')
      ? String.fromEnvironment('USER_APP_ID')
      : "com.xayn.discovery.internal";

  /// The app name set during publish.
  ///
  /// @see [kAppId]
  static const String kAppName = bool.hasEnvironment('USER_APP_NAME')
      ? String.fromEnvironment('USER_APP_NAME')
      : "Discovery App Internal";

  /// The git tag set during publish
  /// defaults to HEAD
  ///
  /// @see [kAppId]
  static const String kGitTag = bool.hasEnvironment('GIT_TAG')
      ? String.fromEnvironment('GIT_TAG')
      : "HEAD";

  static const bool kIsInternalFlavor = _flavor == "internal";

  static const bool kIsBetaFlavor = _flavor == "beta";

  static const bool kIsProductionFlavor = _flavor == "production";
}
