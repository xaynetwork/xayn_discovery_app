import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/domain/model/feature.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager_state.dart';

void main() {
  late FeatureManager featureManager;
  late FeatureManagerState initialState;

  setUp(() {
    initialState = FeatureManagerState.initial(kInitialFeatureMap);
    featureManager = FeatureManager();
  });

  blocTest<FeatureManager, FeatureManagerState>(
    'WHEN manager is created THEN state is initial',
    build: () => featureManager,
    verify: (manager) {
      expect(manager.state, equals(initialState));
    },
  );

  blocTest<FeatureManager, FeatureManagerState>(
    'WHEN overrideFeature method called to set featureScreen feature to true THEN expect  featureScreen feature to be equal to true',
    build: () => featureManager,
    act: (manager) => manager.overrideFeature(Feature.featuresScreen, true),
    verify: (manager) {
      expect(manager.state.featureMap[Feature.featuresScreen], isTrue);
      expect(manager.isEnabled(Feature.featuresScreen), isTrue);
    },
  );

  blocTest<FeatureManager, FeatureManagerState>(
    'WHEN overrideFeature method called to set featureScreen feature to false THEN expect  featureScreen feature to be equal to false',
    build: () => featureManager,
    act: (manager) => manager.overrideFeature(Feature.featuresScreen, false),
    verify: (manager) {
      expect(manager.state.featureMap[Feature.featuresScreen], isFalse);
      expect(manager.isEnabled(Feature.featuresScreen), isFalse);
    },
  );
}
