import 'package:flutter/material.dart';
import 'package:xayn_discovery_app/presentation/utils/environment_helper.dart';

class WidgetTestableProgressIndicator extends StatelessWidget {
  const WidgetTestableProgressIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      // this prevents the animation from running in repeat,
      // which would break widget tests (pumpAndSettle)
      value: EnvironmentHelper.kIsInTest ? 1.0 : null,
    );
  }
}
