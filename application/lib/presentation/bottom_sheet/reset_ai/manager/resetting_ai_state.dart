import 'package:freezed_annotation/freezed_annotation.dart';

part 'resetting_ai_state.freezed.dart';

@freezed
class ResettingAIState with _$ResettingAIState {
  factory ResettingAIState.loading() = Loading;
  factory ResettingAIState.resetSucceeded() = ResetSucceeded;
  factory ResettingAIState.resetFailed() = ResetFailed;
}
