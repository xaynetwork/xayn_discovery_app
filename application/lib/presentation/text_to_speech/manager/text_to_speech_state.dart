import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/manager/discovery_feed_manager.dart';

part 'text_to_speech_state.freezed.dart';

/// The state of the [DiscoveryFeedManager].
@freezed
class TextToSpeechState with _$TextToSpeechState {
  const TextToSpeechState._();

  const factory TextToSpeechState({
    required Duration totalSpokenDuration,
    required Duration lastSpokenDuration,
  }) = _TextToSpeechState;

  factory TextToSpeechState.silent() => const TextToSpeechState(
        totalSpokenDuration: Duration(),
        lastSpokenDuration: Duration(),
      );

  factory TextToSpeechState.speaking({
    required Duration totalSpokenDuration,
    required Duration lastSpokenDuration,
  }) =>
      TextToSpeechState(
        totalSpokenDuration: totalSpokenDuration,
        lastSpokenDuration: lastSpokenDuration,
      );
}
