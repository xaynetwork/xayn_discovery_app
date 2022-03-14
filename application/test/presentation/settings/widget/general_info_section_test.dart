import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xayn_design/xayn_design.dart';
import 'package:xayn_design/xayn_design_test.dart';
import 'package:xayn_discovery_app/presentation/constants/keys.dart';
import 'package:xayn_discovery_app/presentation/constants/r.dart';
import 'package:xayn_discovery_app/presentation/settings/widget/general_info_section.dart';

void main() {
  final linden = Linden();
  testWidgets(
    'GIVEN section THEN verify all widgets present',
    (final WidgetTester tester) async {
      await tester.pumpLindenApp(
        SettingsGeneralInfoSection(
          onAboutPressed: () {},
          onImprintPressed: () {},
          onCarbonNeutralPressed: () {},
          onTermsPressed: () {},
          onPrivacyPressed: () {},
          onContactPressed: () {},
        ),
        initialLinden: linden,
      );

      const kidsAmount = 6;
      expect(
        find.text(R.strings.settingsSectionTitleGeneralInfo),
        findsOneWidget,
      );
      expect(find.text(R.strings.settingsAboutXayn), findsOneWidget);
      expect(find.text(R.strings.settingsCarbonNeutral), findsOneWidget);
      expect(find.text(R.strings.settingsImprint), findsOneWidget);
      expect(find.text(R.strings.settingsPrivacyPolicy), findsOneWidget);
      expect(find.text(R.strings.settingsTermsAndConditions), findsOneWidget);

      expect(find.byType(SettingsSection), findsOneWidget);
      expect(find.byType(SettingsCard), findsNWidgets(kidsAmount));
      expect(find.byType(SettingsGroup), findsNWidgets(kidsAmount));
      expect(find.byType(SettingsTile), findsNWidgets(kidsAmount));
      expect(find.byType(Text), findsNWidgets(kidsAmount + 1));
    },
  );
  testWidgets(
    'GIVEN section WHEN clicked btn THEN proper callbacks are called',
    (final WidgetTester tester) async {
      final callbacks = {
        Keys.settingsAboutXayn: false,
        Keys.settingsImprint: false,
        Keys.settingsCarbonNeutral: false,
        Keys.settingsTermsAndConditions: false,
        Keys.settingsPrivacyPolicy: false,
        Keys.settingsContacts: false,
      };
      final widget = SettingsGeneralInfoSection(
        onAboutPressed: () => callbacks[Keys.settingsAboutXayn] = true,
        onImprintPressed: () => callbacks[Keys.settingsImprint] = true,
        onCarbonNeutralPressed: () =>
            callbacks[Keys.settingsCarbonNeutral] = true,
        onTermsPressed: () => callbacks[Keys.settingsTermsAndConditions] = true,
        onPrivacyPressed: () => callbacks[Keys.settingsPrivacyPolicy] = true,
        onContactPressed: () => callbacks[Keys.settingsContacts] = true,
      );
      await tester.pumpLindenApp(widget, initialLinden: linden);

      for (final key in callbacks.keys) {
        final btnFinder = find.byKey(key);
        await tester.tap(btnFinder);
        expect(callbacks[key], isTrue, reason: 'key: $key');
      }
    },
  );
}
