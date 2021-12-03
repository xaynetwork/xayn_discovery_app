import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';

/// Wraps the Linden design system as an R object.
@immutable
class R {
  const R._();

  static Linden _linden = Linden();

  static const XDurations _durations = XDurations._();

  static Linden get linden => _linden;

  static XAssets get assets => _linden.assets;

  static XStyles get styles => _linden.styles;

  static XSizes get dimen => _linden.dimen;

  static XColors get colors => _linden.colors;

  static XAnimations get animations => _linden.animations;

  static XDurations get durations => _durations;

  static bool get isDarkMode => _linden.brightness == Brightness.dark;

  static Brightness get invertedBrightness =>
      R.isDarkMode ? Brightness.light : Brightness.dark;

  static Brightness get brightness =>
      R.isDarkMode ? Brightness.dark : Brightness.light;

  static void updateLinden(Linden linden) {
    _linden = linden;
  }
}

class XDurations {
  const XDurations._();

  final Duration _unit = const Duration(milliseconds: 200);

  Duration get screenStateChangeDuration => _unit;
}
