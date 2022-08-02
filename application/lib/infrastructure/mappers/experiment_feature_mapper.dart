import 'package:dart_remote_config/model/feature.dart' as experimentation;
import 'package:xayn_discovery_app/domain/model/feature.dart';

const kOnBoardingSheetsFeature = 'onboarding_sheets';

extension ExperimentationFeatureExtension on experimentation.Feature {
  Feature? get toAppFeature {
    if (id == kOnBoardingSheetsFeature) return Feature.onBoardingSheets;
    return null;
  }
}
