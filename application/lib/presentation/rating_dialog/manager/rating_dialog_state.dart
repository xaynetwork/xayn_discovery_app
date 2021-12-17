import 'package:freezed_annotation/freezed_annotation.dart';

part 'rating_dialog_state.freezed.dart';

@freezed
class RatingDialogState with _$RatingDialogState {
  const RatingDialogState._();

  const factory RatingDialogState({
    @Default(false) bool showDialog,
  }) = _RatingDialogState;

  factory RatingDialogState.initial() => const RatingDialogState();
}
