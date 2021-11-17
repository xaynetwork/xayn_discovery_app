import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';

/// Wraps the Linden design system as an R object.
@immutable
class R {
  const R._();

  static final Linden _linden = Linden();

  static XAssets get assets => _linden.assets;

  static XStyles get styles => _linden.styles;

  static XSizes get dimen => _linden.dimen;

  static XColors get colors => _linden.colors;
}
