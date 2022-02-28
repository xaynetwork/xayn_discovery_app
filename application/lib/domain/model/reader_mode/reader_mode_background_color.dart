import 'package:freezed_annotation/freezed_annotation.dart';

part 'reader_mode_background_color.freezed.dart';

@freezed
class ReaderModeBackgroundColor with _$ReaderModeBackgroundColor {
  factory ReaderModeBackgroundColor({
    required ReaderModeBackgroundDarkColor dark,
    required ReaderModeBackgroundLightColor light,
  }) = _ReaderModeBackgroundColor;

  factory ReaderModeBackgroundColor.initial() => ReaderModeBackgroundColor(
        dark: ReaderModeBackgroundDarkColor.dark,
        light: ReaderModeBackgroundLightColor.white,
      );
}

enum ReaderModeBackgroundDarkColor {
  dark,
  trueBlack,
}

enum ReaderModeBackgroundLightColor {
  white,
  beige,
}
