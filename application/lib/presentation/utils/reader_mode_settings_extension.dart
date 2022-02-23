import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_background_color.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_size.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_style.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

extension ReaderModeBackgroundColorExtension on ReaderModeBackgroundColor {
  Color get color {
    switch (mapIfDefault) {
      case ReaderModeBackgroundColor.white:
        return R.colors.readerModeWhiteBackgroundColor;
      case ReaderModeBackgroundColor.beige:
        return R.colors.readerModeBeigeBackgroundColor;
      case ReaderModeBackgroundColor.black:
      default:
        return R.colors.readerModeBlackBackgroundColor;
    }
  }

  Color? get borderColor {
    switch (mapIfDefault) {
      case ReaderModeBackgroundColor.white:
      case ReaderModeBackgroundColor.beige:
        return R.colors.chipBorderColor;
      case ReaderModeBackgroundColor.black:
      default:
        return null;
    }
  }

  Color get textColor {
    switch (mapIfDefault) {
      case ReaderModeBackgroundColor.white:
      case ReaderModeBackgroundColor.beige:
        return R.colors.readerModeTextDarkColor;
      case ReaderModeBackgroundColor.black:
      default:
        return R.colors.readerModeTextWhiteColor;
    }
  }

  bool get isDefault => this == ReaderModeBackgroundColor.system;

  ReaderModeBackgroundColor get mapIfDefault {
    if (isDefault) {
      return R.isDarkMode
          ? ReaderModeBackgroundColor.black
          : ReaderModeBackgroundColor.white;
    }
    return this;
  }
}

extension ReaderModeFontSizeExtension on ReaderModeFontSize {
  String get svgPath {
    switch (this) {
      case ReaderModeFontSize.small:
        return R.assets.icons.textSmallFont;
      case ReaderModeFontSize.medium:
        return R.assets.icons.textMediumFont;
      case ReaderModeFontSize.large:
        return R.assets.icons.textLargeFont;
    }
  }

  TextStyle get textStyle {
    switch (this) {
      case ReaderModeFontSize.small:
        return R.styles.sHighDensityStyle;
      case ReaderModeFontSize.medium:
        return R.styles.mHighDensityStyle;
      case ReaderModeFontSize.large:
        return R.styles.lHighDensityStyle;
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
