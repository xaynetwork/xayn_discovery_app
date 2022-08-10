import 'dart:io';

// This allows to use this file from outside like bin/
// ignore: implementation_imports
import 'package:flutter/src/foundation/constants.dart';

class EnvironmentHelper {
  EnvironmentHelper._();

  static const kIsDebug = !kReleaseMode;

  static const String kFlavor =
      String.fromEnvironment('USER_FLAVOR', defaultValue: "internal");

  /// The release app ID. When running in the release mode, [kAppId] will be the same as [kReleaseAppId].
  ///
  /// @see [kAppId]
  static const kReleaseAppId = 'com.xayn.discovery';

  /// Be aware this is the app id that is passed to the build during publish
  /// thus the USER_APP_ID value is not set during development and we are falling
  /// back to a fixed appId.
  /// get_version will tell you the appId that is declared in the AndroidManifest / Info.plist
  /// To test a different appId behaviour you can build flutter with dart defines:
  ///
  /// ```bash
  ///   flutter ... --dart-define=USER_APP_ID=com.example
  /// ```
  static const String kAppId = String.fromEnvironment('USER_APP_ID',
      defaultValue: "com.xayn.discovery.internal");

  /// The app name set during publish.
  ///
  /// @see [kAppId]
  static const String kAppName =
      String.fromEnvironment('USER_APP_NAME', defaultValue: "Discovery");

  /// The git tag set during publish
  /// defaults to HEAD
  ///
  /// @see [kAppId]
  static const String kGitTag =
      String.fromEnvironment('GIT_TAG', defaultValue: 'HEAD');

  static bool get kIsInTest => Platform.environment.containsKey('FLUTTER_TEST');

  static const bool kIsInternalFlavor = kFlavor == "internal";

  static const bool kIsBetaFlavor = kFlavor == "beta";

  static const bool kIsProductionFlavor = kFlavor == "production";
}
