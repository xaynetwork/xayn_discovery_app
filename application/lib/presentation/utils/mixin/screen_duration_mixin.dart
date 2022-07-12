import 'package:flutter/widgets.dart';

mixin ScreenDurationMixin<T extends StatefulWidget> on State<T> {
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    _stopwatch.start();
    super.initState();
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }

  Duration get getWidgetDuration => _stopwatch.elapsed;
}
