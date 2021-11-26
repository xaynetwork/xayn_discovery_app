import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/utils/environment_helper.dart';

import 'feature.dart';

@lazySingleton
class FeatureManager {
  static bool get shouldShowFeaturesScreen =>
      Feature.featuresScreen.isEnabled && Feature.values.isNotEmpty;

  final _overrideMap = <Feature, bool?>{};

  bool _isOverride(Feature feature) => _overrideMap[feature] != null;

  bool _isEnabled(Feature feature) {
    var override = _overrideMap[feature];
    if (override != null) {
      return override;
    }

    switch (feature) {
      case Feature.onBoarding:
        return false;
      case Feature.featuresScreen:
        return EnvironmentHelper.kIsInternal;
    }
  }
}

extension FeatureHelperExtension on Feature {
  bool get isDisabled => !isEnabled;

  bool get isEnabled => di.get<FeatureManager>()._isEnabled(this);

  void override(bool? isEnabled) =>
      di.get<FeatureManager>()._overrideMap[this] = isEnabled;

  bool get isOverride => di.get<FeatureManager>()._isOverride(this);

  void circle() => isOverride ? override(null) : override(!isEnabled);
}
