import 'package:flutter/material.dart' hide NavigatorState;
import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_architecture/concepts/navigation/navigator_state.dart';
import 'package:xayn_discovery_app/presentation/navigation/observer/nav_bar_observer.dart';
import 'package:xayn_discovery_app/presentation/navigation/pages.dart';

import '../../test_utils/utils.dart';

void main() {
  late MockBuildContext context;
  final stateEmpty = NavigatorState(pages: const [], source: Source.unknown);
  final stateNotEmpty = NavigatorState(
    pages: [PageRegistry.settings],
    source: Source.unknown,
  );
  late List<bool> goingBackResults;
  setUp(() {
    context = MockBuildContext();
    goingBackResults = [];
  });

  void resetNavBarCallback(
    BuildContext context, {
    required bool goingBack,
  }) {
    goingBackResults.add(goingBack);
  }

  testWidgets(
    'GIVEN nullable old state WHEN didChangeState THEN resetNavBar is called with isGoingBack == false',
    (final WidgetTester tester) async {
      final observer = NavBarObserver.test(resetNavBarCallback);

      observer.didChangeState(context, null, stateNotEmpty);

      expect(goingBackResults.length, equals(1));
      expect(goingBackResults.first, isFalse);
    },
  );

  testWidgets(
    'GIVEN old state with same amount of pages as new one WHEN didChangeState THEN resetNavBar is called with isGoingBack == false',
    (final WidgetTester tester) async {
      final observer = NavBarObserver.test(resetNavBarCallback);

      observer.didChangeState(context, stateNotEmpty, stateNotEmpty);

      expect(goingBackResults.length, equals(1));
      expect(goingBackResults.first, isFalse);
    },
  );

  testWidgets(
    'GIVEN old state with smaller amount of pages as new one WHEN didChangeState THEN resetNavBar is called with isGoingBack == false',
    (final WidgetTester tester) async {
      final observer = NavBarObserver.test(resetNavBarCallback);

      observer.didChangeState(context, stateEmpty, stateNotEmpty);

      expect(goingBackResults.length, equals(1));
      expect(goingBackResults.first, isFalse);
    },
  );

  testWidgets(
    'GIVEN old state with bigger amount of pages as new one WHEN didChangeState THEN resetNavBar is called with isGoingBack == false',
    (final WidgetTester tester) async {
      final observer = NavBarObserver.test(resetNavBarCallback);

      observer.didChangeState(context, stateNotEmpty, stateEmpty);

      expect(goingBackResults.length, equals(2));
      expect(goingBackResults.first, isFalse);
      expect(goingBackResults[1], isTrue);
    },
  );
}
