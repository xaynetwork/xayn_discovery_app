import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_design/xayn_design_test.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_manager.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_state.dart';
import 'package:xayn_discovery_app/presentation/personal_area/personal_area_screen.dart';
import 'package:xayn_discovery_app/presentation/utils/widget/card_widget/card_widget.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar/app_toolbar.dart';

import '../../test_utils/utils.dart';
import '../../test_utils/widget_test_utils.dart';

void main() {
  late StreamController<PersonalAreaState> streamController;
  late MockPersonalAreaManager manager;
  late final tooltipController = ApplicationTooltipController();

  setUp(() async {
    await setupWidgetTest();
    manager = MockPersonalAreaManager();
    di.registerSingleton<PersonalAreaManager>(manager);
    when(manager.state).thenReturn(PersonalAreaState.initial());
    streamController = StreamController<PersonalAreaState>();
    when(manager.stream).thenAnswer((_) => streamController.stream);
  });

  tearDown(() async {
    await tearDownWidgetTest();
    streamController.close();
  });

  Future<void> openScreen(WidgetTester tester) async {
    await tester.pumpLindenApp(
      Provider<ApplicationTooltipController>.value(
        value: tooltipController,
        child: const ApplicationTooltipProvider(
          messageFactory: {},
          child: PersonalAreaScreen(),
        ),
      ),
      initialLinden: Linden(),
    );
    await tester.pumpAndSettle(R.animations.screenStateChangeDuration);
  }

  testWidgets(
    'WHEN create PersonalAreaScreen THEN view is correct',
    (final WidgetTester tester) async {
      await openScreen(tester);

      expect(find.byType(AppToolbar), findsOneWidget);
      expect(find.text(R.strings.personalAreaTitle), findsOneWidget);
      expect(find.byType(CardWidget), findsNWidgets(1));
      expect(find.byKey(Keys.personalAreaCardCollections), findsOneWidget);
    },
    skip: true,
  );

  testWidgets(
    'WHEN create PersonalAreaScreen THEN navBarConfigs is correct',
    (final WidgetTester tester) async {
      await tester.initToDiscoveryPage();
      await tester.navigateToPersonalArea();

      final state =
          (find.byType(PersonalAreaScreen).evaluate().first as StatefulElement)
              .state as PersonalAreaScreenState;
      final configs = state.navBarConfig;

      expect(configs.items.length, equals(3));

      final home = configs.items[0];
      expect(home.isHighlighted, isFalse);
      expect(home.key, Keys.navBarItemHome);

      final search = configs.items[1];
      expect(search.isHighlighted, isFalse);
      expect(search.key, Keys.navBarItemSearch);

      final area = configs.items[2];
      expect(area.isHighlighted, isTrue);
      expect(area.key, Keys.navBarItemPersonalArea);
    },
    skip: true,
  );

  group('on navBarItems click tests', () {
    testWidgets(
      'WHEN clicked on homeItem THEN call redirected to manager',
      (final WidgetTester tester) async {
        await tester.initToDiscoveryPage();
        await tester.navigateToPersonalArea();

        await tester.tap(Keys.navBarItemHome.finds());
        verify(manager.onHomeNavPressed());
      },
      skip: true,
    );
    testWidgets(
      'WHEN clicked on activeSearch THEN call is redirected to manager',
      (final WidgetTester tester) async {
        await tester.initToDiscoveryPage();
        await tester.navigateToPersonalArea();

        await tester.tap(Keys.navBarItemSearch.finds());
        verify(manager.onActiveSearchNavPressed());
      },
      skip: true,
    );
    testWidgets(
      'WHEN clicked on personalAreaItem THEN nothing happen',
      (final WidgetTester tester) async {
        await tester.initToDiscoveryPage();
        await tester.navigateToPersonalArea();

        await tester.tap(Keys.navBarItemPersonalArea.finds());

        verify(manager.state);
        verify(manager.stream);
        verifyNoMoreInteractions(manager);
      },
      skip: true,
    );
  });

  group('on card click tests', () {
    testWidgets(
      'WHEN clicked on collections THEN call redirected to manager',
      (final WidgetTester tester) async {
        await openScreen(tester);

        await tester.tap(Keys.personalAreaCardCollections.finds());
        verify(manager.onCollectionsNavPressed());
      },
      skip: true,
    );
  });
}
