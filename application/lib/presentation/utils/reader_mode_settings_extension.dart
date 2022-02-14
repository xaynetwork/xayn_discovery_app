import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_background_color.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_size.dart';
import 'package:xayn_discovery_app/domain/model/reader_mode/reader_mode_font_style.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

extension ReaderModeBackgroundColorExtension on ReaderModeBackgroundColor {
  Color get color {
    switch (this) {
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
    switch (this) {
      case ReaderModeBackgroundColor.white:
      case ReaderModeBackgroundColor.beige:
        return R.colors.chipBorderColor;
      case ReaderModeBackgroundColor.black:
      default:
        return null;
    }
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
}

extension ReaderModeFontStyleExtension on ReaderModeFontStyle {
  String get svgPath {
    switch (this) {
      case ReaderModeFontStyle.sansSerif:
        return R.assets.icons.textSansSerif;
      case ReaderModeFontStyle.serif:
        return R.assets.icons.textSerif;
    }
  }
}
