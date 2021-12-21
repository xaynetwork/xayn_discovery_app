import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_design/src/utils/design_testing_utils.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/onboarding/manager/onboarding_manager.dart';
import 'package:xayn_discovery_app/presentation/onboarding/manager/onboarding_state.dart';
import 'package:xayn_discovery_app/presentation/onboarding/widget/onboarding_screen.dart';

import 'onboarding_screen_widget_test.mocks.dart';

void packageInfoMock() {
  const MethodChannel('dev.fluttercommunity.plus/package_info')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'getAll') {
      return <String, dynamic>{
        // 'appName': 'ABC',
        // 'packageName': 'A.B.C', // <--- set initial values here
        // 'version': '1.0.0', // <--- set initial values here
        // 'buildNumber': '' // <--- set initial values here
      };
    }
    return null;
  });
}

@GenerateMocks([OnBoardingManager])
void main() {
  late MockOnBoardingManager manager;

  Finder getPageOne() => find.byKey(Keys.onBoardingPageOne);
  Finder getPageTwo() => find.byKey(Keys.onBoardingPageTwo);
  Finder getPageThree() => find.byKey(Keys.onBoardingPageThree);
  Finder getTapDetector() => find.byKey(Keys.onBoardingPageTapDetector);

  setUpAll(() {
    packageInfoMock();
    manager = MockOnBoardingManager();
    configureDependencies();
    di
      ..unregister<OnBoardingManager>()
      ..registerSingleton<OnBoardingManager>(manager);

    when(manager.stream).thenAnswer((_) => const Stream.empty());
    when(manager.state).thenAnswer((_) => const OnBoardingState.started());
  });
  testWidgets(
    'WHEN opening onboarding screen THEN show first page',
    (
      WidgetTester tester,
    ) async {
      await tester.pumpLindenApp(const OnBoardingScreen());

      expect(getPageOne(), findsOneWidget);
      expect(getPageTwo(), findsNothing);
      expect(getPageThree(), findsNothing);

      verifyNever(manager.onPageChanged(any));
    },
  );

  testWidgets('WHEN tapping on first page THEN show the second one', (
    WidgetTester tester,
  ) async {
    await tester.pumpLindenApp(const OnBoardingScreen());

    await tester.tap(getTapDetector());
    await tester.pumpAndSettle(kPageSwitchAnimationDuration);

    expect(getPageOne(), findsNothing);
    expect(getPageTwo(), findsOneWidget);
    expect(getPageThree(), findsNothing);
    verify(manager.onPageChanged(1));
  });

  testWidgets('WHEN tapping on second page THEN show the third one', (
    WidgetTester tester,
  ) async {
    await tester.pumpLindenApp(const OnBoardingScreen());
    final tapDetector = getTapDetector();

    for (int i = 0; i < 2; i++) {
      await tester.tap(tapDetector);
      await tester.pumpAndSettle(kPageSwitchAnimationDuration);
    }

    expect(getPageOne(), findsNothing);
    expect(getPageTwo(), findsNothing);
    expect(getPageThree(), findsOneWidget);

    verifyInOrder([
      manager.onPageChanged(1),
      manager.onPageChanged(2),
      manager.onOnBoardingCompleted(2),
    ]);
  });
}
