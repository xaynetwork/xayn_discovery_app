import 'package:freezed_annotation/freezed_annotation.dart';

part 'tts_data.freezed.dart';

@freezed
class TtsData with _$TtsData {
  const factory TtsData({
    required bool enabled,
    required String languageCode,
    String? html,
    Uri? uri,
  }) = _TtsData;

  factory TtsData.disabled() => const TtsData(enabled: false, languageCode: '');
}
