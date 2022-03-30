import 'package:freezed_annotation/freezed_annotation.dart';

part 'tts_state.freezed.dart';

@freezed
class TtsState with _$TtsState {
  const factory TtsState({
    required Duration duration,
  }) = _TtsState;

  factory TtsState.initial() => const TtsState(duration: Duration.zero);
}
