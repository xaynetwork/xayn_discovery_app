import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_design/xayn_design_test.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/app_version.dart';
import 'package:xayn_discovery_app/domain/model/feed_settings/feed_mode.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/infrastructure/service/analytics/events/open_external_url_event.dart';
import 'package:xayn_discovery_app/presentation/constants/constants.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_manager.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_state.dart';
import 'package:xayn_discovery_app/presentation/settings/settings_screen.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/app_theme_section.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/general_info_section.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/help_improve_section.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/home_feed_settings_section.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/subscripton_section.dart';
import 'package:xayn_discovery_app/presentation/utils/overlay/overlay_manager.dart';

import '../../test_utils/utils.dart';
import '../../test_utils/widget_test_utils.dart';

void main() {
  late StreamController<SettingsScreenState> streamController;
  final stateReady = SettingsScreenState.ready(
    theme: AppTheme.system,
    feedMode: FeedMode.stream,
    appVersion: const AppVersion(
      version: '1.2.3',
      build: '321',
    ),
    isPaymentEnabled: false,
    arePushNotificationDeepLinksEnabled: false,
    subscriptionStatus: SubscriptionStatus.initial(),
  ) as SettingsScreenStateReady;
  late MockSettingsScreenManager manager;

  setUp(() async {
    await setupWidgetTest();
    manager = MockSettingsScreenManager();
    di.registerSingleton<SettingsScreenManager>(manager);
    when(manager.state).thenReturn(stateReady);
    streamController = StreamController<SettingsScreenState>();
    when(manager.stream).thenAnswer((_) => streamController.stream);
    when(manager.reportBug()).thenAnswer((_) async {});
    when(manager.overlayManager).thenAnswer((_) => OverlayManager());
  });

  tearDown(() async {
    await tearDownWidgetTest();
    streamController.close();
  });

  Future<void> openScreen(WidgetTester tester) async {
    await tester.pumpLindenApp(
      const ApplicationTooltipProvider(
        child: SettingsScreen(),
      ),
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
      expect(find.byType(SettingsHomeFeedSection), findsOneWidget);

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
    'WHEN create SettingsScreen AND beta user THEN subscription sections is not visible',
    (final WidgetTester tester) async {
      final state = SettingsScreenState.ready(
        theme: AppTheme.system,
        feedMode: FeedMode.stream,
        appVersion: const AppVersion(
          version: '1.2.3',
          build: '321',
        ),
        isPaymentEnabled: false,
        arePushNotificationDeepLinksEnabled: false,
        subscriptionStatus: SubscriptionStatus.initial().copyWith(
          isBetaUser: true,
        ),
      ) as SettingsScreenStateReady;

      when(manager.state).thenReturn(state);

      await openScreen(tester);

      expect(find.byType(SubscriptionSection), findsNothing);
    },
  );

  testWidgets(
    'WHEN create SettingsScreen AND not beta user AND payments enabled AND free trial active THEN subscription sections is visible',
    (final WidgetTester tester) async {
      final state = SettingsScreenState.ready(
        theme: AppTheme.system,
        feedMode: FeedMode.stream,
        appVersion: const AppVersion(
          version: '1.2.3',
          build: '321',
        ),
        isPaymentEnabled: true,
        arePushNotificationDeepLinksEnabled: false,
        subscriptionStatus: SubscriptionStatus.initial().copyWith(
          trialEndDate: DateTime.now().add(const Duration(days: 1)),
          isBetaUser: false,
        ),
      ) as SettingsScreenStateReady;

      when(manager.state).thenReturn(state);

      await openScreen(tester);

      expect(find.byType(SubscriptionSection), findsOneWidget);
    },
  );

  testWidgets(
    'WHEN "change theme" clicked THEN call manager changeTheme method',
    (final WidgetTester tester) async {
      await openScreen(tester);

      final btnFinder = find.byKey(Keys.settingsThemeDark);
      await tester.tap(btnFinder);

      verifyInOrder([
        manager.overlayManager,
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
        manager.overlayManager,
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
        manager.overlayManager,
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
        manager.overlayManager,
        manager.state,
        manager.state,
        manager.stream,

        // actual click happened here
        manager.openExternalUrl(
          url: url,
          currentView: CurrentView.settings,
        ),
      ]);
      verifyNoMoreInteractions(manager);
    }

    testWidgets(
      'WHEN "about" clicked THEN call manager with proper URL',
      (final WidgetTester tester) => testUrlClicked(
        tester: tester,
        url: Constants.aboutXaynUrl,
        btnKey: Keys.settingsAboutXayn,
      ),
    );

    testWidgets(
      'WHEN "carbon neutral" clicked THEN call manager with proper URL',
      (final WidgetTester tester) => testUrlClicked(
        tester: tester,
        url: Constants.carbonNeutralUrl,
        btnKey: Keys.settingsCarbonNeutral,
      ),
    );

    testWidgets(
      'WHEN "imprint" clicked THEN call manager with proper URL',
      (final WidgetTester tester) => testUrlClicked(
        tester: tester,
        url: Constants.imprintUrl,
        btnKey: Keys.settingsImprint,
      ),
    );

    testWidgets(
      'WHEN "privacy" clicked THEN call manager with proper URL',
      (final WidgetTester tester) => testUrlClicked(
        tester: tester,
        url: Constants.privacyPolicyUrl,
        btnKey: Keys.settingsPrivacyPolicy,
      ),
    );

    testWidgets(
      'WHEN "termsAndConditions" clicked THEN call manager with proper URL',
      (final WidgetTester tester) => testUrlClicked(
        tester: tester,
        url: Constants.termsAndConditionsUrl,
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
