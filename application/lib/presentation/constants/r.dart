import 'package:flutter/material.dart';
import 'package:xayn_design/xayn_design.dart';

@immutable
class R {
  const R._();

  static final Linden _linden = Linden();

  static XStyles get styles => _linden.styles;

  static XSizes get dimen => _linden.dimen;

  static XColors get colors => _linden.colors;
}
