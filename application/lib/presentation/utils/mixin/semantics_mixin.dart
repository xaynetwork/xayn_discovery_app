import 'package:flutter/cupertino.dart';

mixin SemanticMixin {
  buildWidget(
      Widget widget,
      String? key,
      ) {
    if (key == null) throw "Used SemanticMixin without providing a Key!";

    return Semantics(label: key.toString(), child: widget);
  }
}