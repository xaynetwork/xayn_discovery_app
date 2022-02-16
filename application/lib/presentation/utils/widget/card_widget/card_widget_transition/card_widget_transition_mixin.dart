import 'package:flutter/material.dart';

mixin CardWidgetTransitionMixin<T extends StatefulWidget> on State<T> {
  void closeCardWidgetTransition() {
    Navigator.pop(context);
  }
}
