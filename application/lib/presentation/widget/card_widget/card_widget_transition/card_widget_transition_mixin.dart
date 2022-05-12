import 'package:flutter/material.dart';

mixin CardWidgetTransitionMixin<T extends StatefulWidget> on State<T> {
  //TODO: to be refactored so it's called from managers instead of widgets
  void closeCardWidgetTransition() {
    Navigator.pop(context);
  }
}
