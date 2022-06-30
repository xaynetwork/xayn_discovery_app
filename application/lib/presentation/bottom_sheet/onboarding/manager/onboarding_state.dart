import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/domain/model/onboarding/onboarding_type.dart';

part 'onboarding_state.freezed.dart';

/// Represents the state of the [OnboardingManager].
@freezed
class OnboardingState with _$OnboardingState {
  const OnboardingState._();

  const factory OnboardingState({
    required OnboardingType? onboardingType,
  }) = _OnboardingState;
}
