import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_state.freezed.dart';

abstract class IOnBoardingState {
  int get currentPageIndex;
}

@freezed
class OnBoardingState with _$OnBoardingState {
  @Implements<IOnBoardingState>()
  const factory OnBoardingState.started({
    @Default(0) int currentPageIndex,
  }) = _OnBoardingStateInitial;

  @Implements<IOnBoardingState>()
  const factory OnBoardingState.onPageChanged({
    required int currentPageIndex,
  }) = _OnBoardingStateOnPageChanged;

  @Implements<IOnBoardingState>()
  const factory OnBoardingState.completed({
    required int currentPageIndex,
  }) = _OnBoardingStateCompleted;

  @Implements<IOnBoardingState>()
  const factory OnBoardingState.error({
    required int currentPageIndex,
  }) = _OnBoardingStateError;
}
