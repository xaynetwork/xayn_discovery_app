import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_design/src/utils/design_testing_utils.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/feed_settings_screen.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/manager/feed_settings_manager.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/manager/feed_settings_state.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/page/country_feed_settings_page.dart';

import '../test_utils/utils.dart';
import '../test_utils/widget_test_utils.dart';
import 'manager/feed_settings_manager_test.dart';

void main() {
  late StreamController<FeedSettingsState> streamController;
  late MockFeedSettingsManager manager;

  setUp(() async {
    await setupWidgetTest();
    manager = MockFeedSettingsManager();
    di.registerSingleton<FeedSettingsManager>(manager);
    streamController = StreamController<FeedSettingsState>();

    when(manager.state).thenReturn(stateReady);
    when(manager.stream).thenAnswer((_) => streamController.stream);
  });

  tearDown(() async {
    await tearDownWidgetTest();
    await streamController.close();
  });

  Future<void> openScreen(WidgetTester tester) async {
    await tester.pumpLindenApp(
      const FeedSettingsScreen(),
      initialLinden: Linden(newColors: true),
    );
  }

  testWidgets(
    'GIVEN state initial WHEN manager emit state THEN no page found',
    (final WidgetTester tester) async {
      when(manager.state).thenReturn(const FeedSettingsState.initial());
      await openScreen(tester);

      expect(find.byType(CountryFeedSettingsPage), findsNothing);
    },
  );

  testWidgets(
    'GIVEN state ready WHEN manager emit state THEN CountryFeedSettingsPage found',
    (final WidgetTester tester) async {
      await openScreen(tester);

      final finder = find.byType(CountryFeedSettingsPage);
      expect(finder, findsOneWidget);

      final widget = (finder.first.evaluate().first as StatelessElement).widget
          as CountryFeedSettingsPage;
      expect(widget.selectedCountries, equals(stateReady.selectedCountries));
      expect(
        widget.unSelectedCountries,
        equals(stateReady.unSelectedCountries),
      );
      expect(
        widget.maxSelectedCountryAmount,
        equals(stateReady.maxSelectedCountryAmount),
      );
    },
  );

  testWidgets(
    'WHEN create FeedSettingsScreenState THEN navBarConfigs is correct',
    (final WidgetTester tester) async {
      await tester.initToDiscoveryPage();
      await tester.navigateToPersonalArea();
      await tester.navigateToFeedSettings();

      final state =
          (find.byType(FeedSettingsScreen).evaluate().first as StatefulElement)
              .state as FeedSettingsScreenState;
      final configs = state.navBarConfig;

      expect(configs.items.length, equals(1));
      expect(configs.items.first, isA<NavBarItemBackButton>());

      await tester.tap(Keys.navBarItemBackBtn.finds());
      verify(manager.onBackNavPressed());
    },
  );

  testWidgets(
    'WHEN unselected country clicked THEN call manager onAddCountryPressed',
    (final WidgetTester tester) async {
      await openScreen(tester);

      await tester.tap(keyGermany.finds());
      verify(manager.onAddCountryPressed(germany));
    },
  );

  testWidgets(
    'WHEN selected country clicked THEN call manager onRemoveCountryPressed',
    (final WidgetTester tester) async {
      await openScreen(tester);

      await tester.tap(keyUsa.finds());
      verify(manager.onRemoveCountryPressed(usa));
    },
  );
}
