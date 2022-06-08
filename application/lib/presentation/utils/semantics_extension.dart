import 'package:flutter/widgets.dart';

extension SemanticsExtension on Widget {
  Widget withSemanticsLabel(
    String semanticsLabel, {
    bool excludeChildren = true,
    bool selected = false,
  }) =>
      Semantics(
        label: semanticsLabel,
        enabled: true,
        selected: selected,
        child: excludeChildren ? ExcludeSemantics(child: this) : this,
      );
}
