import 'package:flutter/widgets.dart';

extension SemanticsExtension on Widget {
  Widget withSemanticsLabel(
    String semanticsLabel, {
    bool excludeChildren = false,
  }) =>
      Semantics(
        label: semanticsLabel,
        enabled: true,
        button: true,
        child: excludeChildren ? ExcludeSemantics(child: this) : this,
      );
}
