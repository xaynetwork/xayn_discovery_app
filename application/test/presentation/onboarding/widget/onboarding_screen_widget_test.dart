import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/onboarding/widget/onboarding_screen.dart';
import 'package:xayn_discovery_app/presentation/utils/keys.dart';

import '../../app_wrapper.dart';

void main() {
  setUpAll(() {
    configureDependencies();
  });
  testWidgets(
    'WHEN opening onboarding screen THEN show first page',
    (
      WidgetTester tester,
    ) async {
      await tester.pumpAppWrapped(const OnBoardingScreen());

      final onBoardingPageOne = find.byKey(const Key(Keys.onBoardingPageOne));

      expect(onBoardingPageOne, findsOneWidget);
    },
  );

  testWidgets('WHEN tapping on first page THEN show the second one', (
    WidgetTester tester,
  ) async {
    await tester.pumpAppWrapped(const OnBoardingScreen());

    final onBoardingPageTapDetector =
        find.byKey(const Key(Keys.onBoardingPageTapDetector));

    await tester.tap(onBoardingPageTapDetector);
    await tester.pumpAndSettle(kPageSwitchAnimationDuration);

    final onBoardingPageTwo = find.byKey(const Key(Keys.onBoardingPageTwo));

    expect(onBoardingPageTwo, findsOneWidget);
  });

  testWidgets('WHEN tapping on second page THEN show the third one', (
    WidgetTester tester,
  ) async {
    final onBoardingPageTapDetector =
        find.byKey(const Key(Keys.onBoardingPageTapDetector));

    await tester.pumpAppWrapped(const OnBoardingScreen());

    await tester.tap(onBoardingPageTapDetector);
    await tester.pumpAndSettle(kPageSwitchAnimationDuration);
    await tester.tap(onBoardingPageTapDetector);
    await tester.pumpAndSettle(kPageSwitchAnimationDuration);

    final onBoardingPageThree = find.byKey(const Key(Keys.onBoardingPageThree));

    expect(onBoardingPageThree, findsOneWidget);
  });
}
