import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_architecture/xayn_architecture.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_design/xayn_design_test.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/personal_area/manager/personal_area_manager.dart';
import 'package:xayn_discovery_app/presentation/personal_area/personal_area_screen.dart';
import 'package:xayn_discovery_app/presentation/personal_area/widget/personal_area_card.dart';
import 'package:xayn_discovery_app/presentation/widget/app_toolbar.dart';

import '../utils/utils.dart';
import '../utils/widget_test_utils.dart';

void main() {
  late StreamController<None> streamController;
  late MockPersonalAreaManager manager;

  setUp(() async {
    await setupWidgetTest();
    manager = MockPersonalAreaManager();
    di.registerSingleton<PersonalAreaManager>(manager);
    when(manager.state).thenReturn(none);
    streamController = StreamController<None>();
    when(manager.stream).thenAnswer((_) => streamController.stream);
  });

  tearDown(() async {
    await tearDownWidgetTest();
    streamController.close();
  });

  Future<void> openScreen(WidgetTester tester) async {
    await tester.pumpLindenApp(
      const PersonalAreaScreen(),
      initialLinden: Linden(newColors: true),
    );
    await tester.pumpAndSettle(R.animations.screenStateChangeDuration);
  }

  testWidgets(
    'WHEN create PersonalAreaScreen THEN view is correct',
    (final WidgetTester tester) async {
      await openScreen(tester);

      expect(find.byType(AppToolbar), findsOneWidget);
      expect(find.text('${R.strings.your} ${R.strings.personalAreaTitle}'),
          findsOneWidget);
      expect(find.byType(PersonalAreaCard), findsNWidgets(3));
      expect(find.byKey(Keys.personalAreaCardCollections), findsOneWidget);
      expect(find.byKey(Keys.personalAreaCardHomeFeed), findsOneWidget);
      expect(find.byKey(Keys.personalAreaCardSettings), findsOneWidget);
    },
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
    );
    testWidgets(
      'WHEN clicked on activeSearch THEN call redirected to manager',
      (final WidgetTester tester) async {
        await tester.initToDiscoveryPage();
        await tester.navigateToPersonalArea();

        await tester.tap(Keys.navBarItemSearch.finds());
        verify(manager.onActiveSearchNavPressed());
      },
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
    );

    testWidgets(
      'WHEN clicked on homeFeed THEN call redirected to manager',
      (final WidgetTester tester) async {
        await openScreen(tester);

        await tester.tap(Keys.personalAreaCardHomeFeed.finds());
        verify(manager.onHomeFeedSettingsNavPressed());
      },
    );

    testWidgets(
      'WHEN clicked on settings THEN call redirected to manager',
      (final WidgetTester tester) async {
        await openScreen(tester);

        await tester.tap(Keys.personalAreaCardSettings.finds());
        verify(manager.onSettingsNavPressed());
      },
    );
  });
}
