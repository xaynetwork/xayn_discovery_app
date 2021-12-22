import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_architecture/concepts/use_case/use_case_bloc_helper.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/onboarding/onboarding_completed_use_case.dart';

import 'onboarding_state.dart';

abstract class OnBoardingNavActions {
  void onClosePressed();
}

@injectable
class OnBoardingManager extends Cubit<OnBoardingState>
    with UseCaseBlocHelper<OnBoardingState>
    implements OnBoardingNavActions {
  final OnBoardingCompletedUseCase _onBoardingCompletedUseCase;
  final OnBoardingNavActions _onboardingNavActions;

  OnBoardingManager(
    this._onBoardingCompletedUseCase,
    this._onboardingNavActions,
  ) : super(const OnBoardingState.started());

  int _currentPageIndex = -1;
  bool _hasError = false;
  bool _isPageChanged = false;

  void onPageChanged(int newPageIndex) => scheduleComputeState(() {
        _currentPageIndex = newPageIndex;
        _isPageChanged = true;
        _hasError = false;
      });

  void onOnBoardingCompleted(int currentPageIndex) async {
    final result = await _onBoardingCompletedUseCase(currentPageIndex);

    scheduleComputeState(() {
      _currentPageIndex = currentPageIndex;
      _isPageChanged = false;

      result.last.fold(
        defaultOnError: (e, s) => _hasError = true,
        onValue: (_) => _hasError = false,
      );
    });
  }

  @override
  Future<OnBoardingState?> computeState() async {
    if (_currentPageIndex == -1) return null;

    if (_hasError) {
      return OnBoardingState.error(
        currentPageIndex: _currentPageIndex,
      );
    }

    if (_isPageChanged) {
      return OnBoardingState.onPageChanged(
        currentPageIndex: _currentPageIndex,
      );
    }

    if (_currentPageIndex == -1) {
      return const OnBoardingState.started();
    }

    return OnBoardingState.completed(
      currentPageIndex: _currentPageIndex,
    );
  }

  @override
  void onClosePressed() => _onboardingNavActions.onClosePressed();
}
