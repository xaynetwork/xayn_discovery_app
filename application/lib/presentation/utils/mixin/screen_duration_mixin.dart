import 'package:flutter/widgets.dart';

mixin ScreenDurationMixin<T extends StatefulWidget> on State<T> {
  late final DateTime _startDateTime;

  @override
  void initState() {
    _startDateTime = DateTime.now();
    super.initState();
  }

  Duration get getDurationFromWidgetInit =>
      DateTime.now().difference(_startDateTime);
}
