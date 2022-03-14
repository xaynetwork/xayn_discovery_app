import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_design/xayn_design_test.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_external_url_event.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/constants/urls.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_manager.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_state.dart';
import 'package:xayn_discovery_app/presentation/settings/settings_screen.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/app_theme_section.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/general_info_section.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/help_imptrove_section.dart';

import '../test_utils/utils.dart';
import '../test_utils/widget_test_utils.dart';

void main() {
  late StreamController<SettingsScreenState> streamController;
  const stateReady = SettingsScreenState.ready(
      theme: AppTheme.system,
      appVersion: AppVersion(
        version: '1.2.3',
        build: '321',
      ),
      isPaymentEnabled: false,
      isTtsEnabled: true,
      trialEndDate: null) as SettingsScreenStateReady;
  late MockSettingsScreenManager manager;

  setUp(() async {
    await setupWidgetTest();
    manager = MockSettingsScreenManager();
    di.registerSingleton<SettingsScreenManager>(manager);
    when(manager.state).thenReturn(stateReady);
    streamController = StreamController<SettingsScreenState>();
    when(manager.stream).thenAnswer((_) => streamController.stream);
    when(manager.reportBug()).thenAnswer((_) async {});
  });

  tearDown(() async {
    await tearDownWidgetTest();
    streamController.close();
  });

  Future<void> openScreen(WidgetTester tester) async {
    await tester.pumpLindenApp(
      const SettingsScreen(),
      initialLinden: Linden(),
    );
    await tester.pumpAndSettle(R.animations.screenStateChangeDuration);
  }

  testWidgets(
    'WHEN create SettingsScreen THEN all sections presented',
    (final WidgetTester tester) async {
      await openScreen(tester);

      expect(find.byType(SettingsAppThemeSection), findsOneWidget);
      expect(find.byType(SettingsGeneralInfoSection), findsOneWidget);
      expect(find.byType(SettingsHelpImproveSection), findsOneWidget);

      final versionText =
          '${R.strings.settingsVersion} ${stateReady.appVersion.version}\n'
          '${R.strings.settingsBuild} ${stateReady.appVersion.build}';

      final btnFinder = find.text(versionText);
      await tester.dragUntilVisible(
        btnFinder,
        find.byType(SingleChildScrollView),
        const Offset(-250, 0), // delta to move
      );
    },
  );

  testWidgets(
    'WHEN "change theme" clicked THEN call manager changeTheme method',
    (final WidgetTester tester) async {
      await openScreen(tester);

      final btnFinder = find.byKey(Keys.settingsThemeDark);
      await tester.tap(btnFinder);

      verifyInOrder([
        manager.state,
        manager.state,
        manager.stream,

        // actual click happened here
        manager.saveTheme(AppTheme.dark),
      ]);
      verifyNoMoreInteractions(manager);
    },
  );

  testWidgets(
    'WHEN "report bug" clicked THEN call manager reportBug method',
    (final WidgetTester tester) async {
      await openScreen(tester);

      final btnFinder = find.byKey(Keys.settingsHaveFoundBug);

      await tester.dragUntilVisible(
        btnFinder,
        find.byType(SingleChildScrollView),
        const Offset(-250, 0), // delta to move
      );

      await tester.tap(btnFinder);

      verifyInOrder([
        manager.state,
        manager.state,
        manager.stream,

        // actual click happened here
        manager.reportBug(),
      ]);
      verifyNoMoreInteractions(manager);
    },
  );

  testWidgets(
    'WHEN "spread word" clicked THEN call manager shareApp method',
    (final WidgetTester tester) async {
      await openScreen(tester);

      final btnFinder = find.byKey(Keys.settingsShareBtn);
      await tester.dragUntilVisible(
        btnFinder,
        find.byType(SingleChildScrollView),
        const Offset(-250, 0), // delta to move
      );

      await tester.tap(btnFinder);

      verifyInOrder([
        manager.state,
        manager.state,
        manager.stream,

        // actual click happened here
        manager.shareApp(),
      ]);
      verifyNoMoreInteractions(manager);
    },
  );

  group('url clicks', () {
    Future<void> testUrlClicked({
      required WidgetTester tester,
      required String url,
      required Key btnKey,
    }) async {
      await openScreen(tester);

      final btnFinder = find.byKey(btnKey);
      await tester.scrollUntilVisible(btnFinder, 10);
      await tester.tap(btnFinder);

      verifyInOrder([
        manager.state,
        manager.state,
        manager.stream,

        // actual click happened here
        manager.openExternalUrl(url, CurrentView.settings),
      ]);
      verifyNoMoreInteractions(manager);
    }

    testWidgets(
      'WHEN "about" clicked THEN call manager with proper URL',
      (final WidgetTester tester) => testUrlClicked(
        tester: tester,
        url: Urls.aboutXayn,
        btnKey: Keys.settingsAboutXayn,
      ),
    );

    testWidgets(
      'WHEN "carbon neutral" clicked THEN call manager with proper URL',
      (final WidgetTester tester) => testUrlClicked(
        tester: tester,
        url: Urls.carbonNeutral,
        btnKey: Keys.settingsCarbonNeutral,
      ),
    );

    testWidgets(
      'WHEN "imprint" clicked THEN call manager with proper URL',
      (final WidgetTester tester) => testUrlClicked(
        tester: tester,
        url: Urls.imprint,
        btnKey: Keys.settingsImprint,
      ),
    );

    testWidgets(
      'WHEN "privacy" clicked THEN call manager with proper URL',
      (final WidgetTester tester) => testUrlClicked(
        tester: tester,
        url: Urls.privacyPolicy,
        btnKey: Keys.settingsPrivacyPolicy,
      ),
    );

    testWidgets(
      'WHEN "termsAndConditions" clicked THEN call manager with proper URL',
      (final WidgetTester tester) => testUrlClicked(
        tester: tester,
        url: Urls.termsAndConditions,
        btnKey: Keys.settingsTermsAndConditions,
      ),
    );

    testWidgets(
      'WHEN SettingsManager disposed THEN manager.close not called',
      (final WidgetTester tester) async {
        when(manager.onBackNavPressed()).thenAnswer((_) {
          di.get<SettingsNavActions>().onBackNavPressed();
        });
        await tester.initToDiscoveryPage();
        await tester.navigateToPersonalArea();
        await tester.navigateToSettingsScreen();
        await tester.navigateBack();
        expect(find.byType(SettingsScreen), findsNothing);

        verifyNever(manager.close());
      },
    );
  });
}
