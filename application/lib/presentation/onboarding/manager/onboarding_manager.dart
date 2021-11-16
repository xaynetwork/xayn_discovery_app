import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:xayn_discovery_app/infrastructure/use_case/onboarding/onboarding_completed_use_case.dart';

import 'onboarding_state.dart';

@injectable
class OnBoardingManager extends Cubit<OnBoardingState> {
  final OnOnBoardingCompletedUseCase _onBoardingCompletedUseCase;
  OnBoardingManager(
    this._onBoardingCompletedUseCase,
  ) : super(const OnBoardingState.started());

  void onPageChanged(int newPageIndex) => emit(
        OnBoardingState.onPageChanged(currentPageIndex: newPageIndex),
      );

  Future<void> onOnBoardingCompleted(int currentPageIndex) async {
    final result = await _onBoardingCompletedUseCase(currentPageIndex);

    if (result.last.hasData) {
      emit(OnBoardingState.completed(
        currentPageIndex: currentPageIndex,
      ));
    } else if (result.last.hasError) {
      emit(OnBoardingState.error(
        currentPageIndex: currentPageIndex,
      ));
    }
  }
}
