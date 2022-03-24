import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_background_color.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_style.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

extension ReaderModeBackgroundColorExtension on ReaderModeBackgroundColor {
  Enum get type => R.isDarkMode ? dark : light;

  Color get color => R.isDarkMode ? dark.color : light.color;

  Color get textColor => R.isDarkMode
      ? R.colors.readerModeTextWhiteColor
      : R.colors.readerModeTextDarkColor;
}

extension ReaderModeBackgroundLightColorExtension
    on ReaderModeBackgroundLightColor {
  Color get color {
    switch (this) {
      case ReaderModeBackgroundLightColor.white:
        return R.colors.readerModeWhiteBackgroundColor;
      case ReaderModeBackgroundLightColor.beige:
        return R.colors.readerModeBeigeBackgroundColor;
    }
  }
}

extension ReaderModeBackgroundDarkColorExtension
    on ReaderModeBackgroundDarkColor {
  Color get color {
    switch (this) {
      case ReaderModeBackgroundDarkColor.trueBlack:
        return R.colors.readerModeBlackBackgroundColor;
      case ReaderModeBackgroundDarkColor.dark:
        return R.colors.readerModeDarkBackgroundColor;
    }
  }
}

extension ReaderModeFontStyleExtension on ReaderModeFontStyle {
  String get svgPath {
    switch (this) {
      case ReaderModeFontStyle.sans:
        return R.assets.icons.textSans;
      case ReaderModeFontStyle.serif:
        return R.assets.icons.textSerif;
    }
  }

  TextStyle get textStyle {
    switch (this) {
      case ReaderModeFontStyle.sans:
        return R.styles.notoSansFontText;
      case ReaderModeFontStyle.serif:
        return R.styles.notoSerifFontText;
    }
  }
}
