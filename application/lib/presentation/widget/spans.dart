import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';

extension TextSpanExtension on String {
  TextSpan link({VoidCallback? onTap}) => span(
      style: R.styles.sStyle.copyWith(color: R.colors.accent), onTap: onTap);
  TextSpan bold({VoidCallback? onTap}) =>
      span(style: R.styles.sBoldStyle, onTap: onTap);

  TextSpan span({TextStyle? style, VoidCallback? onTap}) {
    TapGestureRecognizer? gesture;
    if (onTap != null) {
      gesture = TapGestureRecognizer();
      gesture.onTap = onTap;
    }
    return TextSpan(
      text: this,
      style: style ?? R.styles.sStyle,
      recognizer: gesture,
    );
  }
}

extension TextCollectionSpanExtension on List<InlineSpan> {
  TextSpan span({TextStyle? style}) {
    return TextSpan(
      children: this,
      style: style ?? R.styles.sStyle,
    );
  }
}
