import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_design/src/utils/design_testing_utils.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/domain/model/feature.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/feature/manager/feature_manager.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/feed_settings_screen.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/manager/country_feed_settings_manager.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/manager/country_feed_settings_state.dart';
import 'package:xayn_discovery_app/presentation/feed_settings/page/country_feed_settings_page.dart';

import '../test_utils/utils.dart';
import '../test_utils/widget_test_utils.dart';
import 'manager/country_feed_settings_manager_test.dart';

void main() {
  late StreamController<CountryFeedSettingsState> streamController;
  late MockCountryFeedSettingsManager manager;

  setUp(() async {
    await setupWidgetTest();
    di.get<FeatureManager>().overrideFeature(Feature.documentFilter, false);
    manager = MockCountryFeedSettingsManager();
    di.registerSingleton<CountryFeedSettingsManager>(manager);
    streamController = StreamController<CountryFeedSettingsState>.broadcast();

    when(manager.state).thenReturn(stateReady);
    when(manager.stream).thenAnswer((_) => streamController.stream);
  });

  tearDown(() async {
    await tearDownWidgetTest();
    await streamController.close();
  });

  Future<void> openScreen(WidgetTester tester) async {
    const child = ApplicationTooltipProvider(
      child: FeedSettingsScreen(),
      messageFactory: {},
    );
    await tester.pumpLindenApp(
      child,
      initialLinden: Linden(),
    );
  }

  testWidgets(
    'GIVEN state initial WHEN manager emit state THEN no page found',
    (final WidgetTester tester) async {
      when(manager.state).thenReturn(const CountryFeedSettingsState.initial());
      await openScreen(tester);

      expect(find.byType(SelectCountries), findsNothing);
    },
  );

  testWidgets(
    'GIVEN state ready WHEN manager emit state THEN CountryFeedSettingsPage found',
    (final WidgetTester tester) async {
      await openScreen(tester);

      final finder = find.byType(SelectCountries);
      expect(finder, findsOneWidget);
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
    },
  );

  testWidgets(
    'WHEN unselected country clicked THEN call manager onAddCountryPressed',
    (final WidgetTester tester) async {
      await openScreen(tester);

      when(manager.onAddCountryPressed(germany)).thenAnswer((_) async => true);
      await tester.tap(keyGermany.finds());
      verify(manager.onAddCountryPressed(germany));
    },
  );

  testWidgets(
    'WHEN selected country clicked THEN call manager onRemoveCountryPressed',
    (final WidgetTester tester) async {
      await openScreen(tester);

      when(manager.onRemoveCountryPressed(usa)).thenAnswer((_) async => true);
      await tester.tap(keyUsa.finds());
      verify(manager.onRemoveCountryPressed(usa));
    },
  );
}
