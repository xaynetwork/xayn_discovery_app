import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';

/// Wraps the Linden design system as an R object.
@immutable
class R {
  const R._();

  static Linden _linden = Linden();

  static Linden get linden => _linden;

  static XAssets get assets => _linden.assets;

  static XStyles get styles => _linden.styles;

  static XSizes get dimen => _linden.dimen;

  static XColors get colors => _linden.colors;

  static XAnimations get animations => _linden.animations;

  static bool get isDarkMode => _linden.brightness == Brightness.dark;

  static Brightness get invertedBrightness =>
      R.isDarkMode ? Brightness.light : Brightness.dark;

  static void updateLinden(Linden linden) {
    _linden = linden;
  }
}
