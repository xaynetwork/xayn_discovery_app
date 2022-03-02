import 'dart:io';

import 'package:flutter/material.dart';

class WidgetTestableProgressIndicator extends StatelessWidget {
  const WidgetTestableProgressIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isInTest = Platform.environment.containsKey('FLUTTER_TEST');
    return CircularProgressIndicator(
      // this prevents the animation from running in repeat,
      // which would break widget tests (pumpAndSettle)
      value: isInTest ? 1.0 : null,
    );
  }
}
