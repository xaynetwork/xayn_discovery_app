import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_discovery_app/domain/model/feature.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/feature/override_feature_use_case.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager_state.dart';
import 'feature_manager_test.mocks.dart';

@GenerateMocks([OverrideFeatureUseCase])
void main() {
  late MockOverrideFeatureUseCase overrideFeatureUseCase;
  late FeatureManager featureManager;
  late FeatureManagerState initialState;

  setUp(() {
    initialState = FeatureManagerState.initial(kInitialFeatureMap);
    overrideFeatureUseCase = MockOverrideFeatureUseCase();
    featureManager = FeatureManager(overrideFeatureUseCase);
  });

  blocTest<FeatureManager, FeatureManagerState>(
    'WHEN manager is created THEN state is initial',
    build: () => featureManager,
    verify: (manager) {
      expect(manager.state, equals(initialState));
      verifyNoMoreInteractions(overrideFeatureUseCase);
    },
  );

  blocTest<FeatureManager, FeatureManagerState>(
    'WHEN overrideFeature method called to set featureScreen feature to true THEN expect  featureScreen feature to be equal to true',
    setUp: () {
      when(overrideFeatureUseCase.singleOutput(any)).thenAnswer(
        (_) async => {Feature.featuresScreen: true},
      );
    },
    build: () => featureManager,
    act: (manager) => manager.overrideFeature(Feature.featuresScreen, true),
    verify: (manager) {
      verify(overrideFeatureUseCase.singleOutput(any));
      verifyNoMoreInteractions(overrideFeatureUseCase);
      expect(manager.state.featureMap[Feature.featuresScreen], isTrue);
      expect(manager.isEnabled(Feature.featuresScreen), isTrue);
    },
  );

  blocTest<FeatureManager, FeatureManagerState>(
    'WHEN overrideFeature method called to set featureScreen feature to false THEN expect  featureScreen feature to be equal to false',
    setUp: () {
      when(overrideFeatureUseCase.singleOutput(any)).thenAnswer(
        (_) async => {Feature.featuresScreen: false},
      );
    },
    build: () => featureManager,
    act: (manager) => manager.overrideFeature(Feature.featuresScreen, false),
    verify: (manager) {
      verify(overrideFeatureUseCase.singleOutput(any));
      verifyNoMoreInteractions(overrideFeatureUseCase);
      expect(manager.state.featureMap[Feature.featuresScreen], isFalse);
      expect(manager.isEnabled(Feature.featuresScreen), isFalse);
    },
  );
}
