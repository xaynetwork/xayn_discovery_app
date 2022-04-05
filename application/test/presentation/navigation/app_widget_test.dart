import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/active_search/widget/active_search.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/widget/discovery_feed.dart';
import 'package:xayn_discovery_app/presentation/new_personal_area/new_personal_area_screen.dart';
import 'package:xayn_discovery_app/presentation/settings/settings_screen.dart';

import '../test_utils/utils.dart';
import '../test_utils/widget_test_utils.dart';

void main() {
  setUp(() async {
    await setupWidgetTest();
  });

  tearDown(() async {
    await tearDownWidgetTest();
  });

  testWidgets(
      'Starting the with Feature.featuresScreen app should show the feature selection screen.',
      (driver) async {
    await driver.initToFeatureSelectionPage();

    expect(find.byKey(Keys.featureSelectionButton), findsOneWidget);
  });

  testWidgets(
      'Starting the with Feature.featuresScreen disabled shout go directly to the discovery screen.',
      (driver) async {
    await driver.initToDiscoveryPage();

    expect(Keys.featureSelectionButton.finds(), findsNothing);
    expect(find.byType(DiscoveryFeed), findsOneWidget);
    expect(find.byType(NavBar), findsOneWidget);
  });

  testWidgets(
      'In Discovery clicking on search, navigate to the Active Search screen',
      (driver) async {
    await driver.initToDiscoveryPage();
    await driver.navigateToSearch();

    expect(find.byType(DiscoveryFeed), findsNothing);
    expect(find.byType(ActiveSearch), findsOneWidget);
  });

  testWidgets('In Active Search clicking on home returns to discovery feed',
      (driver) async {
    await driver.initToDiscoveryPage();
    await driver.navigateToSearch();

    await driver.navigateToHome();

    expect(find.byType(ActiveSearch), findsNothing);
    expect(find.byType(DiscoveryFeed), findsOneWidget);
  });

  testWidgets(
      'In DiscoveryFeed clicking on PersonalArea, navigates to Settings',
      (driver) async {
    await driver.initToDiscoveryPage();

    await driver.navigateToPersonalArea();

    expect(find.byType(DiscoveryFeed), findsNothing);
    expect(find.byType(NewPersonalAreaScreen), findsOneWidget);
  });

  testWidgets(
      'In Settings (coming from NewPersonalAreaScreen) clicking back, navigates to NewPersonalAreaScreen',
      (driver) async {
    await driver.initToDiscoveryPage();
    await driver.navigateToPersonalArea();
    await driver.navigateToSettingsScreen();

    await driver.navigateBack();

    expect(find.byType(SettingsScreen), findsNothing);
    expect(find.byType(NewPersonalAreaScreen), findsOneWidget);
  });
}
