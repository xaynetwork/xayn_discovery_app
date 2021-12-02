import 'package:flutter/foundation.dart';

class EnvironmentHelper {
  static const kIsDebug = !kReleaseMode;

  /// The app releases are all internal for now. so [kIsInternal] is set to true
  /// TODO: Implement [kIsInternal] when releasing to production
  /// to be aware of the applicationIdSuffix in Android and iOS build configs
  ///
  /// ex.: bool get kIsInternal =>
  ///           String.fromEnvironment('XAYN_APP_SUFFIX').contains('internal');
  ///
  static const kIsInternal = true;
}
