import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_discovery_app/presentation/active_search/widget/active_search.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/discovery_feed/widget/discovery_feed.dart';
import 'package:xayn_discovery_app/presentation/settings/settings_screen.dart';

import '../utils/utils.dart';
import '../utils/widget_test_utils.dart';

void main() {
  setUp(() {
    setupWidgetTest();
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
      'In Discovery clicking on search, navigates to the Active Search screen.',
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

  testWidgets('In DiscoveryFeed clicking on Account, navigates to Settings',
      (driver) async {
    await driver.initToDiscoveryPage();

    await driver.navigateToAccount();

    expect(find.byType(DiscoveryFeed), findsNothing);
    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets(
      'In Settings (coming from search) clicking back, navigates to search',
      (driver) async {
    await driver.initToDiscoveryPage();
    await driver.navigateToSearch();
    await driver.navigateToAccount();

    await driver.navigateBack();

    expect(find.byType(SettingsScreen), findsNothing);
    expect(find.byType(ActiveSearch), findsOneWidget);
  });

  testWidgets(
      'In Settings (coming from discovery) clicking back, navigates to discovery',
      (driver) async {
    await driver.initToDiscoveryPage();
    await driver.navigateToAccount();

    await driver.navigateBack();

    expect(find.byType(SettingsScreen), findsNothing);
    expect(find.byType(DiscoveryFeed), findsOneWidget);
  });
}
