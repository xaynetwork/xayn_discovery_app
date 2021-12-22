import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/onboarding/onboarding_completed_use_case.dart';
import 'package:xayn_discovery_app/presentation/onboarding/manager/onboarding_manager.dart';
import 'package:xayn_discovery_app/presentation/onboarding/manager/onboarding_state.dart';

import 'onboarding_manager_test.mocks.dart';

@GenerateMocks([OnBoardingCompletedUseCase, OnBoardingNavActions])
void main() {
  late OnBoardingManager onBoardingManager;
  late OnBoardingState initialState;
  late OnBoardingState onPageChangedState;
  late OnBoardingState completedState;
  late OnBoardingState errorState;
  late MockOnBoardingCompletedUseCase onBoardingCompletedUseCase;

  setUp(() {
    initialState = const OnBoardingState.started();
    onPageChangedState =
        const OnBoardingState.onPageChanged(currentPageIndex: 2);
    completedState = const OnBoardingState.completed(currentPageIndex: 3);
    errorState = const OnBoardingState.error(currentPageIndex: 3);
    onBoardingCompletedUseCase = MockOnBoardingCompletedUseCase();
    onBoardingManager = OnBoardingManager(
        onBoardingCompletedUseCase, MockOnBoardingNavActions());
  });

  blocTest<OnBoardingManager, OnBoardingState>(
    'WHEN manager is created THEN state is OnBoardingStateInitial with page index set to 0',
    build: () => onBoardingManager,
    verify: (manager) {
      expect(manager.state, equals(initialState));
      expect(manager.state.currentPageIndex, initialState.currentPageIndex);
      verifyZeroInteractions(onBoardingCompletedUseCase);
    },
  );

  blocTest<OnBoardingManager, OnBoardingState>(
    'WHEN page changes THEN state is OnBoardingStatePageChanged with page index set to the index passed',
    build: () => onBoardingManager,
    act: (manager) => manager.onPageChanged(2),
    expect: () => [
      onPageChangedState,
    ],
    verify: (manager) {
      expect(
          manager.state.currentPageIndex, onPageChangedState.currentPageIndex);
      verifyZeroInteractions(onBoardingCompletedUseCase);
    },
  );

  blocTest<OnBoardingManager, OnBoardingState>(
    'WHEN onBoarding is completed THEN call the OnBoardingCompletedUseCase use case',
    build: () => onBoardingManager,
    setUp: () {
      when(onBoardingCompletedUseCase.call(any))
          .thenAnswer((_) async => [const UseCaseResult.success(true)]);
    },
    act: (manager) => manager.onOnBoardingCompleted(3),
    expect: () => [
      completedState,
    ],
    verify: (manager) {
      expect(manager.state.currentPageIndex, completedState.currentPageIndex);
      verifyInOrder([
        onBoardingCompletedUseCase.call(3),
      ]);
      verifyNoMoreInteractions(onBoardingCompletedUseCase);
    },
  );

  blocTest<OnBoardingManager, OnBoardingState>(
    'WHEN page changes THEN state is OnBoardingStatePageError with page index set to the index passed',
    build: () => onBoardingManager,
    setUp: () {
      when(onBoardingCompletedUseCase.call(any)).thenAnswer((_) async => [
            UseCaseResult.failure(
              Error(),
              StackTrace.empty,
            ),
          ]);
    },
    act: (manager) => manager.onOnBoardingCompleted(3),
    expect: () => [
      errorState,
    ],
    verify: (manager) {
      expect(manager.state.currentPageIndex, errorState.currentPageIndex);
      verifyInOrder([
        onBoardingCompletedUseCase.call(3),
      ]);
      verifyNoMoreInteractions(onBoardingCompletedUseCase);
    },
  );
}
