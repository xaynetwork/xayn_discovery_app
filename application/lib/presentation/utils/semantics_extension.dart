import 'package:flutter/widgets.dart';

extension SemanticsExtension on Widget {
  Widget withSemanticsLabel(
    String semanticsLabel, {
    bool excludeChildren = true,
  }) =>
      Semantics(
        label: semanticsLabel,
        enabled: true,
        child: excludeChildren ? ExcludeSemantics(child: this) : this,
      );
}
