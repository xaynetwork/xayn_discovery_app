import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';

/// Wraps the Linden design system as an R object.
@immutable
class R {
  const R._();

  static Linden _linden = Linden(newColors: true);

  static Linden get linden => _linden;

  static XAssets get assets => _linden.assets;

  static XStyles get styles => _linden.styles;

  static XSizes get dimen => _linden.dimen;

  static XColors get colors => _linden.colors;

  static XAnimations get animations => _linden.animations;

  static Brightness get brightness => _linden.brightness;

  static bool get isDarkMode => brightness == Brightness.dark;

  static void updateLinden(Linden linden) {
    _linden = linden;
  }
}
