import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_design/xayn_design_test.dart';
import 'package:xayn_discovery_app/domain/model/app_theme.dart';
import 'package:xayn_discovery_app/domain/model/payment/subscription_status.dart';
import 'package:xayn_discovery_app/infrastructure/di/di_config.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_manager.dart';
import 'package:xayn_discovery_app/presentation/settings/manager/settings_state.dart';
import 'package:xayn_discovery_app/presentation/settings/settings_screen.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/app_theme_section.dart';

import '../test_utils/utils.dart';
import '../test_utils/widget_test_utils.dart';

void main() {
  late StreamController<SettingsScreenState> streamController;
  final stateReady = SettingsScreenState.ready(
    theme: AppTheme.system,
    isPaymentEnabled: false,
    isTtsEnabled: true,
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
}
