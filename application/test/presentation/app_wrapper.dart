import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_design/xayn_design.dart';

extension WidgetTesterExtension on WidgetTester {
  Future<void> pumpAppWrapped(
    Widget widget, {
    Duration? duration,
    EnginePhase phase = EnginePhase.sendSemanticsUpdate,
    Linden? initialLinden,
  }) =>
      pumpWidget(appWrapped(child: widget, initialLinden: initialLinden));
}

Widget appWrapped({
  required Widget child,
  Linden? initialLinden,
}) {
  final linden = initialLinden ?? Linden();
  return UnterDenLinden(
    child: MaterialApp(
      theme: linden.themeData,
      home: child,
    ),
    initialLinden: linden,
  );
}
