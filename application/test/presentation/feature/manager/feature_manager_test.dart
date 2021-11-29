import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
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
    overrideFeatureUseCase = MockOverrideFeatureUseCase();

    when(overrideFeatureUseCase.transform(any)).thenAnswer(
      (x) => const Stream<OverrideFeatureParam>.empty(),
    );

    initialState = FeatureManagerState.initial(kInitialFeatureMap);
    featureManager = FeatureManager(overrideFeatureUseCase);
  });

  setUpUseCaseResponse(FeatureMap map) {
    when(overrideFeatureUseCase.call(any))
        .thenAnswer((_) async => [UseCaseResult.success(map)]);
  }

  blocTest<FeatureManager, FeatureManagerState>(
    'WHEN manager is created THEN state is initial',
    build: () => featureManager,
    verify: (manager) {
      expect(manager.state, equals(initialState));
      verifyNever(overrideFeatureUseCase.call(any));
      verify(overrideFeatureUseCase.transform(any));
      verifyNoMoreInteractions(overrideFeatureUseCase);
    },
  );

  blocTest<FeatureManager, FeatureManagerState>(
    'Setting featureScreen feature to true',
    setUp: () => setUpUseCaseResponse({Feature.featuresScreen: true}),
    build: () => featureManager,
    act: (manager) => manager.overrideFeature(Feature.featuresScreen, true),
    verify: (manager) {
      expect(manager.state.featureMap[Feature.featuresScreen], isTrue);
      expect(manager.isEnabled(Feature.featuresScreen), isTrue);
      verify(overrideFeatureUseCase.transform(any));
      verifyNoMoreInteractions(overrideFeatureUseCase);
    },
  );

  // blocTest<FeatureManager, FeatureManagerState>(
  //   'Setting featureScreen feature to false',
  //   setUp: () => setUpUseCaseResponse({Feature.featuresScreen: false}),
  //   build: () => featureManager,
  //   act: (manager) => manager.overrideFeature(Feature.featuresScreen, false),
  //   verify: (manager) {
  //     expect(manager.state.featureMap[Feature.featuresScreen], isFalse);
  //     expect(manager.isEnabled(Feature.featuresScreen), isFalse);
  //     verify(overrideFeatureUseCase.transform(any));
  //     verifyNoMoreInteractions(overrideFeatureUseCase);
  //   },
  // );
}
