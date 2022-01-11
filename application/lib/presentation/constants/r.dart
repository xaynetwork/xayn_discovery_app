import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/constants/strings.dart';
import 'package:xayn_discovery_app/presentation/constants/translations/translations.i18n.dart';

/// Wraps the Linden design system as an R object.
@immutable
class R {
  const R._();

  static Linden _linden = Linden(newColors: true);

  static Linden get linden => _linden;

  static Translations get strings => Strings.translation;

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
