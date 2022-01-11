import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_design/src/utils/design_testing_utils.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/onboarding/manager/onboarding_manager.dart';
import 'package:xayn_discovery_app/presentation/onboarding/manager/onboarding_state.dart';
import 'package:xayn_discovery_app/presentation/onboarding/model/onboarding_page_data.dart';
import 'package:xayn_discovery_app/presentation/onboarding/widget/onboarding_screen.dart';

import '../../test_utils/widget_test_utils.dart';
import 'onboarding_screen_widget_test.mocks.dart';

@GenerateMocks([OnBoardingManager])
void main() {
  late MockOnBoardingManager manager;

  Finder getPageOne() => find.byKey(Keys.onBoardingPageOne);
  Finder getPageTwo() => find.byKey(Keys.onBoardingPageTwo);
  Finder getPageThree() => find.byKey(Keys.onBoardingPageThree);
  Finder getTapDetector() => find.byKey(Keys.onBoardingPageTapDetector);
  Finder navBarFinder() => find.byType(NavBar);

  setUp(() async {
    await setupWidgetTest();
    manager = MockOnBoardingManager();
    di.registerLazySingleton<OnBoardingManager>(() => manager);

    when(manager.stream).thenAnswer((_) => const Stream.empty());
    when(manager.state).thenAnswer((_) => const OnBoardingState.started());
  });

  tearDown(() async {
    await tearDownWidgetTest();
  });

  OnBoardingScreenState getState() =>
      (find.byType(OnBoardingScreen).evaluate().first as StatefulElement).state
          as OnBoardingScreenState;
  testWidgets(
    'WHEN opening onboarding screen THEN show first page',
    (
      WidgetTester tester,
    ) async {
      await tester.pumpLindenApp(const OnBoardingScreen());

      expect(getPageOne(), findsOneWidget);
      expect(getPageTwo(), findsNothing);
      expect(getPageThree(), findsNothing);
      expect(navBarFinder(), findsNothing);

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
    expect(getPageThree(), findsNothing);
    expect(navBarFinder(), findsNothing);
    verify(manager.onPageChanged(1));
  });

  testWidgets('WHEN tapping on second page THEN show the third one', (
    WidgetTester tester,
  ) async {
    await tester.pumpLindenApp(
      const OnBoardingScreen(),
      withNavBarContainer: true,
    );
    final tapDetector = getTapDetector();

    for (int i = 0; i < 2; i++) {
      await tester.tap(tapDetector);
      await tester.pumpAndSettle(kPageSwitchAnimationDuration);
    }

    expect(getPageOne(), findsNothing);
    expect(getPageTwo(), findsNothing);
    expect(getPageThree(), findsOneWidget);
    expect(navBarFinder(), findsOneWidget);

    verifyInOrder([
      manager.onPageChanged(1),
      manager.onPageChanged(2),
      manager.onOnBoardingCompleted(2),
    ]);
  });

  testWidgets(
    'GIVEN OnBoardingScreen WHEN  THEN initial pageData is correct',
    (final WidgetTester tester) async {
      final expectedData = [
        const OnBoardingGenericPageData(
          imageAssetUrl: '',
          text: 'Swipe up for next article',
          index: 0,
        ),
        const OnBoardingGenericPageData(
          imageAssetUrl: '',
          text: 'Swipe right for liking',
          index: 1,
        ),
        const OnBoardingGenericPageData(
          imageAssetUrl: '',
          text: 'Swipe left for disliking',
          index: 2,
        ),
      ];
      await tester.pumpLindenApp(const OnBoardingScreen());

      final state = getState();
      final pageData = state.getInitialPageData();

      expect(expectedData, equals(pageData));
    },
  );
}
