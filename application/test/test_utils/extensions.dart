import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

extension StreamExtensions<T> on Stream<T> {
  Future<T> waitFor(bool Function(T) condition) async {
    final current = StackTrace.current;
    return await firstWhere(condition)
        .then((value) => Future.delayed(Duration.zero, () => value))
        .timeout(
      const Duration(milliseconds: 1000),
      onTimeout: () {
        throw 'waitFor timed out, thus the desired state was not reached within 1000 msec.\n$current';
      },
    );
  }
}

extension WidgetTestKeyExtension on Key {
  Finder finds() => find.byKey(this);
}
